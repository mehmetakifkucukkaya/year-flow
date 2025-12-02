/**
 * Goal Optimization using AI
 * Converts user goals to SMART format and suggests sub-goals
 */

import * as logger from 'firebase-functions/logger';
import {
  OptimizeGoalRequest,
  OptimizeGoalResponse,
  SubGoal,
} from '../types/ai-types';
import { GeminiClient } from './gemini-client';

export async function optimizeGoal(
  request: OptimizeGoalRequest,
  geminiClient: GeminiClient
): Promise<OptimizeGoalResponse> {
  const { goalTitle, category, motivation } = request;

  const prompt = `Sen Türkçe konuşan bir kişisel gelişim koçusun.

Görev:
- Kullanıcının verdiği hedefi tam bir SMART hedefine dönüştür (Specific, Measurable, Achievable, Relevant, Time-bound).
- Bu hedefe ulaşmak için 3–5 tane, net ve uygulanabilir alt görev üret.

Girdi:
- Hedef: "${goalTitle}"
- Kategori: ${category}
- Motivasyon: ${motivation || 'Belirtilmemiş'}

Kurallar:
- Yanıtta SADECE geçerli JSON ver, markdown, açıklama, yorum, ekstra metin yok.
- Tüm alanlar Türkçe olmalı.
- Sağlık/egzersiz hedeflerinde güvenli ve makul öneriler ver; tıbbi tavsiye verme.
- Tarih gerekiyorsa ISO formatı kullan (YYYY-MM-DD) veya null döndür.

JSON ŞEMASI (bire bir bu alanları kullan):
{
  "optimizedTitle": "SMART formatında, net ve motive edici hedef başlığı (Türkçe)",
  "subGoals": [
    {
      "id": "benzersiz-bir-id",
      "title": "Net, kısa ve ölçülebilir alt görev (Türkçe)",
      "isCompleted": false,
      "dueDate": "YYYY-MM-DD veya null"
    }
  ],
  "explanation": "Hedefin nasıl optimize edildiğini ve neden daha güçlü olduğunu açıklayan 2-3 cümlelik kısa özet (Türkçe)."
}

ÖNEMLİ:
- optimizedTitle SMART kriterlerine tam uymalı (zaman sınırı ve ölçülebilirlik mutlaka olsun).
- 3 ile 5 arasında alt görev üret.
- Alt görevler birbirini tamamlayan, adım adım ilerleme sağlayan bir yol haritası gibi olmalı.
- Sadece yukarıdaki JSON şemasına uygun, parse edilebilir bir JSON döndür.`;

  try {
    const response = await geminiClient.generateStructuredText(prompt, 2000);

    // Parse JSON response
    let parsed: any;
    try {
      // Remove markdown code blocks if present
      const cleanedResponse = response
        .replace(/```json\n?/g, '')
        .replace(/```\n?/g, '')
        .trim();
      parsed = JSON.parse(cleanedResponse);
    } catch (parseError) {
      logger.error('Failed to parse Gemini response:', response);
      throw new Error('Invalid JSON response from AI');
    }

    // Validate and transform response
    if (!parsed.optimizedTitle || !parsed.subGoals || !parsed.explanation) {
      throw new Error('Invalid response structure from AI');
    }

    const subGoals: SubGoal[] = parsed.subGoals.map((sg: any, index: number) => ({
      id: sg.id || `subgoal-${index + 1}`,
      title: sg.title,
      isCompleted: sg.isCompleted || false,
      dueDate: sg.dueDate || undefined,
    }));

    return {
      optimizedTitle: parsed.optimizedTitle,
      subGoals,
      explanation: parsed.explanation,
    };
  } catch (error: any) {
    logger.error('Error optimizing goal:', error);
    throw new Error(`Goal optimization failed: ${error.message}`);
  }
}

