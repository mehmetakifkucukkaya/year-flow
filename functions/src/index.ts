/**
 * Firebase Cloud Functions - AI Integration
 * Google Gemini API ile hedef optimizasyonu, AI önerileri ve yıllık rapor üretimi
 */

import {onCall, HttpsError} from 'firebase-functions/v2/https';
import {defineSecret} from 'firebase-functions/params';
import {setGlobalOptions} from 'firebase-functions/v2';
import * as logger from 'firebase-functions/logger';
import * as dotenv from 'dotenv';
import * as admin from 'firebase-admin';
import {GeminiClient} from './ai/gemini-client';
import {optimizeGoal} from './ai/optimize-goal';
import {generateSuggestions} from './ai/generate-suggestions';
import {generateYearlyReport} from './ai/generate-yearly-report';
import {generateWeeklyReport} from './ai/generate-weekly-report';
import {generateMonthlyReport} from './ai/generate-monthly-report';
import {suggestSubGoals} from './ai/suggest-subgoals';
import {
  OptimizeGoalResponse,
  GenerateSuggestionsResponse,
  GenerateYearlyReportResponse,
  GenerateWeeklyReportResponse,
  GenerateMonthlyReportResponse,
  SuggestSubGoalsResponse,
} from './types/ai-types';
import {onSchedule} from 'firebase-functions/v2/scheduler';

// Load environment variables in local / emulator environments.
// On deployed Cloud Functions, environment variables should be configured
// via the platform and will already be available in process.env.
dotenv.config();

// Initialize Admin SDK (idempotent)
if (!admin.apps.length) {
  admin.initializeApp();
}

// Global options for cost control
setGlobalOptions({
  maxInstances: 10,
  region: 'europe-west1',
});

// Define secret for Gemini API key
// To set: firebase functions:secrets:set GEMINI_API_KEY
const geminiApiKeySecret = defineSecret('GEMINI_API_KEY');

/**
 * Basic input sanitization helpers
 */
function sanitizeString(
  value: unknown,
  fieldName: string,
  maxLength: number,
  required = true,
): string | undefined {
  if (value === undefined || value === null) {
    if (required) {
      throw new HttpsError(
        'invalid-argument',
        `${fieldName} is required`,
      );
    }
    return undefined;
  }

  if (typeof value !== 'string') {
    throw new HttpsError(
      'invalid-argument',
      `${fieldName} must be a string`,
    );
  }

  const trimmed = value.trim();

  if (required && trimmed.length === 0) {
    throw new HttpsError(
      'invalid-argument',
      `${fieldName} cannot be empty`,
    );
  }

  if (trimmed.length > maxLength) {
    throw new HttpsError(
      'invalid-argument',
      `${fieldName} is too long (max ${maxLength} characters)`,
    );
  }

  return trimmed;
}

function sanitizeArraySize(
  value: unknown,
  fieldName: string,
  maxLength: number,
): void {
  if (value === undefined || value === null) {
    return;
  }

  if (!Array.isArray(value)) {
    throw new HttpsError(
      'invalid-argument',
      `${fieldName} must be an array`,
    );
  }

  if (value.length > maxLength) {
    throw new HttpsError(
      'invalid-argument',
      `${fieldName} is too large (max ${maxLength} items)`,
    );
  }
}

/**
 * Simple Firestore-based per-user rate limiting for AI endpoints.
 * Prevents abuse & cost explosion.
 */
const RATE_LIMIT_COLLECTION = 'aiRateLimits';

