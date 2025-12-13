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

  if (diffDays <= 45) {
    // roughly up to 1.5 months → use weeks
    const phrase =
      diffWeeks === 1 ? 'over 1 week' : `over ${diffWeeks} weeks`;
    return {phrase, weeks: diffWeeks};
  } else {
    const approxMonths = Math.max(1, Math.round(diffDays / 30));
    const phrase =
      approxMonths === 1 ? 'over 1 month' : `over ${approxMonths} months`;
    return {phrase, weeks: diffWeeks};
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

  const prompt = `You are a personal development coach with expertise in goal setting and achievement.

Task:
- Convert the given goal into a full SMART goal (Specific, Measurable, Achievable, Relevant, Time-bound).
- Generate 3–5 high-quality, realistic, and actionable sub-goals that DIRECTLY contribute to achieving the main goal.
- Each sub-goal must be relevant to the goal, achievable within the timeframe, and form a logical progression.

Input:
- Goal: "${goalTitle}"
- Category: ${category}
- Motivation: ${motivation || 'Not specified'}
- Target deadline information: ${timeConstraintText}

Language & output rules:
- ${getLanguageInstruction(locale)}
- Respond with VALID JSON ONLY. No markdown, no code blocks, no comments, no extra text.
- For health / exercise goals, give safe and reasonable suggestions. Do NOT give medical advice.
- When you need a date, use ISO format (YYYY-MM-DD) or null.

JSON SCHEMA (use exactly these fields):
{
  "optimizedTitle": "Short, clear and motivating goal name in ${outputLang} (max 5–8 words)",
  "subGoals": [
    {
      "id": "unique-id",
      "title": "Specific, measurable, and actionable sub-goal in ${outputLang} that directly contributes to the main goal. Must be realistic and achievable.",
      "isCompleted": false,
      "dueDate": "YYYY-MM-DD or null (should be distributed across the timeframe, with earlier sub-goals having earlier dates)"
    }
  ],
  "explanation": "The full SMART version of the goal, in ${outputLang}. 1–2 clear sentences that can be used in the goal description field."
}

CRITICAL TIME CONSTRAINT RULES:
${targetDate ? `- The user selected a completion date: ${new Date(targetDate).toISOString().slice(0, 10)}
- You MUST create a plan that fits EXACTLY within the timeframe until this date
- DO NOT create plans longer than the selected timeframe (e.g., if user selected 1 month, do NOT create a 12-week plan)
- All sub-goal dueDate values MUST be on or before ${new Date(targetDate).toISOString().slice(0, 10)}
- When mentioning duration in the explanation, use EXACTLY: "${durationPhrase}" - never use different durations` : '- No deadline provided, choose a realistic timeframe'}

SUB-GOAL QUALITY REQUIREMENTS (CRITICAL):
- Each sub-goal MUST be directly relevant to achieving the main goal "${goalTitle}"
- Sub-goals must be REALISTIC and ACHIEVABLE within the given timeframe
- Each sub-goal should be SPECIFIC and MEASURABLE (avoid vague tasks like "work on it" or "try harder")
- Sub-goals should form a LOGICAL STEP-BY-STEP ROADMAP that builds upon each other
- Consider the user's motivation: "${motivation || 'Not specified'}" - sub-goals should align with why the user wants this goal
- Consider the category "${category}" - sub-goals should be appropriate for this category
- Sub-goals should be ACTIONABLE (user should know exactly what to do)
- Avoid generic or overly ambitious sub-goals - focus on practical, concrete steps
- Each sub-goal should be meaningful progress toward the main goal, not just busywork
- Distribute sub-goals evenly across the available timeframe (don't cram everything at the end)

OTHER IMPORTANT RULES:
- "optimizedTitle" must always be a SHORT name; ideally 3–4 words, maximum 5. Leave time, amount and measurability details to the explanation field.
- "explanation" contains the SMART details of the goal and can be a longer sentence.
- Generate between 3 and 5 sub-goals.
- All text output (optimizedTitle, sub-goal titles, explanation) MUST be in ${outputLang}.
- Return ONLY parseable JSON that exactly follows the schema above.`;

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
