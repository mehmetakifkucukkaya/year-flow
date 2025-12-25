/**
 * Goal Optimization using AI
 * Converts user goals to SMART format and suggests sub-goals
 */

import * as logger from 'firebase-functions/logger';
import {
  OptimizeGoalRequest,
  OptimizeGoalResponse,
  SubGoal,
} from '../types/ai-types';
import {GeminiClient} from './gemini-client';
import {cleanJsonResponse} from './json-utils';
import {getLanguageInstruction} from './locale-utils';

function calculateDurationPhrase(
  targetDate: string,
  locale: string
): {
  phrase: string;
  weeks: number;
} {
  const now = new Date();
  const target = new Date(targetDate);
  const diffMs = target.getTime() - now.getTime();
  const diffDays = Math.max(1, Math.round(diffMs / (1000 * 60 * 60 * 24)));
  const diffWeeks = Math.max(1, Math.round(diffDays / 7));

  const isTurkish = locale === 'tr';

  if (diffDays <= 45) {
    // roughly up to 1.5 months → use weeks
    if (isTurkish) {
      const phrase =
        diffWeeks === 1 ? '1 hafta içinde' : `${diffWeeks} hafta içinde`;
      return {phrase, weeks: diffWeeks};
    } else {
      const phrase =
        diffWeeks === 1 ? 'over 1 week' : `over ${diffWeeks} weeks`;
      return {phrase, weeks: diffWeeks};
    }
  } else {
    const approxMonths = Math.max(1, Math.round(diffDays / 30));
    if (isTurkish) {
      const phrase =
        approxMonths === 1 ? '1 ay içinde' : `${approxMonths} ay içinde`;
      return {phrase, weeks: diffWeeks};
    } else {
      const phrase =
        approxMonths === 1 ? 'over 1 month' : `over ${approxMonths} months`;
      return {phrase, weeks: diffWeeks};
    }
  }
}

