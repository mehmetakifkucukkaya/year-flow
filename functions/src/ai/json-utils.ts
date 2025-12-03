/**
 * Utility functions for cleaning and parsing JSON responses from AI
 */

export function cleanJsonResponse(response: string): string {
  return response
    .replace(/^```json\s*\n?/, '')
    .replace(/\n?```\s*$/, '')
    .trim();
}

