# Tính năng Chấm điểm Phát âm

## 📋 Tổng quan

Tính năng này cho phép người dùng thực hành phát âm và nhận được phản hồi chi tiết về độ chính xác của phát âm thông qua:
- **Điểm số tổng thể** (0-100)
- **Phân tích từng từ** với màu sắc trực quan
- **Gợi ý phát âm** cho từ sai

## ✅ Hoàn thành

### Backend (Node.js/Express)
✅ **API Endpoints** (`/api/pronunciation/*`)
- `POST /compare` - Chấm điểm và phân tích chi tiết
- `POST /score` - Tính điểm đơn giản
- `POST /errors` - Phân tích lỗi từng từ

✅ **Pronunciation Service**
- Chuẩn hóa text (normalize)
- So sánh sử dụng Levenshtein distance
- Phân loại từ: correct, wrong, close, missing, extra
- Tính toán điểm số và thống kê

### Frontend (Flutter)

✅ **Models**
- `PronunciationResultModel` - Kết quả chấm điểm
- `WordDetail` - Chi tiết từng từ
- `PronunciationStats` - Thống kê

✅ **Services**
- `PronunciationService.comparePronunciation()` - Gọi API chấm điểm
- `PronunciationService.calculateScore()` - Tính điểm đơn giản

✅ **UI Components**
- `PronunciationResultWidget` - Widget hiển thị kết quả với:
  - `CircularPercentIndicator` - Hiển thị điểm số
  - Màu sắc theo điểm (Xanh ≥80, Vàng ≥60, Đỏ <60)
  - Thống kê từ đúng/sai/gần đúng
  - RichText với màu sắc theo trạng thái từ
  - Nút phát âm lại cho từ sai (TTS)

✅ **Integration**
- Tích hợp vào `ManHinhBaiHocPhatAm`
- Tự động chấm điểm sau khi có kết quả STT
- Hiển thị dialog kết quả chi tiết
- Reset state khi chuyển bài

## 🎨 Màu sắc và Biểu tượng

### Điểm số
- 🟢 **Xanh lá** (≥80): Tốt lắm!
- 🟠 **Cam** (60-79): Ổn đấy!
- 🔴 **Đỏ** (<60): Cố gắng thêm!

### Trạng thái từ
- ✅ **Xanh lá** - Từ đúng (correct)
- ⚠️ **Cam** - Từ gần đúng (close)
- ❌ **Đỏ** - Từ sai (wrong)
- ⭕ **Xám** - Từ thiếu (missing)
- ➕ **Tím** - Từ dư (extra)

## 🔧 Cách sử dụng

### 1. Trong màn hình học phát âm
1. Người dùng nghe từ/câu mẫu
2. Nhấn nút ghi âm và đọc
3. STT chuyển giọng nói thành text
4. Nhấn nút **"Chấm điểm phát âm"**
5. Xem kết quả chi tiết trong dialog

### 2. Kết quả hiển thị
- **Điểm số** với vòng tròn progress
- **Thống kê**: Số từ đúng/sai/gần đúng
- **Chi tiết từng từ**: Màu sắc + từ đúng nếu sai
- **Nút phát âm**: Nhấn icon loa bên cạnh từ sai để nghe lại

### 3. Hành động tiếp theo
- **Thử lại**: Reset và ghi âm lại
- **Tiếp tục**: Chuyển sang bài tập tiếp theo

## 📱 Screenshots

```
┌─────────────────────────────────┐
│   Kết quả chấm điểm             │
├─────────────────────────────────┤
│                                 │
│        ╭───────╮                │
│        │  85   │  Tốt lắm! 👏   │
│        │ điểm  │                │
│        ╰───────╯                │
│    Độ chính xác: 87%            │
│                                 │
├─────────────────────────────────┤
│  ✅ Đúng: 7  ❌ Sai: 1  ⚠️ Gần: 2│
├─────────────────────────────────┤
│ Chi tiết từng từ:               │
│                                 │
│ ✅ I  ✅ eat  ⚠️ an 🔊           │
│              → a                │
│ ✅ apple  ✅ every  ✅ day       │
│                                 │
├─────────────────────────────────┤
│  [Thử lại]      [Tiếp tục]     │
└─────────────────────────────────┘
```

## 🔗 API Flow

```
User speaks → STT → Transcript
                        ↓
          Target + Transcript → Backend API
                        ↓
                  Pronunciation Service
                        ↓
                  Analysis Result
                        ↓
                Flutter UI Display
```

## 📦 Packages Used

- `percent_indicator: ^4.2.3` - Circular progress indicator
- `http` - HTTP requests
- `flutter_tts` - Text-to-speech cho gợi ý

## 🚀 Next Steps (Tùy chọn)

- [ ] Lưu lịch sử điểm số
- [ ] Hiển thị biểu đồ tiến bộ
- [ ] So sánh waveform giọng nói
- [ ] Gợi ý luyện tập dựa trên lỗi thường gặp
- [ ] Chế độ thử thách với thời gian

## 🐛 Troubleshooting

### Lỗi thường gặp

1. **Không chấm điểm được**
   - Kiểm tra backend có chạy không
   - Kiểm tra API endpoint trong `api_constants.dart`
   - Xem log console để debug

2. **Điểm số không chính xác**
   - Backend sử dụng Levenshtein distance
   - Đảm bảo STT transcript chính xác
   - Có thể điều chỉnh threshold trong backend

3. **Không phát âm được từ sai**
   - Kiểm tra TTS service đã init chưa
   - Kiểm tra permission microphone
   - Thử phát âm thủ công

## 📝 Code Examples

### Gọi API chấm điểm

```dart
final result = await _pronunciationService.comparePronunciation(
  target: 'I eat an apple every day',
  transcript: 'I eat a apple every day',
);

// result.score: 92.5
// result.accuracy: 85
// result.wordDetails: [...]
```

### Hiển thị kết quả

```dart
PronunciationResultWidget(
  result: pronunciationResult,
  onRetry: () {
    // Logic thử lại
  },
  onNext: () {
    // Logic tiếp tục
  },
)
```

## ✨ Features Checklist

- [x] Hiển thị điểm số với CircularPercentIndicator
- [x] Tô màu từ đúng/sai (RichText)
- [x] Gợi ý phát âm lại từ sai (TTS)
- [x] Thống kê chi tiết
- [x] Dialog kết quả đẹp mắt
- [x] Tích hợp vào bài học phát âm
- [x] Reset state khi chuyển bài
- [x] Loading state khi chấm điểm

## 🎯 Definition of Done (DoD)

✅ Người dùng nhìn thấy rõ mình được bao nhiêu điểm và sai từ nào ngay sau khi nói
✅ Backend API hoạt động ổn định
✅ Frontend hiển thị kết quả trực quan
✅ Không ảnh hưởng đến code/chức năng cũ
✅ Code đã được format và không có lỗi

---

**Tác giả**: GitHub Copilot  
**Ngày hoàn thành**: 6 tháng 12, 2025  
**Version**: 1.0.0
