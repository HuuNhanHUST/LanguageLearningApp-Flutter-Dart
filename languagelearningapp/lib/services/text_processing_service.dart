/// Service để xử lý text từ OCR và tạo flashcard/từ vựng
class TextProcessingService {
  /// Tách text thành các từ và câu
  static Map<String, dynamic> analyzeText(String text) {
    // Loại bỏ ký tự đặc biệt và xuống dòng thừa
    final cleanedText = text.trim().replaceAll(RegExp(r'\s+'), ' ');

    // Tách thành các câu (dựa vào dấu chấm, chấm hỏi, chấm than)
    final sentences = cleanedText
        .split(RegExp(r'[.!?]+'))
        .where((s) => s.trim().isNotEmpty)
        .map((s) => s.trim())
        .toList();

    // Tách thành các từ
    final words = cleanedText
        .toLowerCase()
        .split(RegExp(r'[\s,;:.!?]+'))
        .where((w) => w.isNotEmpty && w.length > 1)
        .toSet() // Loại bỏ trùng lặp
        .toList();

    // Đếm số lượng từ
    final wordCount = words.length;

    return {
      'originalText': text,
      'cleanedText': cleanedText,
      'sentences': sentences,
      'words': words,
      'wordCount': wordCount,
      'sentenceCount': sentences.length,
    };
  }

  /// Tạo danh sách flashcard từ các từ
  static List<Map<String, String>> generateFlashcards(List<String> words) {
    return words.map((word) {
      return {
        'word': word,
        'translation': '', // Sẽ được điền bởi user hoặc API dịch
        'example': '', // Sẽ được tạo sau
        'category': 'scanned', // Đánh dấu từ scan
      };
    }).toList();
  }

  /// Lọc các từ phổ biến (stopwords) - Tiếng Anh
  static List<String> filterCommonWords(List<String> words) {
    final commonWords = {
      'the',
      'a',
      'an',
      'and',
      'or',
      'but',
      'in',
      'on',
      'at',
      'to',
      'for',
      'of',
      'with',
      'by',
      'from',
      'up',
      'about',
      'into',
      'through',
      'during',
      'is',
      'are',
      'was',
      'were',
      'be',
      'been',
      'being',
      'have',
      'has',
      'had',
      'do',
      'does',
      'did',
      'will',
      'would',
      'could',
      'should',
      'may',
      'might',
      'i',
      'you',
      'he',
      'she',
      'it',
      'we',
      'they',
      'them',
      'their',
      'this',
      'that',
    };

    return words
        .where((word) => !commonWords.contains(word.toLowerCase()))
        .toList();
  }

  /// Sắp xếp từ theo độ dài (từ dài → ngắn)
  static List<String> sortWordsByLength(
    List<String> words, {
    bool descending = true,
  }) {
    final sorted = List<String>.from(words);
    sorted.sort(
      (a, b) => descending
          ? b.length.compareTo(a.length)
          : a.length.compareTo(b.length),
    );
    return sorted;
  }

  /// Phân loại từ theo độ dài
  static Map<String, List<String>> categorizeByLength(List<String> words) {
    return {
      'short': words
          .where((w) => w.length <= 4)
          .toList(), // Từ ngắn (1-4 ký tự)
      'medium': words
          .where((w) => w.length > 4 && w.length <= 8)
          .toList(), // Từ trung bình (5-8)
      'long': words.where((w) => w.length > 8).toList(), // Từ dài (9+)
    };
  }
}
