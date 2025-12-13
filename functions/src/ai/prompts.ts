import {Goal, CheckIn} from '../types/ai-types';
import {
  getLanguageInstruction,
  getLocalizedStrings,
} from './locale-utils';

export function buildSuggestionsPrompt(
  goals: Goal[],
  checkIns: CheckIn[],
  locale: string = 'tr'
): string {
  const l = getLocalizedStrings(locale);
  const outputLang = locale === 'tr' ? 'Turkish' : 'English';

  const goalsSummary = goals
    .map(
      (g) =>
        `- ${g.title} (${g.category}): ${g.progress}% progress, ${
          g.isArchived ? 'completed' : 'active'
        }`
    )
    .join('\n');

  const checkInsSummary =
    checkIns.length > 0
      ? `Total ${checkIns.length} check-ins recorded.`
      : 'No check-ins recorded yet.';

  return `You are an experienced personal development coach.

Task:
- Based on the user's goals and check-in history, provide short, focused and actionable suggestions.

Data:
User's goals:
${goalsSummary}

Check-in summary:
${checkInsSummary}

Writing rules:
- ${getLanguageInstruction(locale)}
- Tone: Warm, encouraging and professional.
- Format: Use Markdown, with at most 2 heading levels (#, ##) and numbered lists where helpful.
- Length: Around 150–220 words in total.

Content structure:
1. Briefly evaluate current progress (highlight strengths).
2. Give improvement suggestions (breaking goals into smaller steps, routines, time management, etc.).
3. Suggest 1–2 new goal ideas tailored to the user (concrete, not too generic).
4. Write a 3–4 item list of practical tips to maintain motivation in the long term.

Avoid generic statements. Use categories and progress percentages from the data to make the suggestions as personal and concrete as possible.

IMPORTANT: Your entire response must be written in ${outputLang}.`;
}
