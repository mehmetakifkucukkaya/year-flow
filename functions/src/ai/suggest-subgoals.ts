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

  const prompt = `You are a personal development and productivity coach.

Task:
- For the given goal, suggest 3–6 practical and clear sub-goals.

Input:
- Goal title: "${goalTitle}"
- Category: ${category}
- Goal description / context: ${description || 'Not specified'}

Language & safety rules:
- ${getLanguageInstruction(locale)}
- Respond with VALID JSON ONLY. No markdown, no explanations, no comments, no extra text.
- For health / exercise goals, give safe and reasonable suggestions, without medical advice.
- Sub-goals must be:
  - Short, clear and doable in a single step.
  - Concrete enough to make the user feel "I can do this today".

JSON SCHEMA (use exactly this structure):
{
  "subGoals": [
    {
      "title": "Clear and actionable sub-goal in ${outputLang} (single sentence)"
    }
  ]
}

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
