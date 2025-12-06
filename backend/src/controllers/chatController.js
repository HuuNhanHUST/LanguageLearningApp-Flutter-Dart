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
   * Chat với AI Tutor - với Context-Aware Conversation
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
7. **Remember previous context** - When user says "Nó là gì?" or asks follow-up questions, refer to what was discussed before

Guidelines:
- Be friendly, encouraging, and patient
- Provide clear, concise explanations
- Use examples to illustrate concepts
- When translating, show both languages clearly
- When teaching grammar, explain the rules simply
- Format responses nicely with emojis when appropriate
- If user asks in Vietnamese, respond in Vietnamese
- If user asks in English, respond in English
- Always be helpful and educational
- **IMPORTANT**: Pay attention to previous conversation context and provide relevant answers based on what was discussed
- When user refers to something mentioned before (like "nó", "từ đó", etc.), look at the conversation history to understand what they're referring to`;

      // Giới hạn token: Chỉ lấy 5-10 tin nhắn gần nhất để tránh tốn token
      const HISTORY_LIMIT = 10;
      const recentHistory = conversationHistory.slice(-HISTORY_LIMIT);

      // Xây dựng conversation context với format rõ ràng hơn
      let conversationContext = '';
      if (recentHistory.length > 0) {
        conversationContext = recentHistory
          .map(msg => `${msg.isUser ? 'User' : 'AI Tutor'}: ${msg.text}`)
          .join('\n');
      }

      // Tạo prompt với context được tích hợp ngay trong system prompt
      const fullPrompt = conversationContext 
        ? `${systemPrompt}

=== Previous Conversation Context ===
${conversationContext}
=== End of Context ===

Current User Message: ${message}

AI Tutor Response (remember the context above when answering):`
        : `${systemPrompt}

User: ${message}

AI Tutor:`;

      // Gọi Gemini API - Dùng gemini-2.5-flash (tên chính xác)
      const model = this.client.getGenerativeModel({ 
        model: 'gemini-2.5-flash',
        generationConfig: {
          temperature: 0.7,
          maxOutputTokens: 1000,
          topP: 0.95,
          topK: 40,
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

  /**
   * Translate text to Vietnamese
   * POST /api/chat/translate
   * Body: { text: string }
   */
  async translate(req, res) {
    try {
      const { text } = req.body;

      if (!text || text.trim().length === 0) {
        return res.status(400).json({
          success: false,
          message: 'Text is required',
        });
      }

      const prompt = `Translate the following text to Vietnamese. Only return the Vietnamese translation, no explanations or extra text:

${text}`;

      const model = this.client.getGenerativeModel({ 
        model: 'gemini-2.5-flash',
        generationConfig: {
          temperature: 0.3,
          maxOutputTokens: 2000,
        }
      });

      const result = await model.generateContent(prompt);
      const response = result.response;
      const translation = response.text();

      return res.status(200).json({
        success: true,
        data: {
          originalText: text,
          translatedText: translation.trim(),
          timestamp: new Date().toISOString(),
        },
      });

    } catch (error) {
      console.error('❌ Translation error:', error);
      return res.status(500).json({
        success: false,
        message: 'Failed to translate text',
        error: error.message,
      });
    }
  }
}

module.exports = new ChatController();
