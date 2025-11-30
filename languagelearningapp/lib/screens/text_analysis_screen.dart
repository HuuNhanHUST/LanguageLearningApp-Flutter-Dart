import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/text_processing_service.dart';

class TextAnalysisScreen extends StatefulWidget {
  final String recognizedText;
  final String? imagePath;

  const TextAnalysisScreen({
    super.key,
    required this.recognizedText,
    this.imagePath,
  });

  @override
  State<TextAnalysisScreen> createState() => _TextAnalysisScreenState();
}

class _TextAnalysisScreenState extends State<TextAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Map<String, dynamic> _analysis;
  late List<String> _filteredWords;
  late List<Map<String, String>> _flashcards;
  final Map<int, TextEditingController> _translationControllers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Phân tích text
    _analysis = TextProcessingService.analyzeText(widget.recognizedText);

    // Lọc từ phổ biến và sắp xếp
    final allWords = List<String>.from(_analysis['words']);
    _filteredWords = TextProcessingService.filterCommonWords(allWords);
    _filteredWords = TextProcessingService.sortWordsByLength(_filteredWords);

    // Tạo flashcards
    _flashcards = TextProcessingService.generateFlashcards(_filteredWords);

    // Khởi tạo controllers cho translation
    for (int i = 0; i < _flashcards.length; i++) {
      _translationControllers[i] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in _translationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Đã sao chép'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Phân tích văn bản',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.article), text: 'Văn bản'),
            Tab(icon: Icon(Icons.analytics), text: 'Phân tích'),
            Tab(icon: Icon(Icons.style), text: 'Flashcards'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOriginalTextTab(),
          _buildAnalysisTab(),
          _buildFlashcardsTab(),
        ],
      ),
    );
  }

  Widget _buildOriginalTextTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Văn bản nhận dạng:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _copyToClipboard(widget.recognizedText),
                      icon: const Icon(Icons.copy),
                      tooltip: 'Sao chép toàn bộ',
                      color: const Color(0xFF6366F1),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SelectableText(
                  widget.recognizedText,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildStatsCard(),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.1),
            Colors.blue.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text(
            'Thống kê',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                Icons.short_text,
                'Câu',
                '${_analysis['sentenceCount']}',
                Colors.orange,
              ),
              _buildStatItem(
                Icons.text_fields,
                'Từ',
                '${_analysis['wordCount']}',
                Colors.green,
              ),
              _buildStatItem(
                Icons.filter_list,
                'Từ lọc',
                '${_filteredWords.length}',
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildAnalysisTab() {
    final categorized = TextProcessingService.categorizeByLength(
      _filteredWords,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWordCategorySection(
            'Từ ngắn (1-4 ký tự)',
            categorized['short']!,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildWordCategorySection(
            'Từ trung bình (5-8 ký tự)',
            categorized['medium']!,
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildWordCategorySection(
            'Từ dài (9+ ký tự)',
            categorized['long']!,
            Colors.red,
          ),
          const SizedBox(height: 20),
          _buildSentencesSection(),
        ],
      ),
    );
  }

  Widget _buildWordCategorySection(
    String title,
    List<String> words,
    Color color,
  ) {
    if (words.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.label, color: color),
              const SizedBox(width: 8),
              Text(
                '$title (${words.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: words
                .map(
                  (word) => Chip(
                    label: Text(word),
                    backgroundColor: color.withOpacity(0.2),
                    labelStyle: TextStyle(color: color),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSentencesSection() {
    final sentences = List<String>.from(_analysis['sentences']);
    if (sentences.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_quote, color: Colors.indigo),
              const SizedBox(width: 8),
              Text(
                'Các câu (${sentences.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...sentences.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SelectableText(
                      entry.value,
                      style: const TextStyle(fontSize: 15, height: 1.4),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFlashcardsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _flashcards.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.purple.shade400],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white, size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    'Flashcards đã tạo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_flashcards.length} từ vựng',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Thêm nghĩa tiếng Việt để lưu vào danh sách học',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final cardIndex = index - 1;
        final card = _flashcards[cardIndex];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        card['word']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _copyToClipboard(card['word']!),
                      icon: const Icon(Icons.copy, size: 20),
                      color: Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _translationControllers[cardIndex],
                  decoration: InputDecoration(
                    labelText: 'Nghĩa tiếng Việt',
                    hintText: 'Nhập nghĩa của từ...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.translate),
                  ),
                  onChanged: (value) {
                    _flashcards[cardIndex]['translation'] = value;
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
