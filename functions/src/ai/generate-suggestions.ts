/**
 * Generate AI Suggestions based on user goals and progress
 */

import {GeminiClient} from './gemini-client';
import {
  GenerateSuggestionsRequest,
  GenerateSuggestionsResponse,
} from '../types/ai-types';
import * as logger from 'firebase-functions/logger';
import {buildSuggestionsPrompt} from './prompts';

export async function generateSuggestions(
  request: GenerateSuggestionsRequest,
  geminiClient: GeminiClient
): Promise<GenerateSuggestionsResponse> {
  const {goals, checkIns, locale = 'tr'} = request;

  const prompt = buildSuggestionsPrompt(goals, checkIns, locale);

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

