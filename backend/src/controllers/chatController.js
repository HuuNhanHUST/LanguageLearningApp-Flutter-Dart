const { GoogleGenerativeAI } = require('@google/generative-ai');

/**
 * Chat Controller - Xử lý chat với Gemini AI
 */
class ChatController {
  constructor() {
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      throw new Error('GEMINI_API_KEY is not configured');
    }
    this.client = new GoogleGenerativeAI(apiKey);
  }

  /**
   * Chat với AI Tutor
   * POST /api/chat
   * Body: { message: string, conversationHistory?: array }
   */
  async chat(req, res) {
    try {
      const { message, conversationHistory = [] } = req.body;

      if (!message || message.trim().length === 0) {
        return res.status(400).json({
          success: false,
          message: 'Message is required',
        });
      }

      // Tạo system prompt cho AI Tutor
      const systemPrompt = `You are an AI English Tutor assistant. Your role is to help users learn English effectively.

Your capabilities:
1. Translate between English and Vietnamese
2. Explain grammar rules clearly with examples
3. Teach vocabulary with usage examples
4. Help with pronunciation tips
5. Practice conversation scenarios
6. Answer questions about English learning

Guidelines:
- Be friendly, encouraging, and patient
- Provide clear, concise explanations
- Use examples to illustrate concepts
- When translating, show both languages clearly
- When teaching grammar, explain the rules simply
- Format responses nicely with emojis when appropriate
- If user asks in Vietnamese, respond in Vietnamese
- If user asks in English, respond in English
- Always be helpful and educational`;

      // Xây dựng conversation context
      const conversationContext = conversationHistory
        .map(msg => `${msg.isUser ? 'User' : 'AI'}: ${msg.text}`)
        .join('\n');

      const fullPrompt = `${systemPrompt}

Previous conversation:
${conversationContext}

User: ${message}

AI:`;

      // Gọi Gemini API - Dùng gemini-2.5-flash (tên chính xác)
      const model = this.client.getGenerativeModel({ 
        model: 'gemini-2.5-flash',
        generationConfig: {
          temperature: 0.7,
          maxOutputTokens: 1000,
        }
      });

      const result = await model.generateContent(fullPrompt);
      const response = result.response;
      const aiMessage = response.text();

      return res.status(200).json({
        success: true,
        data: {
          message: aiMessage.trim(),
          timestamp: new Date().toISOString(),
        },
      });

    } catch (error) {
      console.error('❌ Chat error:', error);
      return res.status(500).json({
        success: false,
        message: 'Failed to process chat message',
        error: error.message,
      });
    }
  }
}

module.exports = new ChatController();
