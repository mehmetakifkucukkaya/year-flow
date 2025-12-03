/**
 * Generate Yearly Report using AI
 * Comprehensive analysis of user's year-long journey
 */

import {GeminiClient} from './gemini-client';
import {
  GenerateYearlyReportRequest,
  GenerateYearlyReportResponse,
} from '../types/ai-types';
import * as logger from 'firebase-functions/logger';

export async function generateYearlyReport(
  request: GenerateYearlyReportRequest,
  geminiClient: GeminiClient
): Promise<GenerateYearlyReportResponse> {
  const {year, goals, checkIns} = request;

  // Prepare comprehensive data summary
  const completedGoals = goals.filter((g) => g.progress >= 100);
  const activeGoals = goals.filter((g) => !g.isArchived && g.progress < 100);
  const averageProgress =
    goals.length > 0
      ? goals.reduce((sum, g) => sum + g.progress, 0) / goals.length
      : 0;

  const goalsByCategory = goals.reduce((acc, g) => {
    acc[g.category] = (acc[g.category] || 0) + 1;
    return acc;
  }, {} as Record<string, number>);

  const checkInsByMonth = checkIns.reduce((acc, ci) => {
    const month = new Date(ci.createdAt).getMonth() + 1;
    acc[month] = (acc[month] || 0) + 1;
    return acc;
  }, {} as Record<number, number>);

  const prompt = `You are an experienced Turkish-speaking personal development analyst and coach. Your task is to read the data for the year ${year} and write a meaningful, inspiring and balanced yearly report about the user's personal growth journey.

SUMMARY DATA (already in Turkish):
- Year: ${year}
- Total goals: ${goals.length}
- Completed goals: ${completedGoals.length}
- Active goals: ${activeGoals.length}
- Average progress: %${averageProgress.toFixed(1)}

Goals by category:
${Object.entries(goalsByCategory)
  .map(([cat, count]) => `- ${cat}: ${count} hedef`)
  .join('\n')}

Check-in summary:
- Total check-ins: ${checkIns.length}
- Monthly distribution: ${Object.entries(checkInsByMonth)
  .map(([month, count]) => `${month}. ay: ${count} check-in`)
  .join(', ')}

Goal details:
${goals
  .map(
    (g) =>
      `- "${g.title}" (${g.category}): %${g.progress} ilerleme${
        g.description
          ? `, Açıklama: ${g.description}`
          : g.motivation
          ? `, Motivasyon: ${g.motivation}`
          : ''
      }`
  )
  .join('\n')}

Last 10 check-in notes:
${checkIns
  .slice(-10)
  .map((ci) => `- ${ci.note || 'Not yok'} (Puan: ${ci.score}/10)`)
  .join('\n')}

Writing rules:
- OUTPUT LANGUAGE MUST BE TURKISH.
- Tone: Warm, sincere and supportive, but not overly sentimental.
- Format: Use Markdown headings (#, ##, ###).
- Length: Around 700–1,000 words.

REPORT SECTIONS (write in this order, all in Turkish):

# ${year} Yıllık Kişisel Gelişim Raporun

## 1. Yılın Genel Özeti
Summarise the overall tone of the year, key themes and important changes. Acknowledge strengths and effort.

## 2. Hedeflerdeki İlerleme
Analyse progress by category; discuss completed goals, challenging areas and unfinished goals in an honest but constructive way.

## 3. Duygusal ve Mental Yolculuk
Using check-in data, describe motivation swings, difficult periods and recovery moments. Highlight the user's resilience.

## 4. En İyi Anlar ve Kilometre Taşları
Talk about highlights, firsts and small but meaningful victories throughout the year.

## 5. Öğrenilen Dersler
Write 4–6 clear lessons and insights that can be taken from this year, as a bullet list in Turkish.

## 6. ${year + 1} Yılı İçin Öneriler
Give 3–5 concrete focus areas, new goal ideas and actionable suggestions for the next year, in Turkish.

## 7. Kendine Mektup
Write a short, motivating letter in Turkish that helps the user appreciate their own effort, in a compassionate yet realistic tone.

Throughout the text, address the reader directly using the Turkish second person singular ("sen").`;

  try {
    const content = await geminiClient.generateText(prompt, 4000);

    return {
      content: content.trim(),
    };
  } catch (error: any) {
    logger.error('Error generating yearly report:', error);
    throw new Error(`Yearly report generation failed: ${error.message}`);
  }
}

