/**
 * Generate Yearly Report using AI
 * Comprehensive analysis of user's year-long journey
 */

import * as logger from 'firebase-functions/logger';
import {
  CheckIn,
  GenerateYearlyReportRequest,
  GenerateYearlyReportResponse,
  Goal,
} from '../types/ai-types';
import {GeminiClient} from './gemini-client';
import {getLanguageInstruction, getMonthNames} from './locale-utils';

interface YearlyAnalytics {
  completedGoals: Goal[];
  activeGoals: Goal[];
  averageProgress: number;
  goalsByCategory: Record<string, number>;
  checkInsByMonth: Record<number, number>;
  totalGoals: number;
  totalCheckIns: number;
}

export async function generateYearlyReport(
  request: GenerateYearlyReportRequest,
  geminiClient: GeminiClient
): Promise<GenerateYearlyReportResponse> {
  const {year, goals, checkIns, locale = 'tr'} = request;

  const analytics = calculateYearlyAnalytics(goals, checkIns);
  const prompt = buildYearlyReportPrompt(year, analytics, goals, checkIns, locale);

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

function calculateYearlyAnalytics(
  goals: Goal[],
  checkIns: CheckIn[]
): YearlyAnalytics {
  const completedGoals = goals.filter(
    (g) => g.isCompleted || g.progress >= 100
  );
  const activeGoals = goals.filter(
    (g) => !g.isArchived && !g.isCompleted && g.progress < 100
  );
  const averageProgress =
    goals.length > 0
      ? goals.reduce((sum, g) => sum + g.progress, 0) / goals.length
      : 0;
  const goalsByCategory = groupGoalsByCategory(goals);
  const checkInsByMonth = groupCheckInsByMonth(checkIns);

  return {
    completedGoals,
    activeGoals,
    averageProgress,
    goalsByCategory,
    checkInsByMonth,
    totalGoals: goals.length,
    totalCheckIns: checkIns.length,
  };
}

function groupGoalsByCategory(goals: Goal[]): Record<string, number> {
  return goals.reduce(
    (acc, g) => {
      acc[g.category] = (acc[g.category] || 0) + 1;
      return acc;
    },
    {} as Record<string, number>
  );
}

function groupCheckInsByMonth(checkIns: CheckIn[]): Record<number, number> {
  return checkIns.reduce(
    (acc, ci) => {
      const month = new Date(ci.createdAt).getMonth() + 1;
      acc[month] = (acc[month] || 0) + 1;
      return acc;
    },
    {} as Record<number, number>
  );
}

function buildYearlyReportPrompt(
  year: number,
  analytics: YearlyAnalytics,
  goals: Goal[],
  checkIns: CheckIn[],
  locale: string
): string {
  const outputLang = locale === 'tr' ? 'Turkish' : 'English';
  const monthNames = getMonthNames('en'); // Always use English month names in prompt

  const {
    totalGoals,
    completedGoals,
    activeGoals,
    averageProgress,
    goalsByCategory,
    totalCheckIns,
    checkInsByMonth,
  } = analytics;

  return `You are an experienced personal development analyst and coach. Your task is to analyze the ${year} data and write a **concise, clear, and easy-to-read** yearly report about the user's personal development journey.

SUMMARY DATA:
- Year: ${year}
- Total goals: ${totalGoals}
- Completed goals: ${completedGoals.length} (${completedGoals.filter((g: Goal) => g.isCompleted === true).length} explicitly marked as completed)
- Active goals: ${activeGoals.length}
- Average progress: ${averageProgress.toFixed(1)}%

Goals by category:
${Object.entries(goalsByCategory)
  .map(([cat, count]) => `- ${cat}: ${count} goal${count > 1 ? 's' : ''}`)
  .join('\n')}

Check-in summary:
- Total check-ins: ${totalCheckIns}
- Monthly distribution: ${Object.entries(checkInsByMonth)
  .map(([month, count]) => `${monthNames[parseInt(month) - 1]}: ${count} check-in${count > 1 ? 's' : ''}`)
  .join(', ')}

Goal details:
${goals
  .map(
    (g) =>
      `- "${g.title}" (${g.category}): ${g.progress}% progress${g.isCompleted ? ' [COMPLETED]' : ''}${
        g.description
          ? `, Description: ${g.description}`
          : g.motivation
            ? `, Motivation: ${g.motivation}`
            : ''
      }`
  )
  .join('\n')}

Last 10 check-in notes:
${checkIns
  .slice(-10)
  .map((ci) => `- ${ci.note || 'No note'} (Score: ${ci.score}/10)`)
  .join('\n')}

Writing rules:
- ${getLanguageInstruction(locale)}
- Tone: Warm, friendly and supportive, but not overly emotional.
- Format: Use Markdown headings (#, ##, ###).
- Length: Maximum 300–350 words. Avoid unnecessary repetition and long sentences, write clearly and directly.

REPORT SECTIONS (write in this order, with a maximum of 2–3 sentences per section):

# ${year} Personal Development Report

## 1. Year Overview
Summarize the overall tone of the year, main themes, and significant changes in 2–3 sentences max. Acknowledge strengths and efforts shown.

## 2. Goal Progress
Analyze progress by category in 2–3 sentences max; celebrate completed goals (especially those explicitly marked as completed - isCompleted=true), and honestly but constructively note challenging areas and incomplete goals.

## 3. Emotional and Mental Journey
Summarize motivation fluctuations, difficult periods, and recovery moments in 2–3 sentences max; highlight the user's resilience.

## 4. Best Moments and Milestones
Describe standout moments, firsts, and small but meaningful victories throughout the year in 2–3 sentences max.

## 5. Lessons Learned
Write 4–5 clear lessons and insights from this year as a short bullet list.

## 6. Recommendations for ${year + 1}
Provide 3–4 concrete focus areas, new goal ideas, and actionable recommendations for the coming year in 2–3 sentences max.

## 7. A Short Note to Yourself
Write a short note in a compassionate but realistic tone that helps the user appreciate their own efforts.

IMPORTANT: Your entire response must be written in ${outputLang}. Address the reader directly using second person ("you" / "sen").`;
}
