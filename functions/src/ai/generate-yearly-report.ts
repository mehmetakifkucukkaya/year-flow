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

  return `You are a practical personal development analyst who understands that real progress is rarely linear, life happens, and perfection is not a realistic standard. Your task is to analyze the ${year} data and write an honest, balanced, and insightful yearly report.

REALITY CHECK - Remember:
- Incomplete goals don't mean failure - circumstances change, priorities shift, and that's okay
- Low progress percentage doesn't always mean lack of effort - some goals take longer than expected
- Check-in gaps are normal - people get busy, sick, or distracted
- A year with many started but unfinished goals still shows ambition and growth
- Honest reflection is more valuable than false positivity

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
- Tone: Honest, balanced, and constructive. Celebrate genuine wins AND acknowledge real challenges. Avoid toxic positivity.
- Format: Use Markdown headings (#, ##, ###).
- Length: Maximum 300–350 words. Write clearly and directly.

REPORT SECTIONS (write in this order, with a maximum of 2–3 sentences per section):

# ${year} Personal Development Report

## 1. Year Overview
Summarize the year honestly - what was the overall character? Was it a building year, a challenging year, a transitional year? Acknowledge both efforts made and outcomes achieved.

## 2. Goal Progress
Analyze by category. Celebrate completed goals genuinely. For incomplete goals, provide honest context - was the goal too ambitious? Did priorities shift? Was it a timing issue? Be specific about which categories worked and which didn't.

## 3. Emotional and Mental Journey
Reflect on motivation patterns visible in check-ins. Note periods of high engagement and periods of disengagement. Acknowledge that fluctuation is human, not failure.

## 4. Best Moments and Milestones
Highlight specific achievements - completed goals, high check-in scores, progress breakthroughs. Even in a challenging year, there were bright spots.

## 5. Lessons Learned
Write 4–5 clear insights from this year. Include lessons about what worked, what didn't, and what this reveals about the user's patterns and realistic capacity.

## 6. Recommendations for ${year + 1}
Based on the ACTUAL data from ${year}, provide 3–4 realistic recommendations. If the user struggled with many goals, suggest fewer commitments. If check-ins were inconsistent, suggest a more sustainable system. Be honest, not idealistic.

## 7. A Note to Yourself
Write a brief note that balances appreciation for efforts made with honest acknowledgment of where things didn't go as planned. Self-compassion includes honesty, not just encouragement.

IMPORTANT: Your entire response must be written in ${outputLang}. Address the reader directly using second person ("you" / "sen").`;
}