export async function optimizeGoal(
  request: OptimizeGoalRequest,
  geminiClient: GeminiClient
): Promise<OptimizeGoalResponse> {
  const {goalTitle, category, motivation, targetDate, locale = 'tr'} = request;
  const outputLang = locale === 'tr' ? 'Turkish' : 'English';

  let timeConstraintText =
    'No explicit deadline was provided. Choose a realistic timeframe (for example 8–12 weeks) and keep it consistent across the SMART goal and all sub-goals.';
  let durationPhrase: string | undefined;

  if (targetDate) {
    try {
      const {phrase, weeks} = calculateDurationPhrase(targetDate, locale);
      durationPhrase = phrase;
      const isoDate = new Date(targetDate).toISOString().slice(0, 10);
      const now = new Date();
      const target = new Date(targetDate);
      const diffDays = Math.max(
        1,
        Math.round((target.getTime() - now.getTime()) / (1000 * 60 * 60 * 24))
      );
      const diffMonths = Math.round(diffDays / 30);

      timeConstraintText = `CRITICAL TIME CONSTRAINT: The user has set a completion deadline of ${isoDate}. This is exactly ${diffDays} days (approximately ${weeks} weeks${diffMonths > 0 ? ` or ${diffMonths} month${diffMonths > 1 ? 's' : ''}` : ''}) from today.

YOU MUST:
- Create a plan that fits EXACTLY within this ${diffDays}-day timeframe (from today until ${isoDate})
- All sub-goals must be scheduled to complete BEFORE or ON ${isoDate}
- The explanation must mention the duration using "${phrase}" - DO NOT use different durations like "12 weeks" or "3 months" if the user selected a different timeframe
- If the user selected 1 month, do NOT create a 12-week plan. Respect the exact timeframe provided.`;
    } catch (e) {
      logger.error('Failed to compute time constraint from targetDate', e);
    }
  }

  const prompt = `You are a practical personal development coach who understands REAL LIFE - including work commitments, family responsibilities, fatigue, and unexpected events. You create realistic plans that actual humans can follow.

Task:
- Convert the given goal into a SMART goal (Specific, Measurable, Achievable, Relevant, Time-bound) - but keep it grounded in reality.
- Generate sub-goals that are genuinely doable for someone with a busy life.
- Account for: work/school schedule, commuting, household chores, social obligations, rest days, and the fact that motivation fluctuates.

Input:
- Goal: "${goalTitle}"
- Category: ${category}
- Motivation: ${motivation || 'Not specified'}
- Target deadline information: ${timeConstraintText}

Language & output rules:
- ${getLanguageInstruction(locale)}
- Respond with VALID JSON ONLY. No markdown, no code blocks, no comments, no extra text.
- For health / exercise goals, give safe and conservative suggestions. Start EASY. Do NOT give medical advice.
- When you need a date, use ISO format (YYYY-MM-DD) or null.

REALITY CHECK - Before creating sub-goals, consider:
- Most people have 2-4 hours MAX per day for personal goals (often less on weekdays)
- Weekends are often filled with errands, social events, and rest
- Motivation is high at the start, then drops after 2-3 weeks
- Life happens: sick days, unexpected work, family emergencies
- Building habits takes 4-8 weeks of CONSISTENT effort, not intensity
- A realistic plan has buffer time and flexibility

SUB-GOAL QUANTITY (based on timeframe):
- 1-4 weeks: 2-3 sub-goals MAX (focus on building the foundation)
- 1-2 months: 3-4 sub-goals
- 3+ months: 4-5 sub-goals (no more than 5 - more than this becomes overwhelming)

JSON SCHEMA (use exactly these fields):
{
  "optimizedTitle": "Short, clear goal name in ${outputLang} (max 5 words)",
  "subGoals": [
    {
      "id": "unique-id",
      "title": "Specific, measurable sub-goal in ${outputLang} that takes into account real-life constraints. Start small and build momentum.",
      "isCompleted": false,
      "dueDate": "YYYY-MM-DD or null (distribute realistically - account for slower periods, not even spacing)"
    }
  ],
  "explanation": "The SMART version of the goal in ${outputLang}. Be honest about what it takes. 2-3 sentences including estimated weekly time commitment."
}

CRITICAL TIME CONSTRAINT RULES:
${targetDate ? `- The user selected a completion date: ${new Date(targetDate).toISOString().slice(0, 10)}
- You MUST create a plan that fits EXACTLY within this timeframe
- If the timeframe is SHORT (less than 6 weeks), propose FEWER sub-goals (2-3 max)
- If the timeframe is VERY SHORT (less than 3 weeks), propose 1-2 foundational sub-goals only
- All sub-goal dueDate values MUST be on or before ${new Date(targetDate).toISOString().slice(0, 10)}
- When mentioning duration, use EXACTLY: "${durationPhrase}"` : '- No deadline provided - choose a realistic timeframe (minimum 6-8 weeks for meaningful change)'}

SUB-GOAL QUALITY REQUIREMENTS (REALISTIC):
- Start SMALLER than you think - the biggest mistake is overestimating available time/energy
- First sub-goal should be the EASIEST - build momentum with a quick win
- Each sub-goal should take into account that this is NOT the user's full-time job
- Be SPECIFIC about what "done" looks like (avoid vague outcomes)
- Sub-goals should build on each other progressively
- Include TIME ESTIMATES in the explanation so users understand the commitment
- Consider the user's motivation: "${motivation || 'Not specified'}" - align sub-goals with this WHY
- Match sub-goals to the category "${category}" - use category-appropriate strategies
- Make sub-goals FLEXIBLE - allow for adjustment when life gets in the way
- Focus on CONSISTENCY over intensity - 20 minutes daily beats 3 hours once a week

OTHER IMPORTANT RULES:
- "optimizedTitle" must be SHORT (3-5 words max) - keep it simple and clear
- "explanation" should be honest about the time commitment required
- Generate 2-5 sub-goals based on timeframe (fewer for shorter timeframes)
- All text output MUST be in ${outputLang}
- Return ONLY valid JSON matching the schema above`;

  try {
    const response = await geminiClient.generateStructuredText(prompt, 2000);

    // Parse JSON response
    let parsed: any;
    try {
      const cleanedResponse = cleanJsonResponse(response);
      parsed = JSON.parse(cleanedResponse);
    } catch (parseError) {
      logger.error('Failed to parse Gemini response:', response);
      throw new Error('Invalid JSON response from AI');
    }

    // Validate and transform response
    if (!parsed.optimizedTitle || !parsed.subGoals || !parsed.explanation) {
      throw new Error('Invalid response structure from AI');
    }

    // Validate sub-goals quality
    if (!Array.isArray(parsed.subGoals) || parsed.subGoals.length < 3) {
      throw new Error('AI must generate at least 3 sub-goals');
    }

    // Validate and fix sub-goal dueDates to ensure they don't exceed targetDate
    const targetDateObj = targetDate ? new Date(targetDate) : null;

    const subGoals: SubGoal[] = parsed.subGoals
      .filter((sg: any) => {
        // Filter out empty or too short sub-goals
        const title = String(sg.title || '').trim();
        if (title.length < 5) {
          logger.warn(
            `Filtering out sub-goal with too short title: "${title}"`
          );
          return false;
        }
        return true;
      })
      .map((sg: any, index: number) => {
        let dueDate = sg.dueDate || undefined;

        // If targetDate is set, ensure sub-goal dueDate doesn't exceed it
        if (targetDateObj && dueDate) {
          try {
            const dueDateObj = new Date(dueDate);
            // If sub-goal dueDate is after targetDate, set it to targetDate
            if (dueDateObj > targetDateObj) {
              logger.warn(
                `Sub-goal ${index + 1} dueDate (${dueDate}) exceeds targetDate (${targetDateObj.toISOString().slice(0, 10)}), adjusting to targetDate`
              );
              dueDate = targetDateObj.toISOString().slice(0, 10);
            }
          } catch (e) {
            logger.warn(
              `Invalid dueDate format for sub-goal ${index + 1}: ${dueDate}`
            );
            dueDate = undefined;
          }
        }

        return {
          id: sg.id || `subgoal-${index + 1}`,
          title: sg.title,
          isCompleted: sg.isCompleted || false,
          dueDate: dueDate,
        };
      });

    return {
      optimizedTitle: parsed.optimizedTitle,
      subGoals,
      explanation: parsed.explanation,
    };
  } catch (error: any) {
    logger.error('Error optimizing goal:', error);
    throw new Error(`Goal optimization failed: ${error.message}`);
  }
}