async function enforceRateLimit(
  userId: string,
  endpoint: string,
  maxPerMinute: number,
  maxPerDay: number,
): Promise<void> {
  const db = admin.firestore();
  const now = admin.firestore.Timestamp.now();
  const docRef = db.collection(RATE_LIMIT_COLLECTION).doc(userId);

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(docRef);
    const data = snap.exists ? snap.data() as any : {};

    const endpointKey = endpoint;
    const perEndpoint = data[endpointKey] || {};

    const minuteWindowMs = 60 * 1000;
    const dayWindowMs = 24 * 60 * 60 * 1000;

    const lastMinuteTs: admin.firestore.Timestamp =
      perEndpoint.lastMinuteTs || now;
    const lastDayTs: admin.firestore.Timestamp =
      perEndpoint.lastDayTs || now;

    const lastMinuteDate = lastMinuteTs.toDate();
    const lastDayDate = lastDayTs.toDate();
    const nowDate = now.toDate();

    let minuteCount =
      perEndpoint.minuteCount && nowDate.getTime() - lastMinuteDate.getTime() < minuteWindowMs
        ? perEndpoint.minuteCount as number
        : 0;
    let dayCount =
      perEndpoint.dayCount && nowDate.getTime() - lastDayDate.getTime() < dayWindowMs
        ? perEndpoint.dayCount as number
        : 0;

    minuteCount += 1;
    dayCount += 1;

    if (minuteCount > maxPerMinute || dayCount > maxPerDay) {
      throw new HttpsError(
        'resource-exhausted',
        'AI rate limit exceeded. Please try again later.',
      );
    }

    tx.set(
      docRef,
      {
        [endpointKey]: {
          minuteCount,
          dayCount,
          lastMinuteTs: now,
          lastDayTs: now,
        },
        updatedAt: now,
      },
      {merge: true},
    );
  });
}

/**
 * Scheduled cleanup job to remove orphan checkIns and notes
 * that reference non-existing goals.
 *
 * Çalışma şekli:
 * - Her çalıştığında sınırlı sayıda (ör. 500) check-in ve note dokümanını tarar.
 * - İlgili goal dokümanı yoksa, orphan kabul edip siler.
 * - Maliyet için her koşuda sınırlı sayıda doküman işlenir.
 */
export const cleanupOrphansJob = onSchedule(
  {
    schedule: 'every 24 hours',
    timeZone: 'Etc/UTC',
    region: 'europe-west1',
  },
  async () => {
    const db = admin.firestore();
    const batchSize = 500;

    // Helper: orphan temizliği için generic fonksiyon
    async function cleanupCollection(
      collectionPath: string,
      type: 'checkIns' | 'notes',
    ): Promise<void> {
      const snap = await db
        .collectionGroup(collectionPath)
        .limit(batchSize)
        .get();

      if (snap.empty) {
        return;
      }

      const batch = db.batch();
      let deleteCount = 0;

      for (const doc of snap.docs) {
        const data = doc.data() as any;
        const goalId = data.goalId as string | undefined;
        const userId = data.userId as string | undefined;

        if (!goalId || !userId) {
          continue;
        }

        const goalRef = db
          .collection('users')
          .doc(userId)
          .collection('goals')
          .doc(goalId);

        const goalSnap = await goalRef.get();
        if (!goalSnap.exists) {
          batch.delete(doc.ref);
          deleteCount += 1;
        }
      }

      if (deleteCount > 0) {
        await batch.commit();
        logger.info('Orphan cleanup completed', {
          collectionPath,
          deleted: deleteCount,
        });
      }
    }

    try {
      await cleanupCollection('checkIns', 'checkIns');
      await cleanupCollection('notes', 'notes');
    } catch (error: any) {
      logger.error('Error in cleanupOrphansJob', error);
      throw error;
    }
  },
);

/**
 * Initialize Gemini client with secret
 */
function getGeminiClient(apiKey: string): GeminiClient {
  try {
    if (!apiKey) {
      throw new Error('GEMINI_API_KEY is not set');
    }
    return new GeminiClient(apiKey);
  } catch (error: any) {
    logger.error('Failed to initialize Gemini client:', error);
    throw new HttpsError('internal', 'AI service initialization failed');
  }
}

/**
 * Optimize Goal - Convert user goal to SMART format and suggest sub-goals
 */
