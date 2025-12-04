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

const monthNames = [
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
];

export async function generateMonthlyReport(
  request: GenerateMonthlyReportRequest,
  geminiClient: GeminiClient
): Promise<GenerateMonthlyReportResponse> {
  const {year, month, goals, checkIns} = request;

  const analytics = calculateMonthlyAnalytics(goals, checkIns);
  const prompt = buildMonthlyReportPrompt(
    year,
    month,
    analytics,
    goals,
    checkIns
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

function groupGoalsByCategory(
  goals: Goal[]
): Record<string, number> {
  return goals.reduce((acc, g) => {
    acc[g.category] = (acc[g.category] || 0) + 1;
    return acc;
  }, {} as Record<string, number>);
}

function groupCheckInsByWeek(
  checkIns: CheckIn[]
): Record<number, number> {
  return checkIns.reduce((acc, ci) => {
    const date = new Date(ci.createdAt);
    // Calculate week of month (1-4 or 5)
    const firstDay = new Date(date.getFullYear(), date.getMonth(), 1);
    const dayOfMonth = date.getDate();
    const week = Math.ceil((dayOfMonth + firstDay.getDay()) / 7);
    acc[week] = (acc[week] || 0) + 1;
    return acc;
  }, {} as Record<number, number>);
}

function buildMonthlyReportPrompt(
  year: number,
  month: number,
  analytics: MonthlyAnalytics,
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
    checkInsByWeek,
    averageCheckInScore,
  } = analytics;

  const monthName = monthNames[month - 1];

  return `Sen deneyimli bir Türkçe konuşan kişisel gelişim analisti ve koçusun. Görevin, ${year} yılının ${monthName} ayı verilerini okuyup kullanıcının kişisel gelişim yolculuğu hakkında **kısa, öz ve okunması kolay** bir aylık rapor yazmak.

ÖZET VERİLER (zaten Türkçe):
- Ay: ${monthName} ${year}
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
- Haftalık dağılım: ${Object.entries(checkInsByWeek)
    .map(([week, count]) => `${week}. hafta: ${count} check-in`)
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

Son 15 check-in notu:
${checkIns.length > 0
    ? checkIns
        .slice(-15)
        .map(
          (ci) =>
            `- ${new Date(ci.createdAt).toLocaleDateString('tr-TR')}: ${
              ci.note || 'Not yok'
            } (Puan: ${ci.score}/10, İlerleme: ${ci.progressDelta > 0 ? '+' : ''}${ci.progressDelta}%)`
        )
        .join('\n')
    : 'Bu ay check-in yapılmamış.'}

Yazım kuralları:
- ÇIKTI DİLİ MUTLAKA TÜRKÇE OLMALI.
- Ton: Sıcak, samimi ve destekleyici, ancak aşırı duygusal değil.
- Format: Markdown başlıkları kullan (#, ##, ###).
- Uzunluk: Maksimum 250–300 kelime. Gereksiz tekrar ve uzun cümlelerden kaçın, net ve doğrudan yaz.

RAPOR BÖLÜMLERİ (bu sırayla yaz, hepsi Türkçe ve her bölümde en fazla 2–3 cümle olacak şekilde):

# ${monthName} ${year} Aylık Kişisel Gelişim Raporun

## 1. Ayın Genel Özeti
En fazla 2–3 cümlede ayın genel tonunu özetle; temel temaları ve önemli değişiklikleri belirt. Güçlü yönleri ve çabayı takdir et.

## 2. Hedeflerdeki İlerleme
En fazla 2–3 cümlede kategoriye göre ilerlemeyi analiz et; tamamlanan hedefleri kutla (özellikle açıkça tamamlandı olarak işaretlenenler - isCompleted=true) ve zorlu alanları dürüst ama yapıcı bir şekilde belirt.

## 3. Duygusal ve Mental Yolculuk
En fazla 2–3 cümlede motivasyon ve duygu dalgalanmalarını, zor dönemleri ve toparlanma anlarını özetle; kullanıcının dayanıklılığını vurgula.

## 4. Ayın En İyi Anları ve Kilometre Taşları
En fazla 2–3 cümlede ay boyunca öne çıkan anları, ilkleri ve küçük ama anlamlı zaferleri anlat.

## 5. Öğrenilen Dersler
Bu aydan çıkarılabilecek 3–4 net dersi ve içgörüyü, kısa bir madde işareti listesi halinde yaz.

## 6. Gelecek Ay İçin Öneriler
En fazla 2–3 cümlede önümüzdeki ay için 2–3 somut odak alanı ve eyleme dönüştürülebilir öneri ver, Türkçe.

Metin boyunca okuyucuya doğrudan Türkçe ikinci tekil şahıs ("sen") ile hitap et.`;
}

