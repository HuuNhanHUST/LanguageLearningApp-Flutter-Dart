import 'package:flutter/foundation.dart';

import '../models/word_model.dart';
import '../services/word_service.dart';

class WordLookupProvider extends ChangeNotifier {
  final WordService _wordService;
  WordModel? _currentWord;
  bool _isLoading = false;
  String? _errorMessage;
  final List<WordModel> _history = [];

  WordLookupProvider({WordService? wordService})
    : _wordService = wordService ?? WordService();

  WordModel? get currentWord => _currentWord;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<WordModel> get history => List.unmodifiable(_history);

  Future<void> lookupWord(String word) async {
    final query = word.trim();
    if (query.isEmpty) {
      _errorMessage = 'Vui lòng nhập từ cần tìm';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _wordService.lookupWord(query);
      _currentWord = result;

      _history.removeWhere(
        (item) => item.word.toLowerCase() == query.toLowerCase(),
      );
      _history.insert(0, result);
      if (_history.length > 5) {
        _history.removeLast();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _currentWord = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearResult() {
    _currentWord = null;
    _errorMessage = null;
    notifyListeners();
  }
}
