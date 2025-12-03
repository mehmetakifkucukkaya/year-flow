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
import { GeminiClient } from './gemini-client';
import { cleanJsonResponse } from './json-utils';

function calculateDurationPhrase(targetDate: string): {
  phrase: string;
  weeks: number;
} {
  const now = new Date();
  const target = new Date(targetDate);
  const diffMs = target.getTime() - now.getTime();
  const diffDays = Math.max(
    1,
    Math.round(diffMs / (1000 * 60 * 60 * 24))
  );
  const diffWeeks = Math.max(1, Math.round(diffDays / 7));

  if (diffDays <= 45) {
    // roughly up to 1.5 months → use weeks
    const phrase =
      diffWeeks === 1 ? '1 hafta boyunca' : `${diffWeeks} hafta boyunca`;
    return { phrase, weeks: diffWeeks };
  } else {
    const approxMonths = Math.max(1, Math.round(diffDays / 30));
    const phrase =
      approxMonths === 1 ? '1 ay boyunca' : `${approxMonths} ay boyunca`;
    return { phrase, weeks: diffWeeks };
  }
}

export async function optimizeGoal(
  request: OptimizeGoalRequest,
  geminiClient: GeminiClient
): Promise<OptimizeGoalResponse> {
  const {goalTitle, category, motivation, targetDate} = request;

  let timeConstraintText =
    'No explicit deadline was provided. Choose a realistic timeframe (for example 8–12 weeks) and keep it consistent across the SMART goal and all sub-goals.';
  let durationPhrase: string | undefined;

  if (targetDate) {
    try {
      const {phrase, weeks} = calculateDurationPhrase(targetDate);
      durationPhrase = phrase;
      const isoDate = new Date(targetDate).toISOString().slice(0, 10);
      timeConstraintText = `The user wants to complete this goal by ${isoDate}, which is about ${weeks} weeks from now. The TOTAL duration of the plan MUST correspond to this timeframe. All sub-goals must also be scheduled within this same total timeframe.`;
    } catch (e) {
      logger.error('Failed to compute time constraint from targetDate', e);
    }
  }

  const prompt = `You are a Turkish-speaking personal development coach.

Task:
- Convert the given goal into a full SMART goal (Specific, Measurable, Achievable, Relevant, Time-bound).
- Generate 3–5 clear and actionable sub-goals that help the user reach this goal.

Input:
- Goal: "${goalTitle}"
- Category: ${category}
- Motivation: ${motivation || 'Belirtilmemiş'}
- Target deadline information: ${timeConstraintText}

Language & output rules:
- OUTPUT LANGUAGE MUST BE TURKISH.
- Respond with VALID JSON ONLY. No markdown, no code blocks, no comments, no extra text.
- For health / exercise goals, give safe and reasonable suggestions. Do NOT give medical advice.
- When you need a date, use ISO format (YYYY-MM-DD) or null.

JSON SCHEMA (use exactly these fields):
{
  "optimizedTitle": "Short, clear and motivating goal name in Turkish (max 5–8 words; e.g. 'Düzenli yürüyüş yapmak', 'Düzenli meditasyon alışkanlığı kazanmak')",
  "subGoals": [
    {
      "id": "unique-id",
      "title": "Short, clear and measurable sub-goal in Turkish",
      "isCompleted": false,
      "dueDate": "YYYY-MM-DD or null"
    }
  ],
  "explanation": "The full SMART version of the goal, in Turkish. 1–2 clear sentences that can be used in the goal description field (e.g. 'Önümüzdeki 3 ay boyunca haftada 3 gün, 30 dakika tempolu yürüyüş yaparak genel sağlığımı iyileştirmek.')."
}

IMPORTANT:
- "optimizedTitle" must always be a SHORT name; ideally 3–4 words, maximum 5. Leave time, amount and measurability details to the explanation field.
- "explanation" contains the SMART details of the goal and can be a longer sentence.
- Generate between 3 and 5 sub-goals.
- Sub-goals should form a step-by-step roadmap that works together.
- When you need to mention the TOTAL duration in Turkish, you MUST reuse exactly this phrase (if provided) for the overall period: "${durationPhrase ?? 'belirlenen süre boyunca'}". Do NOT invent a different total duration like "12 hafta", "3 ay" etc.
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

    const subGoals: SubGoal[] = parsed.subGoals.map((sg: any, index: number) => ({
      id: sg.id || `subgoal-${index + 1}`,
      title: sg.title,
      isCompleted: sg.isCompleted || false,
      dueDate: sg.dueDate || undefined,
    }));

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

