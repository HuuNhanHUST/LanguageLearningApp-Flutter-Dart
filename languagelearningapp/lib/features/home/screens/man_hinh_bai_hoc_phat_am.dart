import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import '../../../providers/audio_recorder_provider.dart';
import '../../../widgets/audio_recorder_button.dart';
import '../../../screens/audio_files_screen.dart';
import '../../../utils/audio_file_manager.dart';

/// Màn hình Bài học Phát âm
/// Cho phép học và thực hành phát âm với ghi âm
class ManHinhBaiHocPhatAm extends ConsumerStatefulWidget {
  final String tenBaiHoc;
  final String chuDe;

  const ManHinhBaiHocPhatAm({
    super.key,
    required this.tenBaiHoc,
    required this.chuDe,
  });

  @override
  ConsumerState<ManHinhBaiHocPhatAm> createState() => _ManHinhBaiHocPhatAmState();
}

class _ManHinhBaiHocPhatAmState extends ConsumerState<ManHinhBaiHocPhatAm> {
  int _buocHienTai = 0;
  late FlutterSoundPlayer _player;
  bool _isPlaying = false;
  String? _previousAudioPath; // Để detect khi nào có file ghi âm MỚI
  
  @override
  void initState() {
    super.initState();
    _player = FlutterSoundPlayer();
    _khoiTaoPlayer();
    // Reset state khi vào màn hình (để đồng bộ với Provider)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audioState = ref.read(audioRecorderProvider);
      if (audioState.audioPath != null) {
        // Nếu Provider có file, sync với local
        _previousAudioPath = audioState.audioPath;
      } else {
        // Nếu Provider null, đảm bảo local cũng null
        _previousAudioPath = null;
      }
    });
  }

  Future<void> _khoiTaoPlayer() async {
    await _player.openPlayer();
  }

  @override
  void dispose() {
    _player.closePlayer();
    super.dispose();
  }

  /// Xóa file ghi âm (như trong audio_files_screen.dart)
  Future<void> _xoaFileGhiAm(String audioPath) async {
    // Kiểm tra file có tồn tại không
    final file = File(audioPath);
    if (!await file.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ File ghi âm không tồn tại'),
            backgroundColor: Colors.red,
          ),
        );
        // Xóa audioPath khỏi state
        ref.read(audioRecorderProvider.notifier).clearAudioPath();
        setState(() => _previousAudioPath = null);
      }
      return;
    }
    
    // Hiển thị dialog xác nhận
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 10),
            Text('Xác nhận xóa'),
          ],
        ),
        content: const Text(
          'Bạn có chắc muốn xóa file ghi âm này?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Xóa',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    // Nếu xác nhận xóa
    if (result == true) {
      try {
        // XÓA FILE THẬT TỪ DISK (dùng AudioFileManager)
        final success = await AudioFileManager.deleteAudioFile(file);
        
        if (success) {
          // Dừng phát nếu đang phát
          if (_isPlaying) {
            await _player.stopPlayer();
          }
          
          // QUAN TRỌNG: Reset state TRƯỚC để UI biết sẽ thay đổi
          setState(() {
            _isPlaying = false;
            _previousAudioPath = null; // Reset để box xanh biến mất
          });
          
          // SAU ĐÓ mới clear Provider (trigger rebuild)
          ref.read(audioRecorderProvider.notifier).clearAudioPath();
          
          // Hiển thị thông báo thành công
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Đã xóa file ghi âm thành công'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          // Lỗi xóa file
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Không thể xóa file'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        // Lỗi exception
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Lỗi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Phát audio đã ghi
  Future<void> _phatAudioDaGhi(String audioPath) async {
    try {
      // Kiểm tra file có tồn tại không
      final file = File(audioPath);
      if (!await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ File ghi âm không tồn tại'),
              backgroundColor: Colors.red,
            ),
          );
          // Xóa audioPath khỏi state
          ref.read(audioRecorderProvider.notifier).clearAudioPath();
          setState(() => _previousAudioPath = null);
        }
        return;
      }
      
      if (_isPlaying) {
        await _player.stopPlayer();
        setState(() => _isPlaying = false);
      } else {
        await _player.startPlayer(
          fromURI: audioPath,
          codec: Codec.aacADTS,
          whenFinished: () {
            setState(() => _isPlaying = false);
          },
        );
        setState(() => _isPlaying = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi phát audio: $e')),
        );
      }
    }
  }
  
  // Danh sách các từ/câu cần luyện phát âm
  final List<Map<String, String>> _cacBaiTap = [
    {
      'tu': 'Apple',
      'phienAm': '/ˈæp.əl/',
      'nghia': 'Quả táo',
      'huongDan': 'Nhấn mạnh vào âm đầu "A", sau đó phát âm nhẹ "pple"',
    },
  ];

  /// Chuyển sang bài tập tiếp theo
  void _chuyenBaiTapTiepTheo() {
    if (_buocHienTai < _cacBaiTap.length - 1) {
      // Dừng phát audio nếu đang phát
      if (_isPlaying) {
        _player.stopPlayer();
      }
      // XÓA AUDIO STATE TRƯỚC KHI setState (QUAN TRỌNG!)
      ref.read(audioRecorderProvider.notifier).clearAudioPath();
      
      // SAU ĐÓ mới setState để chuyển trang
      setState(() {
        _buocHienTai++;
        _isPlaying = false;
        _previousAudioPath = null; // Reset để box xanh biến mất
      });
    } else {
      // Hoàn thành bài học - chỉ pop về
      _hoanThanhBaiHoc();
    }
  }

  /// Quay lại bài tập trước
  void _quayLaiBaiTapTruoc() {
    if (_buocHienTai > 0) {
      // Dừng phát audio nếu đang phát
      if (_isPlaying) {
        _player.stopPlayer();
      }
      // XÓA AUDIO STATE TRƯỚC KHI setState (QUAN TRỌNG!)
      ref.read(audioRecorderProvider.notifier).clearAudioPath();
      
      // SAU ĐÓ mới setState để chuyển trang
      setState(() {
        _buocHienTai--;
        _isPlaying = false;
        _previousAudioPath = null; // Reset về trạng thái ban đầu
      });
    }
  }

  /// Hoàn thành bài học - quay về màn hình trước
  void _hoanThanhBaiHoc() {
    // Hiển thông báo thành công
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Chúc mừng! Bạn đã hoàn thành bài học phát âm!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    // Quay về màn hình chính
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioRecorderProvider);
    final baiTapHienTai = _cacBaiTap[_buocHienTai];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2D1B69), Color(0xFF1A0F3E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header với nút back và tiến độ
              _xayDungHeader(),
              
              // Nội dung bài học
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Từ cần học
                      _xayDungTheTu(baiTapHienTai),
                      const SizedBox(height: 30),
                      
                      // Hướng dẫn
                      _xayDungHuongDan(baiTapHienTai),
                      const SizedBox(height: 30),
                      
                      // Khu vực ghi âm
                      _xayDungKhuVucGhiAm(audioState),
                      const SizedBox(height: 30),
                      
                      // Các nút điều khiển
                      _xayDungCacNutDieuKhien(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Xây dựng header với nút back, tiến độ và quản lý file
  Widget _xayDungHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Nút back
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 10),
          // Tiêu đề
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.tenBaiHoc,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.chuDe,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Nút quản lý file ghi âm
          IconButton(
            onPressed: () async {
              // Navigate đến Quản lý file
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AudioFilesScreen(),
                ),
              );
              // Khi quay lại, đồng bộ state với Provider
              if (mounted) {
                final audioState = ref.read(audioRecorderProvider);
                setState(() {
                  // Nếu Provider đã clear (file đã xóa), reset local state
                  if (audioState.audioPath == null) {
                    _previousAudioPath = null;
                    _isPlaying = false;
                  } else {
                    // Nếu vẫn còn file, sync với Provider
                    _previousAudioPath = audioState.audioPath;
                  }
                });
              }
            },
            icon: const Icon(Icons.folder, color: Colors.white),
            tooltip: 'Quản lý file ghi âm',
          ),
          const SizedBox(width: 10),
          // Tiến độ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_buocHienTai + 1}/${_cacBaiTap.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng thẻ hiển thị từ
  Widget _xayDungTheTu(Map<String, String> baiTap) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Từ tiếng Anh
          Text(
            baiTap['tu']!,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D1B69),
            ),
          ),
          const SizedBox(height: 10),
          // Phiên âm
          Text(
            baiTap['phienAm']!,
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 15),
          // Nghĩa tiếng Việt
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              baiTap['nghia']!,
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF6C63FF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Nút phát âm mẫu
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Phát audio mẫu
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🔊 Đang phát âm mẫu...')),
              );
            },
            icon: const Icon(Icons.volume_up),
            label: const Text('Nghe phát âm'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng hướng dẫn phát âm
  Widget _xayDungHuongDan(Map<String, String> baiTap) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber, size: 24),
              SizedBox(width: 10),
              Text(
                'Hướng dẫn',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            baiTap['huongDan']!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng khu vực ghi âm
  Widget _xayDungKhuVucGhiAm(AudioRecorderState audioState) {
    // Hiển thông báo CHỈ KHI audioPath thay đổi từ null -> có giá trị
    if (!audioState.isRecording && 
        audioState.audioPath != null && 
        audioState.audioPath != _previousAudioPath) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Đã lưu bản ghi âm của bạn!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          // Cập nhật _previousAudioPath để không hiện lại
          _previousAudioPath = audioState.audioPath;
        }
      });
    }

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Thực hành phát âm',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D1B69),
            ),
          ),
          const SizedBox(height: 20),
          // Audio Recorder Button (không còn callback tự động)
          AudioRecorderButton(
            size: 100,
          ),
          const SizedBox(height: 20),
          Text(
            audioState.isRecording
                ? 'Đang ghi âm... 🎙️'
                : 'Nhấn để bắt đầu ghi âm',
            style: TextStyle(
              fontSize: 16,
              color: audioState.isRecording ? Colors.red : Colors.grey[600],
              fontWeight: audioState.isRecording ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          // Hiển thị thông tin file đã ghi
          if (audioState.audioPath != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Đã ghi âm thành công!',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Nút nghe lại - CÓ CHỨC NĂNG THẬT
                      TextButton.icon(
                        onPressed: () => _phatAudioDaGhi(audioState.audioPath!),
                        icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                        label: Text(_isPlaying ? 'Dừng' : 'Nghe lại'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ),
                      ),
                      // Nút XÓA FILE - Xóa file thật khỏi disk
                      TextButton.icon(
                        onPressed: () => _xoaFileGhiAm(audioState.audioPath!),
                        icon: const Icon(Icons.delete),
                        label: const Text('Xóa'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          // Hiển thị lỗi nếu có
          if (audioState.errorMessage != null) ...[
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      audioState.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Xây dựng các nút điều khiển (Quay lại / Tiếp theo)
  Widget _xayDungCacNutDieuKhien() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Nút quay lại
        if (_buocHienTai > 0)
          ElevatedButton.icon(
            onPressed: _quayLaiBaiTapTruoc,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Quay lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          )
        else
          const SizedBox.shrink(),
        
        // Nút tiếp theo / hoàn thành
        ElevatedButton.icon(
          onPressed: _chuyenBaiTapTiepTheo,
          icon: Icon(
            _buocHienTai < _cacBaiTap.length - 1
                ? Icons.arrow_forward
                : Icons.check,
          ),
          label: Text(
            _buocHienTai < _cacBaiTap.length - 1
                ? 'Tiếp theo'
                : 'Hoàn thành',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
        ),
      ],
    );
  }
}