export const optimizeGoalFunction = onCall(
  {
    region: 'europe-west1',
    timeoutSeconds: 60,
    memory: '512MiB',
    secrets: [geminiApiKeySecret],
  },
  async (request): Promise<OptimizeGoalResponse> => {
    // Authentication check
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    // Per-user rate limiting
    await enforceRateLimit(request.auth.uid, 'optimizeGoal', 10, 100);

    const rawGoalTitle = request.data.goalTitle;
    const rawCategory = request.data.category;

    const goalTitle = sanitizeString(rawGoalTitle, 'goalTitle', 200, true);
    const category = sanitizeString(rawCategory, 'category', 50, true);

    // Optional fields
    const motivation = sanitizeString(
      request.data.motivation,
      'motivation',
      2000,
      false,
    );

    try {
      const geminiClient = getGeminiClient(geminiApiKeySecret.value());
      const result = await optimizeGoal(
        {
          ...request.data,
          goalTitle,
          category,
          motivation,
        },
        geminiClient,
      );

      logger.info('Goal optimized successfully', {
        userId: request.auth.uid,
        originalTitle: goalTitle,
      });

      return result;
    } catch (error: any) {
      logger.error('Error in optimizeGoalFunction:', error);
      throw new HttpsError(
        'internal',
        `Failed to optimize goal: ${error.message}`
      );
    }
  }
);

/**
 * Generate AI Suggestions - Personalized recommendations based on goals and progress
 */
export const generateSuggestionsFunction = onCall(
  {
    region: 'europe-west1',
    timeoutSeconds: 60,
    memory: '512MiB',
    secrets: [geminiApiKeySecret],
  },
  async (request): Promise<GenerateSuggestionsResponse> => {
    // Authentication check
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const {userId, goals, checkIns} = request.data;

    if (request.auth.uid !== userId) {
      throw new HttpsError('permission-denied', 'User can only access own data');
    }

    if (!goals || !Array.isArray(goals)) {
      throw new HttpsError('invalid-argument', 'goals array is required');
    }

    // Rate limit + payload size limits
    await enforceRateLimit(userId, 'generateSuggestions', 5, 50);
    sanitizeArraySize(goals, 'goals', 200);
    sanitizeArraySize(checkIns, 'checkIns', 2000);

    try {
      const geminiClient = getGeminiClient(geminiApiKeySecret.value());
      const result = await generateSuggestions(request.data, geminiClient);

      logger.info('Suggestions generated successfully', {
        userId,
        goalsCount: goals.length,
        checkInsCount: checkIns?.length || 0,
      });

      return result;
    } catch (error: any) {
      logger.error('Error in generateSuggestionsFunction:', error);
      throw new HttpsError(
        'internal',
        `Failed to generate suggestions: ${error.message}`
      );
    }
  }
);

/**
 * Generate Yearly Report - Comprehensive AI-generated yearly analysis
 */
export const generateYearlyReportFunction = onCall(
  {
    region: 'europe-west1',
    timeoutSeconds: 120,
    memory: '1GiB',
    secrets: [geminiApiKeySecret],
  },
  async (request): Promise<GenerateYearlyReportResponse> => {
    // Authentication check
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const {userId, year, goals, checkIns} = request.data;

    if (request.auth.uid !== userId) {
      throw new HttpsError('permission-denied', 'User can only access own data');
    }

    if (!year || !goals || !Array.isArray(goals)) {
      throw new HttpsError(
        'invalid-argument',
        'year and goals array are required'
      );
    }

    await enforceRateLimit(userId, 'generateYearlyReport', 3, 20);
    sanitizeArraySize(goals, 'goals', 300);
    sanitizeArraySize(checkIns, 'checkIns', 5000);

    try {
      const geminiClient = getGeminiClient(geminiApiKeySecret.value());
      const result = await generateYearlyReport(request.data, geminiClient);

      logger.info('Yearly report generated successfully', {
        userId,
        year,
        goalsCount: goals.length,
        checkInsCount: checkIns?.length || 0,
      });

      return result;
    } catch (error: any) {
      logger.error('Error in generateYearlyReportFunction:', error);
      throw new HttpsError(
        'internal',
        `Failed to generate yearly report: ${error.message}`
      );
    }
  }
);

/**
 * Suggest Sub-goals - Lightweight AI endpoint for sub-goal ideas
 */
