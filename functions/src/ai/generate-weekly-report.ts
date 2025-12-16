/**
 * Generate Weekly Report using AI
 * Analysis of user's week-long journey
 */

import * as logger from 'firebase-functions/logger';
import {
  CheckIn,
  GenerateWeeklyReportRequest,
  GenerateWeeklyReportResponse,
  Goal,
} from '../types/ai-types';
import {GeminiClient} from './gemini-client';
import {getDayNames, getDateLocale, getLanguageInstruction} from './locale-utils';

interface WeeklyAnalytics {
  completedGoals: Goal[];
  activeGoals: Goal[];
  averageProgress: number;
  goalsByCategory: Record<string, number>;
  checkInsByDay: Record<number, number>;
  totalGoals: number;
  totalCheckIns: number;
  averageCheckInScore: number;
}

export async function generateWeeklyReport(
  request: GenerateWeeklyReportRequest,
  geminiClient: GeminiClient
): Promise<GenerateWeeklyReportResponse> {
  const {weekStart, weekEnd, goals, checkIns, locale = 'tr'} = request;

  const analytics = calculateWeeklyAnalytics(goals, checkIns);
  const prompt = buildWeeklyReportPrompt(
    weekStart,
    weekEnd,
    analytics,
    goals,
    checkIns,
    locale
  );

  try {
    const content = await geminiClient.generateText(prompt, 3000);

    return {
      content: content.trim(),
    };
  } catch (error: any) {
    logger.error('Error generating weekly report:', error);
    throw new Error(`Weekly report generation failed: ${error.message}`);
  }
}

function calculateWeeklyAnalytics(
  goals: Goal[],
  checkIns: CheckIn[]
): WeeklyAnalytics {
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
  const checkInsByDay = groupCheckInsByDay(checkIns);
  const averageCheckInScore =
    checkIns.length > 0
      ? checkIns.reduce((sum, ci) => sum + ci.score, 0) / checkIns.length
      : 0;

  return {
    completedGoals,
    activeGoals,
    averageProgress,
    goalsByCategory,
    checkInsByDay,
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

function groupCheckInsByDay(checkIns: CheckIn[]): Record<number, number> {
  return checkIns.reduce(
    (acc, ci) => {
      const day = new Date(ci.createdAt).getDay(); // 0 = Sunday, 1 = Monday, etc.
      acc[day] = (acc[day] || 0) + 1;
      return acc;
    },
    {} as Record<number, number>
  );
}

function formatDate(date: Date): string {
  const dayNames = getDayNames('en'); // Always use English day names in prompt
  const day = date.getDate();
  const month = date.getMonth() + 1;
  const year = date.getFullYear();
  const dayName = dayNames[date.getDay()];
  return `${month}/${day}/${year} (${dayName})`;
}

function buildWeeklyReportPrompt(
  weekStart: string,
  weekEnd: string,
  analytics: WeeklyAnalytics,
  goals: Goal[],
  checkIns: CheckIn[],
  locale: string
): string {
  const outputLang = locale === 'tr' ? 'Turkish' : 'English';
  const dayNames = getDayNames('en'); // Always use English day names in prompt
  const dateLocale = getDateLocale(locale);

  const {
    totalGoals,
    completedGoals,
    activeGoals,
    averageProgress,
    goalsByCategory,
    totalCheckIns,
    checkInsByDay,
    averageCheckInScore,
  } = analytics;

  const startDate = formatDate(new Date(weekStart));
  const endDate = formatDate(new Date(weekEnd));

  return `You are an experienced personal development analyst and coach. Your task is to analyze the weekly data from ${startDate} to ${endDate} and write a **concise, clear, and easy-to-read** weekly report about the user's personal development journey.

SUMMARY DATA:
- Week: ${startDate} - ${endDate}
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
- Daily distribution: ${Object.entries(checkInsByDay)
  .map(([day, count]) => `${dayNames[parseInt(day)]}: ${count} check-in${count > 1 ? 's' : ''}`)
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

All check-in notes:
${
  checkIns.length > 0
    ? checkIns
        .map(
          (ci) =>
            `- ${new Date(ci.createdAt).toLocaleDateString(dateLocale)}: ${ci.note || 'No note'} (Score: ${ci.score}/10, Progress: ${ci.progressDelta > 0 ? '+' : ''}${ci.progressDelta}%)`
        )
        .join('\n')
    : 'No check-ins this week.'
}

Writing rules:
- ${getLanguageInstruction(locale)}
- Tone: Warm, friendly and supportive, but not overly emotional.
- Format: Use Markdown headings (#, ##, ###).
- Length: Maximum 200–250 words. Avoid unnecessary repetition and long sentences, write clearly and directly.

REPORT SECTIONS (write in this order, with a maximum of 2–3 sentences per section):

# Weekly Report: ${startDate} - ${endDate}

## 1. Week Overview
Summarize the overall tone of the week in 2–3 sentences max; note main themes and significant changes. Acknowledge strengths and efforts.

## 2. Goal Progress
Analyze progress by category in 2–3 sentences max; celebrate completed goals (especially those explicitly marked as completed - isCompleted=true) and honestly but constructively note challenging areas.

## 3. Challenges & Solutions
Summarize the main challenges during the week and the solutions or strategies developed to address them in 2–3 sentences max.

## 4. AI Recommendations
Provide 2–3 concrete focus areas and actionable recommendations for the coming week in 2–3 sentences max.

IMPORTANT: Your entire response must be written in ${outputLang}. Address the reader directly using second person ("you" / "sen").`;
}
