# Script Test Chấm Điểm Phát Âm (không cần STT)

## 🎯 Mục đích
Test tính năng chấm điểm phát âm NGAY LẬP TỨC mà không cần:
- ❌ AssemblyAI API Key
- ❌ Ghi âm thật
- ❌ STT service

## 🚀 Cách test

### Option 1: Test trực tiếp Backend API

```bash
cd backend
node
```

Trong Node REPL:
```javascript
const pronunciationService = require('./src/services/pronunciationService');

// Test 1: Câu hoàn hảo
const result1 = pronunciationService.analyzePronunciation(
  'I eat an apple every day',
  'I eat an apple every day'
);
console.log('Test 1 (Perfect):', result1);
// Expected: score: 100, accuracy: 100%

// Test 2: Câu có 1 lỗi
const result2 = pronunciationService.analyzePronunciation(
  'I eat an apple every day',
  'I eat a apple every day'
);
console.log('Test 2 (1 error):', result2);
// Expected: score: ~92, một từ sai ('a' thay vì 'an')

// Test 3: Câu nhiều lỗi
const result3 = pronunciationService.analyzePronunciation(
  'I eat an apple every day',
  'I eating apple everyday'
);
console.log('Test 3 (Multiple errors):', result3);
// Expected: score: ~60-70, nhiều từ sai

process.exit();
```

### Option 2: Test bằng Postman/cURL

**Endpoint**: `POST http://localhost:5000/api/pronunciation/compare`

**Headers**:
```
Content-Type: application/json
Authorization: Bearer YOUR_JWT_TOKEN
```

**Body** (JSON):
```json
{
  "target": "I eat an apple every day",
  "transcript": "I eat a apple every day"
}
```

**Response**:
```json
{
  "success": true,
  "message": "Pronunciation analysis completed",
  "data": {
    "score": 92.31,
    "accuracy": 85,
    "target": "i eat an apple every day",
    "transcript": "i eat a apple every day",
    "wordDetails": [
      {
        "word": "i",
        "status": "correct",
        "position": 0
      },
      {
        "word": "eat",
        "status": "correct",
        "position": 1
      },
      {
        "word": "a",
        "expected": "an",
        "status": "close",
        "similarity": 50,
        "position": 2
      },
      {
        "word": "apple",
        "status": "correct",
        "position": 3
      },
      {
        "word": "every",
        "status": "correct",
        "position": 4
      },
      {
        "word": "day",
        "status": "correct",
        "position": 5
      }
    ],
    "stats": {
      "totalWords": 6,
      "correctWords": 5,
      "wrongWords": 0,
      "closeWords": 1,
      "missingWords": 0,
      "extraWords": 0
    }
  }
}
```

### Option 3: Thêm nút Test vào Flutter App

Thêm code tạm vào `man_hinh_bai_hoc_phat_am.dart`:

```dart
// Thêm trong widget _xayDungKhuVucGhiAm, sau phần "Câu mẫu cần đọc"

// 🧪 NÚT TEST DEMO (xóa sau khi test xong)
const SizedBox(height: 12),
ElevatedButton.icon(
  onPressed: () {
    // Giả lập có transcript
    _chamDiemPhatAm(
      target: targetText,
      transcript: 'I eat a apple every day', // Giả lập lỗi
    );
  },
  icon: const Icon(Icons.science),
  label: const Text('🧪 Test Chấm Điểm (Demo)'),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.orange,
    foregroundColor: Colors.white,
  ),
),
```

Sau đó:
1. Run app
2. Vào màn hình Phát âm
3. Nhấn nút **"🧪 Test Chấm Điểm (Demo)"**
4. Xem kết quả chấm điểm ngay lập tức!

---

## 📊 Kịch bản test

### Test Case 1: Perfect Score
```
Target: "Hello world"
Transcript: "Hello world"
Expected: 100 điểm, tất cả từ màu xanh
```

### Test Case 2: One Wrong Word
```
Target: "I eat an apple"
Transcript: "I eat a apple"
Expected: ~90 điểm, "a" màu cam/đỏ, còn lại xanh
```

### Test Case 3: Multiple Errors
```
Target: "The cat is sleeping"
Transcript: "The dog was sleep"
Expected: ~50-60 điểm, nhiều từ đỏ
```

### Test Case 4: Missing Words
```
Target: "I love you very much"
Transcript: "I love you"
Expected: ~60 điểm, 2 từ thiếu
```

### Test Case 5: Extra Words
```
Target: "Good morning"
Transcript: "Good morning everyone"
Expected: ~80 điểm, 1 từ dư
```

---

## 🎨 Kết quả mong đợi trên UI

Sau khi nhấn "Chấm điểm phát âm", bạn sẽ thấy dialog với:

✅ **Điểm số**: Vòng tròn với số điểm (0-100)
- Màu xanh nếu ≥80
- Màu cam nếu 60-79
- Màu đỏ nếu <60

✅ **Thống kê**:
- ✔️ Đúng: X từ (màu xanh)
- ❌ Sai: X từ (màu đỏ)
- ⚠️ Gần đúng: X từ (màu cam)

✅ **Chi tiết từng từ**:
- Từ đúng: nền xanh nhạt, viền xanh
- Từ sai: nền đỏ nhạt, viền đỏ, có icon 🔊 để nghe lại
- Từ gần đúng: nền cam nhạt, viền cam, có icon 🔊

✅ **Hai nút**:
- [Thử lại]: Reset và thử lại
- [Tiếp tục]: Chuyển bài tiếp theo

---

## 🔍 Debug checklist

Nếu không thấy dialog:
- [ ] Kiểm tra console có lỗi không
- [ ] Kiểm tra backend có chạy không (`http://localhost:5000/api/health`)
- [ ] Kiểm tra method `_chamDiemPhatAm` có được gọi không (thêm print)
- [ ] Kiểm tra import PronunciationResultWidget
- [ ] Kiểm tra package percent_indicator đã install chưa

Nếu dialog hiện nhưng không có dữ liệu:
- [ ] Check response từ API (dùng Flutter DevTools)
- [ ] Check model parsing (thử print result)
- [ ] Check widget có nhận đúng data không

---

## ✨ Sau khi test xong

1. **Xóa nút Test Demo** khỏi code (nếu đã thêm)
2. **Cấu hình AssemblyAI** để có STT thật
3. **Test flow hoàn chỉnh**: Ghi âm → STT → Chấm điểm
4. **Enjoy!** 🎉

---

**Lưu ý**: Tính năng chấm điểm hoạt động HOÀN TOÀN ĐỘC LẬP với STT. Bạn có thể test ngay mà không cần AssemblyAI!
