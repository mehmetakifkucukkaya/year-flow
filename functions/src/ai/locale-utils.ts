/**
 * Locale Utilities for AI Prompts
 * Provides language-dependent strings for multilingual AI output
 */

export type SupportedLocale = 'tr' | 'en';

/**
 * Get the full language name for prompts
 */
export function getLanguageName(locale: string): string {
  return locale === 'tr' ? 'Turkish' : 'English';
}

/**
 * Get the language instruction for AI prompts
 */
export function getLanguageInstruction(locale: string): string {
  return locale === 'tr'
    ? 'OUTPUT LANGUAGE MUST BE TURKISH.'
    : 'OUTPUT LANGUAGE MUST BE ENGLISH.';
}

/**
 * Get the coach description based on locale
 */
export function getCoachDescription(locale: string): string {
  return locale === 'tr'
    ? 'Sen deneyimli bir Türkçe konuşan kişisel gelişim koçusun.'
    : 'You are an experienced personal development coach who communicates in English.';
}

/**
 * Get the analyst description based on locale
 */
export function getAnalystDescription(locale: string): string {
  return locale === 'tr'
    ? 'Sen deneyimli bir Türkçe konuşan kişisel gelişim analisti ve koçusun.'
    : 'You are an experienced personal development analyst and coach who communicates in English.';
}

/**
 * Get month names based on locale
 */
export function getMonthNames(locale: string): string[] {
  return locale === 'tr'
    ? [
        'Ocak',
        'Şubat',
        'Mart',
        'Nisan',
        'Mayıs',
        'Haziran',
        'Temmuz',
        'Ağustos',
        'Eylül',
        'Ekim',
        'Kasım',
        'Aralık',
      ]
    : [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
}

/**
 * Get day names based on locale (Sunday = 0)
 */
export function getDayNames(locale: string): string[] {
  return locale === 'tr'
    ? [
        'Pazar',
        'Pazartesi',
        'Salı',
        'Çarşamba',
        'Perşembe',
        'Cuma',
        'Cumartesi',
      ]
    : [
        'Sunday',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
      ];
}

/**
 * Get date format locale string for toLocaleDateString
 */
export function getDateLocale(locale: string): string {
  return locale === 'tr' ? 'tr-TR' : 'en-US';
}

/**
 * Get "Not specified" text based on locale
 */
export function getNotSpecifiedText(locale: string): string {
  return locale === 'tr' ? 'Belirtilmemiş' : 'Not specified';
}

/**
 * Get "No note" text based on locale
 */
export function getNoNoteText(locale: string): string {
  return locale === 'tr' ? 'Not yok' : 'No note';
}

/**
 * Get pronoun instruction based on locale
 */
export function getPronounInstruction(locale: string): string {
  return locale === 'tr'
    ? 'Metin boyunca okuyucuya doğrudan Türkçe ikinci tekil şahıs ("sen") ile hitap et.'
    : 'Address the reader directly using second person ("you") throughout the text.';
}

/**
 * Get tone instruction based on locale
 */
export function getToneInstruction(locale: string): string {
  return locale === 'tr'
    ? 'Ton: Sıcak, samimi ve destekleyici, ancak aşırı duygusal değil.'
    : 'Tone: Warm, friendly and supportive, but not overly emotional.';
}

/**
 * Get format instruction based on locale
 */
export function getFormatInstruction(locale: string): string {
  return locale === 'tr'
    ? 'Format: Markdown başlıkları kullan (#, ##, ###).'
    : 'Format: Use Markdown headings (#, ##, ###).';
}

/**
 * Get "completed" label based on locale
 */
export function getCompletedLabel(locale: string): string {
  return locale === 'tr' ? 'TAMAMLANDI' : 'COMPLETED';
}

/**
 * Get "active" label based on locale
 */
export function getActiveLabel(locale: string): string {
  return locale === 'tr' ? 'aktif' : 'active';
}

/**
 * Get "archived/completed" label based on locale
 */
export function getArchivedLabel(locale: string): string {
  return locale === 'tr' ? 'tamamlanmış' : 'completed';
}

/**
 * Get progress text based on locale
 */
export function getProgressText(locale: string): string {
  return locale === 'tr' ? 'ilerleme' : 'progress';
}

/**
 * Common localized strings for prompts
 */
export function getLocalizedStrings(locale: string) {
  return {
    languageName: getLanguageName(locale),
    languageInstruction: getLanguageInstruction(locale),
    coachDescription: getCoachDescription(locale),
    analystDescription: getAnalystDescription(locale),
    monthNames: getMonthNames(locale),
    dayNames: getDayNames(locale),
    dateLocale: getDateLocale(locale),
    notSpecified: getNotSpecifiedText(locale),
    noNote: getNoNoteText(locale),
    pronounInstruction: getPronounInstruction(locale),
    toneInstruction: getToneInstruction(locale),
    formatInstruction: getFormatInstruction(locale),
    completedLabel: getCompletedLabel(locale),
    activeLabel: getActiveLabel(locale),
    archivedLabel: getArchivedLabel(locale),
    progressText: getProgressText(locale),
    // Common labels
    goals: locale === 'tr' ? 'hedefler' : 'goals',
    goal: locale === 'tr' ? 'hedef' : 'goal',
    checkIn: locale === 'tr' ? 'check-in' : 'check-in',
    checkIns: locale === 'tr' ? 'check-in' : 'check-ins',
    score: locale === 'tr' ? 'Puan' : 'Score',
    week: locale === 'tr' ? 'hafta' : 'week',
    total: locale === 'tr' ? 'Toplam' : 'Total',
    average: locale === 'tr' ? 'Ortalama' : 'Average',
    description: locale === 'tr' ? 'Açıklama' : 'Description',
    motivation: locale === 'tr' ? 'Motivasyon' : 'Motivation',
  };
}

