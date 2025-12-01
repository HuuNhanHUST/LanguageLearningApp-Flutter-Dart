const levenshtein = require('fast-levenshtein');

class PronunciationService {
  /**
   * Normalize text: lowercase, remove punctuation, trim whitespace
   * @param {string} text - Text to normalize
   * @returns {string} Normalized text
   */
  normalizeText(text) {
    if (!text || typeof text !== 'string') return '';
    
    return text
      .toLowerCase()
      .replace(/[.,!?;:"""''()[\]{}]/g, '') // Remove punctuation
      .replace(/\s+/g, ' ') // Replace multiple spaces with single space
      .trim();
  }

  /**
   * Calculate similarity score between target and transcript
   * @param {string} target - Expected text
   * @param {string} transcript - User's spoken text
   * @returns {number} Similarity percentage (0-100)
   */
  calculateScore(target, transcript) {
    const normalizedTarget = this.normalizeText(target);
    const normalizedTranscript = this.normalizeText(transcript);

    if (!normalizedTarget || !normalizedTranscript) {
      return 0;
    }

    // Calculate Levenshtein distance
    const distance = levenshtein.get(normalizedTarget, normalizedTranscript);
    
    // Get max length for normalization
    const maxLength = Math.max(normalizedTarget.length, normalizedTranscript.length);
    
    if (maxLength === 0) return 100;

    // Calculate similarity percentage
    const similarity = ((maxLength - distance) / maxLength) * 100;
    
    // Round to 2 decimal places
    return Math.max(0, Math.min(100, Math.round(similarity * 100) / 100));
  }

  /**
   * Highlight errors by comparing target and transcript word by word
   * @param {string} target - Expected text
   * @param {string} transcript - User's spoken text
   * @returns {Array} Array of word objects with status
   */
  highlightErrors(target, transcript) {
    const normalizedTarget = this.normalizeText(target);
    const normalizedTranscript = this.normalizeText(transcript);

    const targetWords = normalizedTarget.split(' ').filter(w => w.length > 0);
    const transcriptWords = normalizedTranscript.split(' ').filter(w => w.length > 0);

    const result = [];
    const maxLength = Math.max(targetWords.length, transcriptWords.length);

    for (let i = 0; i < maxLength; i++) {
      const targetWord = targetWords[i];
      const transcriptWord = transcriptWords[i];

      if (!targetWord && transcriptWord) {
        // Extra word (user said something not in target)
        result.push({
          word: transcriptWord,
          status: 'extra',
          position: i,
        });
      } else if (targetWord && !transcriptWord) {
        // Missing word (user didn't say this word)
        result.push({
          word: targetWord,
          status: 'missing',
          position: i,
        });
      } else if (targetWord === transcriptWord) {
        // Correct word
        result.push({
          word: targetWord,
          status: 'correct',
          position: i,
        });
      } else {
        // Wrong word (similar but not exact)
        const wordSimilarity = this.calculateWordSimilarity(targetWord, transcriptWord);
        
        result.push({
          word: transcriptWord,
          expected: targetWord,
          status: wordSimilarity > 70 ? 'close' : 'wrong',
          similarity: wordSimilarity,
          position: i,
        });
      }
    }

    return result;
  }

  /**
   * Calculate similarity between two words
   * @param {string} word1 - First word
   * @param {string} word2 - Second word
   * @returns {number} Similarity percentage (0-100)
   */
  calculateWordSimilarity(word1, word2) {
    if (!word1 || !word2) return 0;
    if (word1 === word2) return 100;

    const distance = levenshtein.get(word1, word2);
    const maxLength = Math.max(word1.length, word2.length);
    
    if (maxLength === 0) return 100;

    const similarity = ((maxLength - distance) / maxLength) * 100;
    return Math.round(similarity * 100) / 100;
  }

  /**
   * Get detailed pronunciation analysis
   * @param {string} target - Expected text
   * @param {string} transcript - User's spoken text
   * @returns {Object} Complete analysis with score and word-by-word breakdown
   */
  analyzePronunciation(target, transcript) {
    const score = this.calculateScore(target, transcript);
    const wordDetails = this.highlightErrors(target, transcript);

    // Calculate statistics
    const stats = {
      totalWords: wordDetails.length,
      correctWords: wordDetails.filter(w => w.status === 'correct').length,
      wrongWords: wordDetails.filter(w => w.status === 'wrong').length,
      closeWords: wordDetails.filter(w => w.status === 'close').length,
      missingWords: wordDetails.filter(w => w.status === 'missing').length,
      extraWords: wordDetails.filter(w => w.status === 'extra').length,
    };

    // Calculate accuracy percentage
    const accuracy = stats.totalWords > 0 
      ? Math.round((stats.correctWords / stats.totalWords) * 100)
      : 0;

    return {
      score,
      accuracy,
      target: this.normalizeText(target),
      transcript: this.normalizeText(transcript),
      wordDetails,
      stats,
    };
  }
}

module.exports = new PronunciationService();
