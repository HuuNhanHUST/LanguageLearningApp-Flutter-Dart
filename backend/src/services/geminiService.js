const { GoogleGenerativeAI } = require('@google/generative-ai');

const MODEL_NAME = 'gemini-2.5-flash';
const VALID_TYPES = ['noun', 'verb', 'adj', 'adv', 'other'];
const VALID_DIFFICULTIES = ['beginner', 'intermediate', 'advanced'];

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

const sanitizeDifficulty = (value = '') => {
  const normalized = value.trim().toLowerCase();
  if (VALID_DIFFICULTIES.includes(normalized)) {
    return normalized;
  }
  if (normalized.includes('inter')) return 'intermediate';
  if (normalized.includes('advance')) return 'advanced';
  return 'beginner';
};

const buildGrammarPrompt = ({ word, meaning, type, example, count, level }) => `You are an English grammar coach generating high-quality multiple-choice questions.
Return ONLY valid JSON with this schema (no markdown, no explanations outside JSON):
{
  "questions": [
    {
      "question": "...",
      "options": ["A", "B", "C", "D"],
      "correctIndex": 0,
      "explanation": "Explain why the answer is correct in <= 25 words",
      "targetSkill": "tense | part-of-speech | collocation | usage | synonym",
      "difficulty": "beginner | intermediate | advanced"
    }
  ]
}
Rules:
- Always return exactly ${count} questions.
- Each question must relate to the vocabulary word "${word}" (meaning: ${meaning}).
- Vary the grammar focus when possible.
- Options must be concise (<= 35 characters) and mutually exclusive.
- Embed the target word or its concept inside the stem or answers.
- Use level ${level} difficulty cues.
- IMPORTANT: return pure JSON, no commentary.
Reference example sentence: ${example || 'N/A'}.
Word type: ${type || 'unknown'}.
`;

const normalizeOptions = (options) => {
  if (!Array.isArray(options)) return [];
  return options
    .map((choice) => (typeof choice === 'string' ? choice.trim() : ''))
    .filter((choice) => choice);
};

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

  async generateGrammarQuestions(wordPayload, { count = 3, level = 'beginner' } = {}) {
    if (!wordPayload || !wordPayload.word) {
      throw new Error('Word payload is required to generate questions');
    }

    const safeCount = Math.min(Math.max(count, 1), 5);
    const model = this.client.getGenerativeModel({ model: MODEL_NAME });
    const prompt = buildGrammarPrompt({
      word: wordPayload.word,
      meaning: wordPayload.meaning || '',
      type: wordPayload.type || 'other',
      example: wordPayload.example || '',
      count: safeCount,
      level,
    });

    const response = await model.generateContent(prompt);
    const text = response?.response?.text();

    if (!text) {
      throw new Error('Gemini returned empty response for grammar questions');
    }

    let parsed;
    try {
      parsed = JSON.parse(cleanJsonText(text));
    } catch (error) {
      throw new Error('Unable to parse Gemini grammar response');
    }

    const rawList = Array.isArray(parsed)
      ? parsed
      : Array.isArray(parsed.questions)
        ? parsed.questions
        : [];

    if (!rawList.length) {
      throw new Error('Gemini grammar response did not contain questions');
    }

    const sanitized = rawList
      .map((item) => {
        const options = normalizeOptions(item.options);
        return {
          question: (item.question || '').trim(),
          options,
          correctIndex: Number.isInteger(item.correctIndex)
            ? item.correctIndex
            : 0,
          explanation: (item.explanation || '').trim(),
          targetSkill: (item.targetSkill || 'grammar').trim() || 'grammar',
          difficulty: sanitizeDifficulty(item.difficulty || level),
        };
      })
      .filter((item) => item.question && item.options.length === 4)
      .slice(0, safeCount);

    if (!sanitized.length) {
      throw new Error('Gemini returned invalid grammar questions');
    }

    return sanitized.map((item) => ({
      ...item,
      correctIndex: Math.min(Math.max(item.correctIndex, 0), item.options.length - 1),
    }));
  }
}

module.exports = new GeminiService();
