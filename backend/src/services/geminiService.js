const { GoogleGenerativeAI } = require('@google/generative-ai');

const MODEL_NAME = 'gemini-2.5-flash';
const VALID_TYPES = ['noun', 'verb', 'adj', 'adv', 'other'];

const sanitizeType = (value = '') => {
  const formatted = value.trim().toLowerCase();
  if (VALID_TYPES.includes(formatted)) {
    return formatted;
  }
  if (formatted.includes('noun')) return 'noun';
  if (formatted.includes('verb')) return 'verb';
  if (formatted.includes('adj') || formatted.includes('adjective')) return 'adj';
  if (formatted.includes('adv') || formatted.includes('adverb')) return 'adv';
  return 'other';
};

const cleanJsonText = (raw) =>
  raw
    .replace(/```json/gi, '')
    .replace(/```/g, '')
    .trim();

const buildPrompt = (term) => `You are a bilingual English-Vietnamese dictionary.
Return ONLY valid JSON (no markdown, no commentary) that matches exactly the schema below:
{
  "word": "original english word in lowercase",
  "meaning": "short explanation in Vietnamese",
  "type": "one of noun | verb | adj | adv | other",
  "example": "one concise English example sentence",
  "topic": "one word topic in English, e.g. Greetings, Travel, Food"
}
Rules:
- Translate meaning to Vietnamese.
- Keep word lowercase.
- Example must contain the word.
- If unsure, set type to "other" and topic to "General".
- Absolutely no newline text outside JSON.
Target word: "${term}"`;

class GeminiService {
  constructor() {
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      throw new Error('GEMINI_API_KEY is not configured');
    }
    this.client = new GoogleGenerativeAI(apiKey);
  }

  async fetchWordData(term) {
    const model = this.client.getGenerativeModel({ model: MODEL_NAME });
    const prompt = buildPrompt(term);

    const response = await model.generateContent(prompt);
    const text = response?.response?.text();

    if (!text) {
      throw new Error('Gemini returned empty response');
    }

    try {
      const parsed = JSON.parse(cleanJsonText(text));
      return {
        word: (parsed.word || term).trim().toLowerCase(),
        meaning: (parsed.meaning || '').trim(),
        type: sanitizeType(parsed.type || ''),
        example: (parsed.example || '').trim(),
        topic: (parsed.topic || 'General').trim() || 'General',
      };
    } catch (error) {
      throw new Error('Unable to parse Gemini response');
    }
  }
}

module.exports = new GeminiService();
