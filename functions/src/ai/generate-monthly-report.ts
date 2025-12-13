/**
 * Generate Monthly Report using AI
 * Analysis of user's month-long journey
 */

import * as logger from 'firebase-functions/logger';
import {
  CheckIn,
  GenerateMonthlyReportRequest,
  GenerateMonthlyReportResponse,
  Goal,
} from '../types/ai-types';
import {GeminiClient} from './gemini-client';
import {getMonthNames, getDateLocale, getLanguageInstruction} from './locale-utils';

interface MonthlyAnalytics {
  completedGoals: Goal[];
  activeGoals: Goal[];
  averageProgress: number;
  goalsByCategory: Record<string, number>;
  checkInsByWeek: Record<number, number>;
  totalGoals: number;
  totalCheckIns: number;
  averageCheckInScore: number;
}

export async function generateMonthlyReport(
  request: GenerateMonthlyReportRequest,
  geminiClient: GeminiClient
): Promise<GenerateMonthlyReportResponse> {
  const {year, month, goals, checkIns, locale = 'tr'} = request;

  const analytics = calculateMonthlyAnalytics(goals, checkIns);
  const prompt = buildMonthlyReportPrompt(
    year,
    month,
    analytics,
    goals,
    checkIns,
    locale
  );

  try {
    const content = await geminiClient.generateText(prompt, 3500);

    return {
      content: content.trim(),
    };
  } catch (error: any) {
    logger.error('Error generating monthly report:', error);
    throw new Error(`Monthly report generation failed: ${error.message}`);
  }
}

function calculateMonthlyAnalytics(
  goals: Goal[],
  checkIns: CheckIn[]
): MonthlyAnalytics {
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
  const checkInsByWeek = groupCheckInsByWeek(checkIns);
  const averageCheckInScore =
    checkIns.length > 0
      ? checkIns.reduce((sum, ci) => sum + ci.score, 0) / checkIns.length
      : 0;

  return {
    completedGoals,
    activeGoals,
    averageProgress,
    goalsByCategory,
    checkInsByWeek,
    totalGoals: goals.length,
    totalCheckIns: checkIns.length,
    averageCheckInScore,
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

function groupCheckInsByWeek(checkIns: CheckIn[]): Record<number, number> {
  return checkIns.reduce(
    (acc, ci) => {
      const date = new Date(ci.createdAt);
      // Calculate week of month (1-4 or 5)
      const firstDay = new Date(date.getFullYear(), date.getMonth(), 1);
      const dayOfMonth = date.getDate();
      const week = Math.ceil((dayOfMonth + firstDay.getDay()) / 7);
      acc[week] = (acc[week] || 0) + 1;
      return acc;
    },
    {} as Record<number, number>
  );
}

function buildMonthlyReportPrompt(
  year: number,
  month: number,
  analytics: MonthlyAnalytics,
  goals: Goal[],
  checkIns: CheckIn[],
  locale: string
): string {
  const outputLang = locale === 'tr' ? 'Turkish' : 'English';
  const monthNames = getMonthNames('en'); // Always use English month names in prompt
  const dateLocale = getDateLocale(locale);

  const {
    totalGoals,
    completedGoals,
    activeGoals,
    averageProgress,
    goalsByCategory,
    totalCheckIns,
    checkInsByWeek,
    averageCheckInScore,
  } = analytics;

  const monthName = monthNames[month - 1];

  return `You are an experienced personal development analyst and coach. Your task is to analyze the ${monthName} ${year} data and write a **concise, clear, and easy-to-read** monthly report about the user's personal development journey.

SUMMARY DATA:
- Month: ${monthName} ${year}
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
- Average check-in score: ${averageCheckInScore.toFixed(1)}/10
- Weekly distribution: ${Object.entries(checkInsByWeek)
  .map(([week, count]) => `Week ${week}: ${count} check-in${count > 1 ? 's' : ''}`)
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

Last 15 check-in notes:
${
  checkIns.length > 0
    ? checkIns
        .slice(-15)
        .map(
          (ci) =>
            `- ${new Date(ci.createdAt).toLocaleDateString('en-US')}: ${ci.note || 'No note'} (Score: ${ci.score}/10, Progress: ${ci.progressDelta > 0 ? '+' : ''}${ci.progressDelta}%)`
        )
        .join('\n')
    : 'No check-ins this month.'
}

Writing rules:
- ${getLanguageInstruction(locale)}
- Tone: Warm, friendly and supportive, but not overly emotional.
- Format: Use Markdown headings (#, ##, ###).
- Length: Maximum 250–300 words. Avoid unnecessary repetition and long sentences, write clearly and directly.

REPORT SECTIONS (write in this order, with a maximum of 2–3 sentences per section):

# ${monthName} ${year} Monthly Report

## 1. Month Overview
Summarize the overall tone of the month in 2–3 sentences max; note main themes and significant changes. Acknowledge strengths and efforts.

## 2. Goal Progress
Analyze progress by category in 2–3 sentences max; celebrate completed goals (especially those explicitly marked as completed - isCompleted=true) and honestly but constructively note challenging areas.

## 3. Emotional and Mental Journey
Summarize motivation and emotional fluctuations, difficult periods, and recovery moments in 2–3 sentences max; highlight the user's resilience.

## 4. Best Moments and Milestones of the Month
Describe standout moments, firsts, and small but meaningful victories throughout the month in 2–3 sentences max.

## 5. Lessons Learned
Write 3–4 clear lessons and insights from this month as a short bullet list.

## 6. Recommendations for Next Month
Provide 2–3 concrete focus areas and actionable recommendations for the coming month in 2–3 sentences max.

IMPORTANT: Your entire response must be written in ${outputLang}. Address the reader directly using second person ("you" / "sen").`;
}
