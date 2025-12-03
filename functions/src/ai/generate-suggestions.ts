/**
 * Generate AI Suggestions based on user goals and progress
 */

import {GeminiClient} from './gemini-client';
import {
  GenerateSuggestionsRequest,
  GenerateSuggestionsResponse,
} from '../types/ai-types';
import * as logger from 'firebase-functions/logger';

export async function generateSuggestions(
  request: GenerateSuggestionsRequest,
  geminiClient: GeminiClient
): Promise<GenerateSuggestionsResponse> {
  const {goals, checkIns} = request;

  // Prepare data summary for AI
  const goalsSummary = goals
    .map(
      (g) =>
        `- ${g.title} (${g.category}): %${g.progress} ilerleme, ${
          g.isArchived ? 'tamamlanmış' : 'aktif'
        }`
    )
    .join('\n');

  const checkInsSummary = checkIns.length > 0
    ? `Toplam ${checkIns.length} check-in yapılmış.`
    : 'Henüz check-in yapılmamış.';

  const prompt = `You are an experienced personal development coach who communicates in Turkish.

Goal:
- Based on the user's goals and check-in history, provide short, focused and actionable suggestions.

Data (all in Turkish already):
User's goals:
${goalsSummary}

Check-in summary:
${checkInsSummary}

Writing rules:
- OUTPUT LANGUAGE MUST BE TURKISH.
- Tone: Warm, encouraging and professional.
- Format: Use Markdown, with at most 2 heading levels (#, ##) and numbered lists where helpful.
- Length: Around 150–220 words in total.

Content structure:
1. Briefly evaluate current progress (highlight strengths).
2. Give improvement suggestions (breaking goals into smaller steps, routines, time management, etc.).
3. Suggest 1–2 new goal ideas tailored to the user (concrete, not too generic).
4. Write a 3–4 item list of practical tips to maintain motivation in the long term.

Avoid generic statements. Use categories and progress percentages from the data to make the suggestions as personal and concrete as possible.`;

  try {
    const suggestions = await geminiClient.generateText(prompt, 1500);

    return {
      suggestions: suggestions.trim(),
    };
  } catch (error: any) {
    logger.error('Error generating suggestions:', error);
    throw new Error(`Suggestions generation failed: ${error.message}`);
  }
}

