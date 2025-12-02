/**
 * Generate AI Suggestions based on user goals and progress
 */

import {GeminiClient} from './gemini-client';
import {
  GenerateSuggestionsRequest,
  GenerateSuggestionsResponse,
} from '../types/ai-types';
import * as logger from 'firebase-functions/logger';

export async function generateSuggestions(
  request: GenerateSuggestionsRequest,
  geminiClient: GeminiClient
): Promise<GenerateSuggestionsResponse> {
  const {goals, checkIns} = request;

  // Prepare data summary for AI
  const goalsSummary = goals
    .map(
      (g) =>
        `- ${g.title} (${g.category}): %${g.progress} ilerleme, ${
          g.isArchived ? 'tamamlanmış' : 'aktif'
        }`
    )
    .join('\n');

  const checkInsSummary = checkIns.length > 0
    ? `Toplam ${checkIns.length} check-in yapılmış.`
    : 'Henüz check-in yapılmamış.';

  const prompt = `Sen Türkçe konuşan deneyimli bir kişisel gelişim koçusun.

Amaç:
- Kullanıcının hedefleri ve check-in geçmişi üzerinden kısa, odaklı ve uygulanabilir öneriler vermek.

Veriler:
Kullanıcının Hedefleri:
${goalsSummary}

Check-in Durumu:
${checkInsSummary}

Yazım Kuralları:
- Dil: Türkçe, sıcak ama net ve profesyonel bir ton.
- Biçim: Markdown kullan, en fazla 2 seviye başlık (#, ##) ve numaralı listeler kullanabilirsin.
- Uzunluk: Toplam yaklaşık 150–220 kelime.

İçerik Yapısı:
1. Mevcut ilerlemeyi kısaca değerlendir (güçlü yönleri vurgula).
2. İyileştirme önerileri ver (hedefleri daha küçük adımlara bölme, rutin oluşturma, zaman yönetimi vb.).
3. Kullanıcının durumuna uygun 1-2 yeni hedef fikri öner (çok genel olmayan, somut örnekler).
4. Motivasyonu uzun vadede korumak için 3–4 maddelik pratik ipucu listesi yaz.

Genellemekten kaçın, verilerdeki kategori ve ilerleme yüzdelerini kullanarak mümkün olduğunca kişisel ve somut öneriler üret.`;

  try {
    const suggestions = await geminiClient.generateText(prompt, 1500);

    return {
      suggestions: suggestions.trim(),
    };
  } catch (error: any) {
    logger.error('Error generating suggestions:', error);
    throw new Error(`Suggestions generation failed: ${error.message}`);
  }
}

