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
  const {weekStart, weekEnd, goals, checkIns} = request;

  const analytics = calculateWeeklyAnalytics(goals, checkIns);
  const prompt = buildWeeklyReportPrompt(
    weekStart,
    weekEnd,
    analytics,
    goals,
    checkIns
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

function groupGoalsByCategory(
  goals: Goal[]
): Record<string, number> {
  return goals.reduce((acc, g) => {
    acc[g.category] = (acc[g.category] || 0) + 1;
    return acc;
  }, {} as Record<string, number>);
}

function groupCheckInsByDay(
  checkIns: CheckIn[]
): Record<number, number> {
  return checkIns.reduce((acc, ci) => {
    const day = new Date(ci.createdAt).getDay(); // 0 = Sunday, 1 = Monday, etc.
    acc[day] = (acc[day] || 0) + 1;
    return acc;
  }, {} as Record<number, number>);
}

function formatDate(date: Date): string {
  const day = date.getDate();
  const month = date.getMonth() + 1;
  const year = date.getFullYear();
  const dayNames = [
    'Pazar',
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
  ];
  const dayName = dayNames[date.getDay()];
  return `${day}.${month}.${year} (${dayName})`;
}

function buildWeeklyReportPrompt(
  weekStart: string,
  weekEnd: string,
  analytics: WeeklyAnalytics,
  goals: Goal[],
  checkIns: CheckIn[]
): string {
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

  const dayNames = [
    'Pazar',
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
  ];

  return `Sen deneyimli bir Türkçe konuşan kişisel gelişim analisti ve koçusun. Görevin, ${startDate} ile ${endDate} tarihleri arasındaki haftalık verileri okuyup kullanıcının kişisel gelişim yolculuğu hakkında **kısa, öz ve okunması kolay** bir haftalık rapor yazmak.

ÖZET VERİLER (zaten Türkçe):
- Hafta: ${startDate} - ${endDate}
- Toplam hedef: ${totalGoals}
- Tamamlanan hedefler: ${completedGoals.length} (${
    completedGoals.filter((g: Goal) => g.isCompleted === true).length
  } açıkça tamamlandı olarak işaretlenmiş)
- Aktif hedefler: ${activeGoals.length}
- Ortalama ilerleme: %${averageProgress.toFixed(1)}

Kategoriye göre hedefler:
${Object.entries(goalsByCategory)
    .map(([cat, count]) => `- ${cat}: ${count} hedef`)
    .join('\n')}

Check-in özeti:
- Toplam check-in: ${totalCheckIns}
- Ortalama check-in puanı: ${averageCheckInScore.toFixed(1)}/10
- Günlük dağılım: ${Object.entries(checkInsByDay)
    .map(
      ([day, count]) =>
        `${dayNames[parseInt(day)]}: ${count} check-in`
    )
    .join(', ')}

Hedef detayları:
${goals
    .map(
      (g) =>
        `- "${g.title}" (${g.category}): %${g.progress} ilerleme${
          g.isCompleted ? ' [TAMAMLANDI]' : ''
        }${
          g.description
            ? `, Açıklama: ${g.description}`
            : g.motivation
              ? `, Motivasyon: ${g.motivation}`
              : ''
        }`
    )
    .join('\n')}

Tüm check-in notları:
${checkIns.length > 0
    ? checkIns
        .map(
          (ci) =>
            `- ${new Date(ci.createdAt).toLocaleDateString('tr-TR')}: ${
              ci.note || 'Not yok'
            } (Puan: ${ci.score}/10, İlerleme: ${ci.progressDelta > 0 ? '+' : ''}${ci.progressDelta}%)`
        )
        .join('\n')
    : 'Bu hafta check-in yapılmamış.'}

Yazım kuralları:
- ÇIKTI DİLİ MUTLAKA TÜRKÇE OLMALI.
- Ton: Sıcak, samimi ve destekleyici, ancak aşırı duygusal değil.
- Format: Markdown başlıkları kullan (#, ##, ###).
- Uzunluk: Maksimum 200–250 kelime. Gereksiz tekrar ve uzun cümlelerden kaçın, net ve doğrudan yaz.

RAPOR BÖLÜMLERİ (bu sırayla yaz, hepsi Türkçe ve her bölümde en fazla 2–3 cümle olacak şekilde):

# ${startDate} - ${endDate} Haftalık Raporun

## 1. Haftanın Genel Özeti
En fazla 2–3 cümlede haftanın genel tonunu özetle; temel temaları ve önemli değişiklikleri belirt. Güçlü yönleri ve çabayı takdir et.

## 2. Hedeflerdeki İlerleme
En fazla 2–3 cümlede kategoriye göre ilerlemeyi analiz et; tamamlanan hedefleri kutla (özellikle açıkça tamamlandı olarak işaretlenenler - isCompleted=true) ve zorlu alanları dürüst ama yapıcı bir şekilde belirt.

## 3. Karşılaşılan Zorluklar & Çözümler
En fazla 2–3 cümlede hafta içindeki ana zorlukları ve bunlara karşı geliştirilen çözüm veya stratejileri özetle.

## 4. AI Önerileri
En fazla 2–3 cümlede önümüzdeki hafta için 2–3 somut odak alanı ve eyleme dönüştürülebilir öneriler ver, Türkçe.

Metin boyunca okuyucuya doğrudan Türkçe ikinci tekil şahıs ("sen") ile hitap et.`;
}

