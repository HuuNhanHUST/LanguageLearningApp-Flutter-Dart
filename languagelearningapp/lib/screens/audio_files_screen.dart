import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/audio_file_manager.dart';

class AudioFilesScreen extends ConsumerStatefulWidget {
  const AudioFilesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AudioFilesScreen> createState() => _AudioFilesScreenState();
}

class _AudioFilesScreenState extends ConsumerState<AudioFilesScreen> {
  List<File> audioFiles = [];
  bool isLoading = true;
  String? tempDirectory;

  @override
  void initState() {
    super.initState();
    _loadAudioFiles();
    _getTempDirectory();
  }

  Future<void> _loadAudioFiles() async {
    setState(() => isLoading = true);
    
    try {
      final files = await AudioFileManager.getAudioFiles();
      setState(() {
        audioFiles = files;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải file: $e')),
        );
      }
    }
  }

  Future<void> _getTempDirectory() async {
    final path = await AudioFileManager.getTempDirectoryPath();
    setState(() => tempDirectory = path);
  }

  Future<void> _deleteFile(File file) async {
    final success = await AudioFileManager.deleteAudioFile(file);
    if (success) {
      _loadAudioFiles(); // Refresh list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa file thành công')),
        );
      }
    }
  }

  Future<void> _deleteAllFiles() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa tất cả file ghi âm?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (result == true) {
      final deletedCount = await AudioFileManager.deleteAllAudioFiles();
      _loadAudioFiles(); // Refresh list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa $deletedCount file')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý File Ghi âm'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadAudioFiles,
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
          ),
          if (audioFiles.isNotEmpty)
            IconButton(
              onPressed: _deleteAllFiles,
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Xóa tất cả',
            ),
        ],
      ),
      body: Column(
        children: [
          // Info Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Thông tin thư mục',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Thư mục: ${tempDirectory ?? "Đang tải..."}'),
                  Text('Số lượng file: ${audioFiles.length}'),
                ],
              ),
            ),
          ),
          
          // Files List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : audioFiles.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.audiotrack, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Chưa có file ghi âm nào'),
                            SizedBox(height: 8),
                            Text('Hãy thử ghi âm một đoạn để xem file ở đây'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: audioFiles.length,
                        itemBuilder: (context, index) {
                          final file = audioFiles[index];
                          return FutureBuilder<Map<String, dynamic>>(
                            future: AudioFileManager.getFileInfo(file),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const ListTile(
                                  title: Text('Đang tải...'),
                                );
                              }

                              final fileInfo = snapshot.data!;
                              final fileName = fileInfo['name'] ?? 'Unknown';
                              final fileSize = fileInfo['sizeKB'] ?? '0';
                              final created = fileInfo['created'] as DateTime?;

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16, 
                                  vertical: 4,
                                ),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child: Icon(Icons.audiotrack, 
                                               color: Colors.white),
                                  ),
                                  title: Text(fileName),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Kích thước: ${fileSize} KB'),
                                      if (created != null)
                                        Text('Tạo lúc: ${_formatDateTime(created)}'),
                                    ],
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        _showDeleteConfirmation(file);
                                      } else if (value == 'info') {
                                        _showFileInfo(fileInfo);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'info',
                                        child: Row(
                                          children: [
                                            Icon(Icons.info),
                                            SizedBox(width: 8),
                                            Text('Chi tiết'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Xóa'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        tooltip: 'Quay lại ghi âm',
        child: const Icon(Icons.mic),
      ),
    );
  }

  void _showDeleteConfirmation(File file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa file này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteFile(file);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showFileInfo(Map<String, dynamic> fileInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chi tiết file'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tên: ${fileInfo['name']}'),
            const SizedBox(height: 8),
            Text('Đường dẫn: ${fileInfo['path']}'),
            const SizedBox(height: 8),
            Text('Kích thước: ${AudioFileManager.formatFileSize(fileInfo['size'] ?? 0)}'),
            const SizedBox(height: 8),
            Text('Tạo lúc: ${_formatDateTime(fileInfo['created'])}'),
            const SizedBox(height: 8),
            Text('Tồn tại: ${fileInfo['exists'] ? "Có" : "Không"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Không rõ';
    
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}:'
           '${dateTime.second.toString().padLeft(2, '0')}';
  }
}