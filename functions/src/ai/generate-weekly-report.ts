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

  return `Sen deneyimli bir Türkçe konuşan kişisel gelişim analisti ve koçusun. Görevin, ${startDate} ile ${endDate} tarihleri arasındaki haftalık verileri okuyup kullanıcının kişisel gelişim yolculuğu hakkında anlamlı, ilham verici ve dengeli bir haftalık rapor yazmak.

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
- Uzunluk: Yaklaşık 400–600 kelime.

RAPOR BÖLÜMLERİ (bu sırayla yaz, hepsi Türkçe):

# ${startDate} - ${endDate} Haftalık Raporun

## 1. Haftanın Genel Özeti
Haftanın genel tonunu özetle, temel temaları ve önemli değişiklikleri belirt. Güçlü yönleri ve çabayı takdir et.

## 2. Hedeflerdeki İlerleme
Kategoriye göre ilerlemeyi analiz et; tamamlanan hedefleri kutla (özellikle açıkça tamamlandı olarak işaretlenenler - isCompleted=true), zorlu alanları ve tamamlanmamış hedefleri dürüst ama yapıcı bir şekilde tartış. Hedef tamamlama başarısını pozitif bir kilometre taşı ve başarı olarak vurgula.

## 3. Check-in Analizi
Check-in verilerini kullanarak motivasyon değişimlerini, zorlu dönemleri ve toparlanma anlarını açıkla. Kullanıcının dayanıklılığını vurgula.

## 4. Haftanın En İyi Anları
Hafta boyunca öne çıkan anları, ilkleri ve küçük ama anlamlı zaferleri anlat.

## 5. Öğrenilen Dersler
Bu haftadan çıkarılabilecek 3–4 net ders ve içgörüyü, Türkçe madde işareti listesi olarak yaz.

## 6. Gelecek Hafta İçin Öneriler
Önümüzdeki hafta için 2–3 somut odak alanı ve eyleme dönüştürülebilir öneriler ver, Türkçe.

## 7. Kendine Kısa Not
Kullanıcının kendi çabasını takdir etmesine yardımcı olan, şefkatli ama gerçekçi bir tonda kısa bir not yaz, Türkçe.

Metin boyunca okuyucuya doğrudan Türkçe ikinci tekil şahıs ("sen") ile hitap et.`;
}

