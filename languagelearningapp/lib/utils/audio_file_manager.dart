import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AudioFileManager {
  /// Get all audio files in the temporary directory
  static Future<List<File>> getAudioFiles() async {
    try {
      final directory = await getTemporaryDirectory();
      final List<FileSystemEntity> entities = directory.listSync();
      
      final List<File> audioFiles = entities
          .whereType<File>()
          .where((file) => file.path.contains('audio_') && 
                         (file.path.endsWith('.aac') || 
                          file.path.endsWith('.mp3') || 
                          file.path.endsWith('.wav')))
          .toList();
      
      // Sort by modification date (newest first)
      audioFiles.sort((a, b) => 
          b.statSync().modified.compareTo(a.statSync().modified));
      
      return audioFiles;
    } catch (e) {
      print('❌ Error getting audio files: $e');
      return [];
    }
  }

  /// Get file info (size, creation date, etc.)
  static Future<Map<String, dynamic>> getFileInfo(File file) async {
    try {
      final stat = await file.stat();
      final fileName = file.path.split('/').last.split('\\').last;
      
      return {
        'name': fileName,
        'path': file.path,
        'size': stat.size,
        'sizeKB': (stat.size / 1024).toStringAsFixed(2),
        'created': stat.modified,
        'exists': await file.exists(),
      };
    } catch (e) {
      print('❌ Error getting file info: $e');
      return {};
    }
  }

  /// Delete an audio file
  static Future<bool> deleteAudioFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        print('✅ Deleted: ${file.path}');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error deleting file: $e');
      return false;
    }
  }

  /// Delete all audio files
  static Future<int> deleteAllAudioFiles() async {
    try {
      final audioFiles = await getAudioFiles();
      int deletedCount = 0;
      
      for (final file in audioFiles) {
        if (await deleteAudioFile(file)) {
          deletedCount++;
        }
      }
      
      return deletedCount;
    } catch (e) {
      print('❌ Error deleting all files: $e');
      return 0;
    }
  }

  /// Get temporary directory path
  static Future<String> getTempDirectoryPath() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}