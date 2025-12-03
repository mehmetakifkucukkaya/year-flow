/**
 * Lightweight Sub-goal Suggestions using AI
 * Generates 3–6 actionable sub-goal ideas for a given goal.
 */

import * as logger from 'firebase-functions/logger';
import {
  SuggestSubGoalsRequest,
  SuggestSubGoalsResponse,
} from '../types/ai-types';
import {GeminiClient} from './gemini-client';

export async function suggestSubGoals(
  request: SuggestSubGoalsRequest,
  geminiClient: GeminiClient
): Promise<SuggestSubGoalsResponse> {
  const {goalTitle, description, category} = request;

  const prompt = `Sen Türkçe konuşan bir kişisel gelişim ve üretkenlik koçusun.

Görev:
- Kullanıcının verdiği hedef için, uygulanabilir ve net 3–6 adet alt görev (sub-goal) öner.

Girdi:
- Hedef başlığı: "${goalTitle}"
- Kategori: ${category}
- Hedef açıklaması / bağlam: ${description || 'Belirtilmemiş'}

Kurallar:
- Yanıtta SADECE geçerli JSON ver, markdown, açıklama, yorum veya ek metin verme.
- Tüm içerik Türkçe olmalı.
- Sağlık/egzersiz hedeflerinde güvenli, makul ve tıbbi tavsiye içermeyen öneriler ver.
- Alt görevler:
  - Kısa, net ve tek adımda yapılabilir olmalı.
  - Kullanıcıya "bunu bugün yapabilirim" hissi vermeli.

JSON ŞEMASI (bire bir bu yapıyı kullan):
{
  "subGoals": [
    {
      "title": "Net ve uygulanabilir alt görev (Türkçe, tek cümle)"
    }
  ]
}

ÖNEMLİ:
- 3 ile 6 arasında alt görev üret.
- Sadece yukarıdaki JSON şemasına uygun, parse edilebilir bir JSON döndür.`;

  try {
    const response = await geminiClient.generateStructuredText(prompt, 1200);

    let parsed: any;
    try {
      const cleaned = response
        .replace(/```json\n?/g, '')
        .replace(/```\n?/g, '')
        .trim();
      parsed = JSON.parse(cleaned);
    } catch (parseError) {
      logger.error('Failed to parse Gemini response for suggestSubGoals:', {
        raw: response,
        error: parseError,
      });
      throw new Error('Invalid JSON response from AI');
    }

    if (!parsed.subGoals || !Array.isArray(parsed.subGoals)) {
      throw new Error('Invalid response structure from AI (missing subGoals)');
    }

    const subGoals = parsed.subGoals
      .map((sg: any) => ({
        title: String(sg.title || '').trim(),
      }))
      .filter((sg: {title: string}) => sg.title.length > 0);

    return {subGoals};
  } catch (error: any) {
    logger.error('Error in suggestSubGoals:', error);
    throw new Error(`Suggest sub-goals failed: ${error.message}`);
  }
}


