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
  "optimizedTitle": "Kısa, net ve motive edici hedef adı (Türkçe, en fazla 5–8 kelime; örn. 'Düzenli yürüyüş yapmak', 'Düzenli meditasyon alışkanlığı kazanmak')",
  "subGoals": [
    {
      "id": "benzersiz-bir-id",
      "title": "Net, kısa ve ölçülebilir alt görev (Türkçe)",
      "isCompleted": false,
      "dueDate": "YYYY-MM-DD veya null"
    }
  ],
  "explanation": "Hedefin tam SMART versiyonu. Kullanıcının hedef detay/ açıklama alanına yazılabilecek, 1–2 cümlelik net bir metin (örn: 'Önümüzdeki 3 ay boyunca haftada 3 gün, 30 dakika tempolu yürüyüş yaparak genel sağlığımı iyileştirmek.')."
}

ÖNEMLİ:
- optimizedTitle her zaman KISA bir isim olmalı; mümkünse 3–4 kelime, en fazla 5 kelime kullan. Zamanı, miktarı ve ölçülebilirliği explanation alanına bırak.
- explanation alanı, hedefin SMART detayını içerir ve uzun cümle olabilir.
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

