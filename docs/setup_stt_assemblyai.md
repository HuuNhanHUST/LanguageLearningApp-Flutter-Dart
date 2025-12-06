# Hướng dẫn cấu hình Speech-to-Text (STT) với AssemblyAI

## ⚠️ Lỗi hiện tại
```
Gửi STT thất bại: Exception: ASSEMBLYAI_API_KEY is not configured
```

## 🔧 Cách sửa

### Bước 1: Đăng ký tài khoản AssemblyAI (MIỄN PHÍ)

1. Truy cập: https://www.assemblyai.com/dashboard/signup
2. Đăng ký tài khoản (dùng email hoặc Google/GitHub)
3. Xác nhận email

### Bước 2: Lấy API Key

1. Đăng nhập vào: https://www.assemblyai.com/dashboard
2. Vào mục **"API Keys"** hoặc **"Settings"**
3. Copy **API Key** (dạng: `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`)

### Bước 3: Cấu hình Backend

1. Mở file `backend/.env`
2. Tìm dòng:
   ```
   ASSEMBLYAI_API_KEY=your-assemblyai-api-key-here
   ```
3. Thay thế bằng API key thực:
   ```
   ASSEMBLYAI_API_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   ```
4. **Lưu file**

### Bước 4: Khởi động lại Backend

```bash
cd backend
node server.js
```

Hoặc nếu đang chạy, **Ctrl+C** rồi chạy lại.

---

## ✅ Kiểm tra hoạt động

Sau khi cấu hình xong:

1. Mở app Flutter
2. Vào màn hình **"Phát âm"**
3. Nhấn nút ghi âm 🎙️
4. Đọc câu ví dụ
5. Nhấn dừng → Đợi STT xử lý
6. Sẽ thấy:
   - ✅ "Đã ghi âm thành công!"
   - 📝 "Kết quả STT: ..."
   - 🎯 Nút **"Chấm điểm phát âm"**

---

## 🆓 Giới hạn Free Tier

AssemblyAI Free Plan:
- ✅ **3 giờ STT miễn phí mỗi tháng**
- ✅ Đủ để phát triển và test
- ✅ Không cần thẻ tín dụng

Nếu hết quota:
- Chờ tháng sau
- Hoặc upgrade plan (nếu cần)

---

## 🔐 Bảo mật API Key

⚠️ **QUAN TRỌNG**:
- ❌ **KHÔNG** commit file `.env` lên GitHub
- ✅ File `.env` đã được thêm vào `.gitignore`
- ✅ API key được lưu trên server, không gửi về client

---

## 🧪 Test thủ công STT API

Nếu muốn test API trực tiếp:

```bash
cd backend
node
```

Trong Node REPL:
```javascript
require('dotenv').config();
console.log('API Key:', process.env.ASSEMBLYAI_API_KEY);
// Nếu hiện "your-assemblyai-api-key-here" → chưa cấu hình
// Nếu hiện chuỗi dài → OK
```

---

## 🐛 Troubleshooting

### Lỗi 1: "ASSEMBLYAI_API_KEY is not configured"
- ✅ Kiểm tra file `.env` có key chưa
- ✅ Khởi động lại backend
- ✅ Đảm bảo không có khoảng trắng thừa

### Lỗi 2: "Unauthorized" / 401
- ❌ API key không hợp lệ
- ✅ Copy lại key từ dashboard
- ✅ Kiểm tra không copy nhầm

### Lỗi 3: "Quota exceeded"
- ⏰ Đã dùng hết 3 giờ miễn phí
- ✅ Chờ tháng sau
- ✅ Hoặc upgrade plan

### Lỗi 4: File âm thanh quá lớn
- ⚠️ AssemblyAI giới hạn file size
- ✅ Backend đã giới hạn thời gian ghi âm
- ✅ Nén file trước khi upload (nếu cần)

---

## 🎯 Luồng hoạt động

```
User speaks → Flutter records → .m4a file
                                    ↓
                        Upload to Backend (multipart/form-data)
                                    ↓
                        Backend → AssemblyAI API
                                    ↓
                        Transcript text returned
                                    ↓
                        Flutter displays result
                                    ↓
                User clicks "Chấm điểm phát âm"
                                    ↓
                Backend Pronunciation Service
                                    ↓
                Score + Word Details + Stats
                                    ↓
                Flutter shows beautiful dialog! 🎉
```

---

## 📝 Alternative: Google Speech-to-Text

Nếu không muốn dùng AssemblyAI, có thể đổi sang:
- Google Cloud Speech-to-Text
- Azure Speech Services
- AWS Transcribe
- OpenAI Whisper API

Nhưng cần cập nhật code trong `backend/src/services/sttService.js`

---

## ✨ Sau khi hoàn thành

Bạn sẽ có đầy đủ tính năng:
- 🎙️ Ghi âm phát âm
- 📝 Chuyển giọng nói thành text (STT)
- 🎯 Chấm điểm tự động
- 📊 Phân tích từng từ đúng/sai
- 🔊 Gợi ý phát âm lại từ sai
- 📈 Thống kê chi tiết

**Happy coding!** 🚀
