/**
 * Generate Yearly Report using AI
 * Comprehensive analysis of user's year-long journey
 */

import {GeminiClient} from './gemini-client';
import {
  GenerateYearlyReportRequest,
  GenerateYearlyReportResponse,
} from '../types/ai-types';
import * as logger from 'firebase-functions/logger';

export async function generateYearlyReport(
  request: GenerateYearlyReportRequest,
  geminiClient: GeminiClient
): Promise<GenerateYearlyReportResponse> {
  const {year, goals, checkIns} = request;

  // Prepare comprehensive data summary
  const completedGoals = goals.filter((g) => g.progress >= 100);
  const activeGoals = goals.filter((g) => !g.isArchived && g.progress < 100);
  const averageProgress =
    goals.length > 0
      ? goals.reduce((sum, g) => sum + g.progress, 0) / goals.length
      : 0;

  const goalsByCategory = goals.reduce((acc, g) => {
    acc[g.category] = (acc[g.category] || 0) + 1;
    return acc;
  }, {} as Record<string, number>);

  const checkInsByMonth = checkIns.reduce((acc, ci) => {
    const month = new Date(ci.createdAt).getMonth() + 1;
    acc[month] = (acc[month] || 0) + 1;
    return acc;
  }, {} as Record<number, number>);

  const prompt = `Sen Türkçe konuşan deneyimli bir kişisel gelişim analisti ve koçusun. Görevin, ${year} yılı için kullanıcının kişisel gelişim yolculuğunu veriler üzerinden okuyup anlamlı, ilham verici ama aynı zamanda dengeli bir yıllık rapor yazmak.

ÖZET VERİLER:
- Yıl: ${year}
- Toplam Hedef: ${goals.length}
- Tamamlanan Hedef: ${completedGoals.length}
- Aktif Hedef: ${activeGoals.length}
- Ortalama İlerleme: %${averageProgress.toFixed(1)}

Kategori Dağılımı:
${Object.entries(goalsByCategory)
  .map(([cat, count]) => `- ${cat}: ${count} hedef`)
  .join('\n')}

Check-in Özeti:
- Toplam Check-in: ${checkIns.length}
- Aylık Dağılım: ${Object.entries(checkInsByMonth)
  .map(([month, count]) => `${month}. ay: ${count} check-in`)
  .join(', ')}

Hedefler Detayı:
${goals
  .map(
    (g) =>
      `- "${g.title}" (${g.category}): %${g.progress} ilerleme${
        g.description
          ? `, Açıklama: ${g.description}`
          : g.motivation
          ? `, Motivasyon: ${g.motivation}`
          : ''
      }`
  )
  .join('\n')}

Son 10 Check-in Notu:
${checkIns
  .slice(-10)
  .map((ci) => `- ${ci.note || 'Not yok'} (Puan: ${ci.score}/10)`)
  .join('\n')}

YAZIM KURALLARI:
- Dil: Türkçe, samimi ve içten ama aşırı duygusal değil.
- Biçim: Markdown başlıkları (#, ##, ###) kullan.
- Uzunluk: Yaklaşık 700–1.000 kelime arasında tut.

RAPOR BÖLÜMLERİ (sırasıyla yaz):

# ${year} Yıllık Kişisel Gelişim Raporun

## 1. Yılın Genel Özeti
Yılın genel tonunu, öne çıkan temaları ve önemli değişimleri özetle. Güçlü yönleri ve çabayı takdir et.

## 2. Hedeflerdeki İlerleme
Kategorilere göre ilerlemeyi analiz et; tamamlanan hedefler, zorlanılan alanlar ve yarım kalan hedefler hakkında dürüst ama yapıcı bir değerlendirme yap.

## 3. Duygusal ve Mental Yolculuk
Check-in verilerini kullanarak motivasyon dalgalanmaları, zor dönemler ve toparlanma anlarını anlat. Kullanıcının gösterdiği dayanıklılığı vurgula.

## 4. En İyi Anlar ve Kilometre Taşları
Yıl boyunca öne çıkan başarılar, ilkler ve küçük ama anlamlı zaferlerden bahset.

## 5. Öğrenilen Dersler
Bu yıldan çıkarılabilecek 4–6 madde halinde net dersler ve içgörüler yaz.

## 6. ${year + 1} Yılı İçin Öneriler
Bir sonraki yıl için 3–5 somut odak alanı, yeni hedef fikri ve uygulanabilir öneri ver.

## 7. Kendine Mektup
Kullanıcının kendi emeğini takdir eden, şefkatli ama gerçekçi, motive edici kısa bir mektup yaz.

Metnin tamamında kişisel zamir olarak \"sen\" kullan ve okuyucuyla doğrudan konuş.`;

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

