/**
 * Lightweight Sub-goal Suggestions using AI
 * Generates 3–6 actionable sub-goal ideas for a given goal.
 */

import * as logger from 'firebase-functions/logger';
import {
  SuggestSubGoalsRequest,
  SuggestSubGoalsResponse,
} from '../types/ai-types';
import {GeminiClient} from './gemini-client';
import {cleanJsonResponse} from './json-utils';
import {getLanguageInstruction} from './locale-utils';

export async function suggestSubGoals(
  request: SuggestSubGoalsRequest,
  geminiClient: GeminiClient
): Promise<SuggestSubGoalsResponse> {
  const {goalTitle, description, category, locale = 'tr'} = request;
  const outputLang = locale === 'tr' ? 'Turkish' : 'English';

  const prompt = `You are a practical personal development coach who understands REAL LIFE constraints - work, family, fatigue, and limited time. You suggest sub-goals that actual humans can realistically accomplish.

Task:
- For the given goal, suggest 3-6 practical sub-goals that fit into a busy person's schedule.

Input:
- Goal title: "${goalTitle}"
- Category: ${category}
- Goal description / context: ${description || 'Not specified'}

REALITY CHECK - Keep these in mind:
- Most people have 30-90 minutes MAX per day for personal development (often less)
- Weekends are often occupied with errands, social events, and rest
- Sub-goals should be things someone can do AFTER a workday when tired
- The goal is CONSISTENCY, not intensity - small steps compound over time
- Each sub-goal should feel achievable even on a "bad day"

Language & safety rules:
- ${getLanguageInstruction(locale)}
- Respond with VALID JSON ONLY. No markdown, no explanations, no comments, no extra text.
- For health / exercise goals, start VERY CONSERVATIVE. It's better to start too easy than too hard. Do NOT give medical advice.
- Sub-goals must be:
  - Short enough to complete in 15-60 minutes (depending on category)
  - Clear enough that the user knows exactly what to do
  - Realistic for someone with a full schedule
  - Designed to build momentum, not overwhelm

JSON SCHEMA (use exactly this structure):
{
  "subGoals": [
    {
      "title": "Clear, actionable sub-goal in ${outputLang} that fits into a busy schedule. Be specific about the action (single sentence)"
    }
  ]
}

QUALITY GUIDELINES:
- Start with the EASIEST sub-goal - quick wins build confidence
- Include sub-goals that can be done in different contexts (at home, commuting, etc.)
- Each sub-goal should be small enough to complete even when motivation is low
- Focus on SPECIFIC actions rather than vague intentions
- Consider the category "${category}" - match sub-goals to what's realistic for that domain
- Avoid suggesting dramatic lifestyle changes - focus on incremental improvements

IMPORTANT:
- Generate between 3 and 6 sub-goals.
- All sub-goal titles must be written in ${outputLang}.
- Return ONLY parseable JSON that exactly follows the schema above.`;

  try {
    const response = await geminiClient.generateStructuredText(prompt, 1200);

    let parsed: any;
    try {
      const cleaned = cleanJsonResponse(response);
      parsed = JSON.parse(cleaned);
    } catch (parseError) {
      logger.error('Failed to parse Gemini response for suggestSubGoals:', {
        raw: response,
        error: parseError,
      });
      throw new Error('Invalid JSON response from AI');
    }

    if (!parsed.subGoals || !Array.isArray(parsed.subGoals)) {
      throw new Error('Invalid response structure from AI (missing subGoals)');
    }

    const subGoals = parsed.subGoals
      .map((sg: any) => ({
        title: String(sg.title || '').trim(),
      }))
      .filter((sg: {title: string}) => sg.title.length > 0);

    return {subGoals};
  } catch (error: any) {
    logger.error('Error in suggestSubGoals:', error);
    throw new Error(`Suggest sub-goals failed: ${error.message}`);
  }
}
