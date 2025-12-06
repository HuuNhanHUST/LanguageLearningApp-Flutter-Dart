import 'package:flutter/material.dart';
import '../models/word_model.dart';
import '../services/word_service.dart';

enum WordFilter { all, memorized, notMemorized }

class WordProvider extends ChangeNotifier {
  final WordService _wordService;

  WordProvider({WordService? wordService})
      : _wordService = wordService ?? WordService();

  // State
  List<WordModel> _words = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  WordFilter _currentFilter = WordFilter.all;
  
  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  final int _limit = 20;
  bool _hasMore = true;

  // Getters
  List<WordModel> get words => _words;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  WordFilter get currentFilter => _currentFilter;
  int get total => _total;
  bool get hasMore => _hasMore;
  bool get isEmpty => _words.isEmpty && !_isLoading;

  // Load words
  Future<void> loadWords({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _words.clear();
    }

    if (_isLoading || _isLoadingMore) return;
    if (!refresh && !_hasMore) return;

    if (_currentPage == 1) {
      _isLoading = true;
      _error = null;
    } else {
      _isLoadingMore = true;
    }
    notifyListeners();

    try {
      final filterString = _getFilterString(_currentFilter);
      final result = await _wordService.getWords(
        page: _currentPage,
        limit: _limit,
        filter: filterString,
      );

      final newWords = result['words'] as List<WordModel>;
      _total = result['total'] as int;
      _totalPages = result['totalPages'] as int;

      if (refresh) {
        _words = newWords;
      } else {
        _words.addAll(newWords);
      }

      _hasMore = _currentPage < _totalPages;
      _currentPage++;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Change filter
  Future<void> changeFilter(WordFilter filter) async {
    if (_currentFilter == filter) return;
    _currentFilter = filter;
    await loadWords(refresh: true);
  }

  // Toggle memorized status
  Future<void> toggleMemorized(String wordId, bool isMemorized) async {
    try {
      final updatedWord = await _wordService.toggleMemorized(wordId, isMemorized);
      
      final index = _words.indexWhere((w) => w.id == wordId);
      if (index != -1) {
        _words[index] = updatedWord;
        notifyListeners();
      }

      // Reload if filter doesn't match
      if (_currentFilter == WordFilter.memorized && !isMemorized) {
        _words.removeAt(index);
        _total--;
        notifyListeners();
      } else if (_currentFilter == WordFilter.notMemorized && isMemorized) {
        _words.removeAt(index);
        _total--;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Delete word
  Future<void> deleteWord(String wordId) async {
    try {
      await _wordService.deleteWord(wordId);
      
      _words.removeWhere((w) => w.id == wordId);
      _total--;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Helper
  String? _getFilterString(WordFilter filter) {
    switch (filter) {
      case WordFilter.all:
        return 'all';
      case WordFilter.memorized:
        return 'memorized';
      case WordFilter.notMemorized:
        return 'not-memorized';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
