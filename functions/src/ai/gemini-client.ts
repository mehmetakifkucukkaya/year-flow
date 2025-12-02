/**
 * Gemini API Client Wrapper
 */

import {GoogleGenerativeAI} from '@google/generative-ai';
import * as logger from 'firebase-functions/logger';

export class GeminiClient {
  private genAI: GoogleGenerativeAI;
  private model: any;

  constructor(apiKey: string) {
    if (!apiKey) {
      throw new Error('GEMINI_API_KEY is not set');
    }
    this.genAI = new GoogleGenerativeAI(apiKey);
    this.model = this.genAI.getGenerativeModel({model: 'gemini-2.0-flash-exp'});
  }

  /**
   * Generate text using Gemini API
   */
  async generateText(prompt: string, maxTokens: number = 2000): Promise<string> {
    try {
      const result = await this.model.generateContent(prompt);
      const response = await result.response;
      const text = response.text();

      if (!text || text.trim().length === 0) {
        throw new Error('Empty response from Gemini API');
      }

      return text.trim();
    } catch (error: any) {
      logger.error('Gemini API error:', error);
      throw new Error(`Gemini API error: ${error.message || 'Unknown error'}`);
    }
  }

  /**
   * Generate structured JSON response
   */
  async generateStructuredText(
    prompt: string,
    maxTokens: number = 2000
  ): Promise<string> {
    try {
      const generationConfig = {
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: maxTokens,
      };

      const result = await this.model.generateContent({
        contents: [{role: 'user', parts: [{text: prompt}]}],
        generationConfig,
      });

      const response = await result.response;
      const text = response.text();

      if (!text || text.trim().length === 0) {
        throw new Error('Empty response from Gemini API');
      }

      return text.trim();
    } catch (error: any) {
      logger.error('Gemini API error:', error);
      throw new Error(`Gemini API error: ${error.message || 'Unknown error'}`);
    }
  }
}

