import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../words/models/word_model.dart';
import '../../words/services/pronunciation_service.dart';
import '../../words/services/text_to_speech_service.dart';
import '../../learning/providers/learning_provider.dart';
import '../../learning/widgets/level_up_dialog.dart';

/// Màn hình Flashcard từ vựng
/// 20 từ/ngày theo cấp độ
class ManHinhFlashcard extends ConsumerStatefulWidget {
  final String tenBaiHoc;
  final String chuDe;

  const ManHinhFlashcard({
    super.key,
    required this.tenBaiHoc,
    required this.chuDe,
  });

  @override
  ConsumerState<ManHinhFlashcard> createState() => _ManHinhFlashcardState();
}

class _ManHinhFlashcardState extends ConsumerState<ManHinhFlashcard> {
  final PronunciationService _pronunciationService = PronunciationService();
  final TextToSpeechService _ttsService = TextToSpeechService();

  List<WordModel> _words = [];
  int _currentIndex = 0;
  bool _isLoadingWords = true;
  bool _showMeaning = false;
  bool _isMarkingWord = false;
  Set<String> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadWords());
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }

  Future<void> _loadWords() async {
    setState(() {
      _isLoadingWords = true;
    });

    try {
      await ref.read(learningProvider.notifier).loadProgress();
      await Future.delayed(const Duration(milliseconds: 100));

      final learningState = ref.read(learningProvider);

      // Check nếu đã hết lượt học hôm nay
      if (learningState.flashcardRemaining == 0 || !learningState.canLearnFlashcard) {
        if (!mounted) return;
        setState(() {
          _isLoadingWords = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Bạn đã hoàn thành 20 flashcards hôm nay! Quay lại vào ngày mai nhé!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop();
        return;
      }

      // Lấy flashcard words: 20 từ theo difficulty
      final words = await _pronunciationService.getFlashcardWords(
        limit: learningState.flashcardRemaining > 0 
          ? learningState.flashcardRemaining 
          : 20,
      );

      if (!mounted) return;

      if (words.isEmpty) {
        setState(() {
          _isLoadingWords = false;
        });
        _showSnackBar('Bạn đã hoàn thành 20 flashcards hôm nay! 🎉', isSuccess: true);
        return;
      }

      setState(() {
        _words = words;
        _currentIndex = 0;
        _isLoadingWords = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingWords = false;
      });
      _showSnackBar('Không thể tải từ vựng: $e');
    }
  }

  Future<void> _speakWord() async {
    if (_words.isEmpty) return;
    final word = _words[_currentIndex];
    await _ttsService.speak(word.word);
  }

  void _toggleFavorite() {
    if (_words.isEmpty) return;
    final wordId = _words[_currentIndex].id;
    setState(() {
      if (_favoriteIds.contains(wordId)) {
        _favoriteIds.remove(wordId);
      } else {
        _favoriteIds.add(wordId);
      }
    });
  }

  void _toggleMeaning() {
    setState(() {
      _showMeaning = !_showMeaning;
    });
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _showMeaning = false;
      });
    }
  }

  void _nextCard() {
    if (_currentIndex < _words.length - 1) {
      setState(() {
        _currentIndex++;
        _showMeaning = false;
      });
    } else {
      _showSnackBar('Đã hết thẻ! Nhấn "Hoàn thành" để kết thúc.');
    }
  }

  Future<void> _completeFlashcard() async {
    if (_isMarkingWord) return;

    setState(() => _isMarkingWord = true);

    try {
      final result = await ref.read(learningProvider.notifier).markWordLearned(
        _words[_currentIndex].id,
        lessonType: 'flashcard',
      );

      if (!mounted) return;

      setState(() => _isMarkingWord = false);

      if (result['success'] == true) {
        _showSnackBar('Đã học từ này! 🎉', isSuccess: true);

        // Check level up
        if (result['leveledUp'] == true) {
          await Future.delayed(const Duration(milliseconds: 300));
          if (mounted) {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => LevelUpDialog(
                newLevel: result['newLevel'] as int,
                xpGained: result['xpGained'] as int,
              ),
            );
          }
        }

        // Move to next card or finish
        if (_currentIndex < _words.length - 1) {
          _nextCard();
        } else {
          // Hoàn thành tất cả
          _showSnackBar('🎉 Hoàn thành 20 flashcards hôm nay!', isSuccess: true);
          Navigator.pop(context);
        }
      } else {
        _showSnackBar(result['message']?.toString() ?? 'Lỗi đánh dấu từ');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isMarkingWord = false);
      _showSnackBar('Lỗi: $e');
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final learningState = ref.watch(learningProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tenBaiHoc),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Còn ${learningState.flashcardRemaining}/20',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoadingWords
          ? const Center(child: CircularProgressIndicator())
          : _words.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 80, color: Colors.green),
                      const SizedBox(height: 16),
                      const Text(
                        '🎉 Đã hoàn thành!',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('Bạn đã học xong 20 flashcards hôm nay!'),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Quay lại'),
                      ),
                    ],
                  ),
                )
              : _buildFlashcard(),
      bottomNavigationBar: _words.isNotEmpty
          ? _buildBottomControls()
          : null,
    );
  }

  Widget _buildFlashcard() {
    final word = _words[_currentIndex];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Counter
            Text(
              '${_currentIndex + 1} / ${_words.length}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),

            // Flashcard
            GestureDetector(
              onTap: _toggleMeaning,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Star button
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: IconButton(
                          icon: Icon(
                            _favoriteIds.contains(word.id)
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: _toggleFavorite,
                        ),
                      ),
                    ),

                    // Word or meaning
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!_showMeaning) ...[
                                Text(
                                  word.word,
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '(${word.type})',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                IconButton(
                                  icon: const Icon(Icons.volume_up, size: 48),
                                  color: const Color(0xFF6C63FF),
                                  onPressed: _speakWord,
                                ),
                              ] else ...[
                                Text(
                                  word.meaning,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (word.example != null &&
                                    word.example!.isNotEmpty) ...[
                                  const SizedBox(height: 24),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          word.example!,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Tap hint
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _showMeaning ? 'Nhấn để xem từ' : 'Nhấn để xem nghĩa',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Complete button
            ElevatedButton(
              onPressed: _isMarkingWord ? null : _completeFlashcard,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isMarkingWord
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Đã học từ này',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 32),
            onPressed: _currentIndex > 0 ? _previousCard : null,
            color: _currentIndex > 0 ? const Color(0xFF6C63FF) : Colors.grey,
          ),
          IconButton(
            icon: const Icon(Icons.volume_up, size: 32),
            onPressed: _speakWord,
            color: const Color(0xFF6C63FF),
          ),
          IconButton(
            icon: const Icon(Icons.flip, size: 32),
            onPressed: _toggleMeaning,
            color: const Color(0xFF6C63FF),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 32),
            onPressed: _currentIndex < _words.length - 1 ? _nextCard : null,
            color: _currentIndex < _words.length - 1
                ? const Color(0xFF6C63FF)
                : Colors.grey,
          ),
        ],
      ),
    );
  }
}
