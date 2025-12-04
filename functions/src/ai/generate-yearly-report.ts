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
import { GeminiClient } from './gemini-client';

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
  const { year, goals, checkIns } = request;

  const analytics = calculateYearlyAnalytics(goals, checkIns);
  const prompt = buildYearlyReportPrompt(year, analytics, goals, checkIns);

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
  // Tamamlanan hedefler: isCompleted=true veya progress=100
  const completedGoals = goals.filter((g) => g.isCompleted || g.progress >= 100);
  const activeGoals = goals.filter((g) => !g.isArchived && !g.isCompleted && g.progress < 100);
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

function groupGoalsByCategory(
  goals: Goal[]
): Record<string, number> {
  return goals.reduce((acc, g) => {
    acc[g.category] = (acc[g.category] || 0) + 1;
    return acc;
  }, {} as Record<string, number>);
}

function groupCheckInsByMonth(
  checkIns: CheckIn[]
): Record<number, number> {
  return checkIns.reduce((acc, ci) => {
    const month = new Date(ci.createdAt).getMonth() + 1;
    acc[month] = (acc[month] || 0) + 1;
    return acc;
  }, {} as Record<number, number>);
}

function buildYearlyReportPrompt(
  year: number,
  analytics: YearlyAnalytics,
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
    checkInsByMonth,
  } = analytics;

  return `Sen deneyimli bir Türkçe konuşan kişisel gelişim analisti ve koçusun. Görevin, ${year} yılı verilerini okuyup kullanıcının kişisel gelişim yolculuğu hakkında **kısa, öz ve okunması kolay** bir yıllık rapor yazmak.

ÖZET VERİLER (zaten Türkçe):
- Yıl: ${year}
- Toplam hedef: ${totalGoals}
- Tamamlanan hedefler: ${completedGoals.length} (${completedGoals.filter((g: Goal) => g.isCompleted === true).length} açıkça tamamlandı olarak işaretlenmiş)
- Aktif hedefler: ${activeGoals.length}
- Ortalama ilerleme: %${averageProgress.toFixed(1)}

Kategoriye göre hedefler:
${Object.entries(goalsByCategory)
      .map(([cat, count]) => `- ${cat}: ${count} hedef`)
      .join('\n')}

Check-in özeti:
- Toplam check-in: ${totalCheckIns}
- Aylık dağılım: ${Object.entries(checkInsByMonth)
      .map(([month, count]) => `${month}. ay: ${count} check-in`)
      .join(', ')}

Hedef detayları:
${goals
      .map(
        (g) =>
          `- "${g.title}" (${g.category}): %${g.progress} ilerleme${g.isCompleted ? ' [TAMAMLANDI]' : ''
          }${g.description
            ? `, Açıklama: ${g.description}`
            : g.motivation
              ? `, Motivasyon: ${g.motivation}`
              : ''
          }`
      )
      .join('\n')}

Son 10 check-in notu:
${checkIns
      .slice(-10)
      .map((ci) => `- ${ci.note || 'Not yok'} (Puan: ${ci.score}/10)`)
      .join('\n')}

Yazım kuralları:
- ÇIKTI DİLİ MUTLAKA TÜRKÇE OLMALI.
- Ton: Sıcak, samimi ve destekleyici, ancak aşırı duygusal değil.
- Format: Markdown başlıkları kullan (#, ##, ###).
- Uzunluk: Maksimum 300–350 kelime. Gereksiz tekrar ve uzun cümlelerden kaçın, net ve doğrudan yaz.

RAPOR BÖLÜMLERİ (bu sırayla yaz, hepsi Türkçe ve her bölümde en fazla 2–3 cümle olacak şekilde):

# ${year} Yıllık Kişisel Gelişim Raporun

## 1. Yılın Genel Özeti
En fazla 2–3 cümlede yılın genel tonunu, ana temaları ve önemli değişimleri özetle. Güçlü yönleri ve gösterilen çabayı takdir et.

## 2. Hedeflerdeki İlerleme
En fazla 2–3 cümlede kategoriye göre ilerlemeyi analiz et; tamamlanan hedefleri kutla (özellikle açıkça tamamlandı olarak işaretlenenler - isCompleted=true), zorlu alanları ve tamamlanmamış hedefleri dürüst ama yapıcı bir şekilde belirt.

## 3. Duygusal ve Mental Yolculuk
En fazla 2–3 cümlede motivasyon dalgalanmalarını, zor dönemleri ve toparlanma anlarını özetle; kullanıcının dayanıklılığını vurgula.

## 4. En İyi Anlar ve Kilometre Taşları
En fazla 2–3 cümlede yıl boyunca öne çıkan anları, ilkleri ve küçük ama anlamlı zaferleri anlat.

## 5. Öğrenilen Dersler
Bu yıldan çıkarılabilecek 4–5 net dersi ve içgörüyü, kısa bir madde işareti listesi halinde yaz.

## 6. ${year + 1} Yılı İçin Öneriler
En fazla 2–3 cümlede gelecek yıl için 3–4 somut odak alanı, yeni hedef fikirleri ve eyleme dönüştürülebilir öneriler ver, Türkçe.

## 7. Kendine Kısa Not
Kullanıcının kendi çabasını takdir etmesine yardımcı olan, şefkatli ama gerçekçi bir tonda kısa bir not yaz, Türkçe.

Metin boyunca okuyucuya doğrudan Türkçe ikinci tekil şahıs ("sen") ile hitap et.`;
}