export const suggestSubGoalsFunction = onCall(
  {
    region: 'europe-west1',
    timeoutSeconds: 45,
    memory: '512MiB',
    secrets: [geminiApiKeySecret],
  },
  async (request): Promise<SuggestSubGoalsResponse> => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    // Per-user rate limiting
    await enforceRateLimit(request.auth.uid, 'suggestSubGoals', 15, 150);

    const rawGoalTitle = request.data.goalTitle;
    const rawCategory = request.data.category;

    const goalTitle = sanitizeString(rawGoalTitle, 'goalTitle', 200, true);
    const category = sanitizeString(rawCategory, 'category', 50, true);

    try {
      const geminiClient = getGeminiClient(geminiApiKeySecret.value());
      const result = await suggestSubGoals(
        {
          ...request.data,
          goalTitle,
          category,
        },
        geminiClient,
      );

      logger.info('Sub-goal suggestions generated', {
        userId: request.auth.uid,
        goalTitle,
        subGoalCount: result.subGoals.length,
      });

      return result;
    } catch (error: any) {
      logger.error('Error in suggestSubGoalsFunction:', error);
      throw new HttpsError(
        'internal',
        `Failed to suggest sub-goals: ${error.message}`
      );
    }
  }
);

/**
 * Generate Weekly Report - AI-generated weekly analysis
 */
export const generateWeeklyReportFunction = onCall(
  {
    region: 'europe-west1',
    timeoutSeconds: 90,
    memory: '1GiB',
    secrets: [geminiApiKeySecret],
  },
  async (request): Promise<GenerateWeeklyReportResponse> => {
    // Authentication check
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const {userId, weekStart, weekEnd, goals, checkIns} = request.data;

    if (request.auth.uid !== userId) {
      throw new HttpsError('permission-denied', 'User can only access own data');
    }

    if (!weekStart || !weekEnd || !goals || !Array.isArray(goals)) {
      throw new HttpsError(
        'invalid-argument',
        'weekStart, weekEnd and goals array are required'
      );
    }

    await enforceRateLimit(userId, 'generateWeeklyReport', 5, 50);
    sanitizeArraySize(goals, 'goals', 200);
    sanitizeArraySize(checkIns, 'checkIns', 2000);

    try {
      const geminiClient = getGeminiClient(geminiApiKeySecret.value());
      const result = await generateWeeklyReport(request.data, geminiClient);

      logger.info('Weekly report generated successfully', {
        userId,
        weekStart,
        weekEnd,
        goalsCount: goals.length,
        checkInsCount: checkIns?.length || 0,
      });

      return result;
    } catch (error: any) {
      logger.error('Error in generateWeeklyReportFunction:', error);
      throw new HttpsError(
        'internal',
        `Failed to generate weekly report: ${error.message}`
      );
    }
  }
);

/**
 * Generate Monthly Report - AI-generated monthly analysis
 */
export const generateMonthlyReportFunction = onCall(
  {
    region: 'europe-west1',
    timeoutSeconds: 120,
    memory: '1GiB',
    secrets: [geminiApiKeySecret],
  },
  async (request): Promise<GenerateMonthlyReportResponse> => {
    // Authentication check
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const {userId, year, month, goals, checkIns} = request.data;

    if (request.auth.uid !== userId) {
      throw new HttpsError('permission-denied', 'User can only access own data');
    }

    if (!year || !month || !goals || !Array.isArray(goals)) {
      throw new HttpsError(
        'invalid-argument',
        'year, month and goals array are required'
      );
    }

    await enforceRateLimit(userId, 'generateMonthlyReport', 3, 30);
    sanitizeArraySize(goals, 'goals', 300);
    sanitizeArraySize(checkIns, 'checkIns', 5000);

    try {
      const geminiClient = getGeminiClient(geminiApiKeySecret.value());
      const result = await generateMonthlyReport(request.data, geminiClient);

      logger.info('Monthly report generated successfully', {
        userId,
        year,
        month,
        goalsCount: goals.length,
        checkInsCount: checkIns?.length || 0,
      });

      return result;
    } catch (error: any) {
      logger.error('Error in generateMonthlyReportFunction:', error);
      throw new HttpsError(
        'internal',
        `Failed to generate monthly report: ${error.message}`
      );
    }
  }
);
