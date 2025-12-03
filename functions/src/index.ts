/**
 * Firebase Cloud Functions - AI Integration
 * Google Gemini API ile hedef optimizasyonu, AI önerileri ve yıllık rapor üretimi
 */

import {onCall, HttpsError} from 'firebase-functions/v2/https';
import {defineSecret} from 'firebase-functions/params';
import {setGlobalOptions} from 'firebase-functions/v2';
import * as logger from 'firebase-functions/logger';
import * as dotenv from 'dotenv';
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

// Load environment variables in local / emulator environments.
// On deployed Cloud Functions, environment variables should be configured
// via the platform and will already be available in process.env.
dotenv.config();

// Global options for cost control
setGlobalOptions({
  maxInstances: 10,
  region: 'europe-west1',
});

// Define secret for Gemini API key
// To set: firebase functions:secrets:set GEMINI_API_KEY
const geminiApiKeySecret = defineSecret('GEMINI_API_KEY');

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

    const {goalTitle, category} = request.data;

    if (!goalTitle || !category) {
      throw new HttpsError(
        'invalid-argument',
        'goalTitle and category are required'
      );
    }

    try {
      const geminiClient = getGeminiClient(geminiApiKeySecret.value());
      const result = await optimizeGoal(request.data, geminiClient);

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

    const {goalTitle, category} = request.data;

    if (!goalTitle || !category) {
      throw new HttpsError(
        'invalid-argument',
        'goalTitle and category are required'
      );
    }

    try {
      const geminiClient = getGeminiClient(geminiApiKeySecret.value());
      const result = await suggestSubGoals(request.data, geminiClient);

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
