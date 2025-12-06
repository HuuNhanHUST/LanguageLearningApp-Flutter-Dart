# 🎯 TÌM RA NGUYÊN NHÂN LỖI 401!

## ❌ Phát Hiện Mới

Lỗi 401 **KHÔNG PHẢI** từ Pronunciation API mà từ **STT Service**!

### Luồng Thực Thi:
```
1. Nhấn mic ghi âm ✅
2. Nhấn "Đã ghi âm thành công!" ✅
3. App upload audio → /ai/stt ❌ 401 ERROR
4. Show "Gửi STT thất bại: Request failed with status code 401"
5. KHÔNG BAO GIỜ đến bước chấm điểm ❌
```

### Nguyên Nhân:
- Endpoint `/api/ai/stt` **YÊU CẦU authentication**
- Token đang bị backend reject (lý do chưa rõ)
- Có thể: JWT_SECRET khác nhau, token expired, hoặc auth middleware sai

---

## 🔍 ĐÃ THÊM DEBUG LOGS MỚI

File: `lib/services/stt_service.dart`

### Logs mới:
```
🎤 STT Token exists: true/false
🎤 STT Token preview: eyJhbG...
🎤 POST http://192.168.1.2:5000/api/ai/stt
🎤 Audio file: audio_20231206_182100.aac
🎤 Target text: I eat an apple every day
🎤 Response Status: 401/200
🎤 Response Data: {...}
```

---

## 🚀 HƯỚNG DẪN DEBUG MỚI

### Bước 1: Hot Restart App
```powershell
# Trong VS Code, nhấn:
r (trong terminal đang chạy flutter run)
# HOẶC
Shift + F5 để dừng, rồi F5 để chạy lại
```

### Bước 2: Test Luồng Hoàn Chỉnh
1. **Login** với tài khoản mới (hoặc test@example.com)
2. **Vào màn hình Phát âm**
3. **Nhấn mic** → Ghi âm → Dừng
4. **Nhấn "Đã ghi âm thành công!"**
5. **MỞ Debug Console** và đọc logs!

### Bước 3: Đọc Logs Theo Thứ Tự

#### Khi Login:
```
🔐 Login Request to: http://192.168.1.2:5000/api/users/login
🔐 Login Response Status: 200
🔐 Token saved
```
✅ Nếu thấy → Login thành công

#### Khi Upload Audio (STT):
```
🎤 STT Token exists: true
🎤 STT Token preview: eyJhbG...
🎤 POST http://192.168.1.2:5000/api/ai/stt
🎤 Response Status: ???
```

**Quan trọng**: Kiểm tra `Response Status`
- **401** → Token bị reject → Đọc tiếp Response Data để biết lý do
- **200** → STT thành công → Sẽ đến bước chấm điểm

#### Nếu STT thành công, sẽ thấy logs tiếp:
```
🔑 Token exists: true
🔑 Token preview: eyJhbG...
📤 POST http://192.168.1.2:5000/api/pronunciation/compare
📥 Response Status: ???
```

---

## 🔧 KIỂM TRA BACKEND

### Test 1: Kiểm tra endpoint STT
```powershell
cd backend
node
```

Trong Node REPL:
```javascript
const axios = require('axios');

// Lấy token (thay YOUR_TOKEN bằng token thật)
const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';

// Test STT endpoint
axios.post('http://localhost:5000/api/ai/stt', 
  { /* FormData */ },
  { headers: { Authorization: `Bearer ${token}` } }
).then(res => console.log('✅', res.status))
  .catch(err => console.log('❌', err.response?.status, err.response?.data));
```

### Test 2: Kiểm tra auth middleware
File: `backend/src/routes/aiRoutes.js`

Xem có dòng này không:
```javascript
router.post('/stt', auth, upload.single('audio'), aiController.speechToText);
```

Nếu **KHÔNG CÓ `auth`** → Đây là nguyên nhân! Phải thêm middleware auth.

Nếu **CÓ `auth`** → Vấn đề là token bị reject, cần check JWT_SECRET.

---

## 🐛 CÁC TRƯỜNG HỢP THƯỜNG GẶP

### Case 1: Token Null
```
🎤 STT Token exists: false
```
**Nguyên nhân**: Token không được lưu sau login.
**Giải pháp**: Check `auth_service.dart` → `_saveAuthData()`

### Case 2: Token Expired
```
🎤 Response Status: 401
🎤 Response Data: {"success":false,"message":"Token has expired"}
```
**Nguyên nhân**: Token hết hạn (JWT_EXPIRATION).
**Giải pháp**: Đăng nhập lại.

### Case 3: Invalid Token (JWT_SECRET sai)
```
🎤 Response Status: 401
🎤 Response Data: {"success":false,"message":"Invalid token"}
```
**Nguyên nhân**: Backend đổi JWT_SECRET nhưng app dùng token cũ.
**Giải pháp**: 
1. Xóa app khỏi điện thoại
2. Cài lại
3. Đăng nhập mới

### Case 4: User Not Found
```
🎤 Response Status: 401
🎤 Response Data: {"success":false,"message":"User not found"}
```
**Nguyên nhân**: User bị xóa khỏi database.
**Giải pháp**: Tạo tài khoản mới.

### Case 5: Auth Middleware Chặn
```
🎤 Response Status: 401
🎤 Response Data: {"success":false,"message":"No token provided"}
```
**Nguyên nhân**: Header không có Authorization hoặc format sai.
**Giải pháp**: Check code STT service (đã fix rồi).

---

## ✅ GIẢI PHÁP TẠM THỜI: BỎ AUTH CHO STT

Nếu muốn test **CHỨC NĂNG CHẤM ĐIỂM** trước, có thể tạm thời **BỎ AUTH** cho endpoint STT:

### File: `backend/src/routes/aiRoutes.js`

**Tìm dòng:**
```javascript
router.post('/stt', auth, upload.single('audio'), aiController.speechToText);
```

**Sửa thành (tạm thời):**
```javascript
router.post('/stt', upload.single('audio'), aiController.speechToText);
// ↑ Đã bỏ auth middleware
```

**Lưu ý**: 
- ⚠️ Chỉ để test, KHÔNG dùng production!
- ⚠️ Sau khi test xong phải bỏ lại `auth` vào!
- ✅ Cách này giúp test được chức năng chấm điểm ngay

---

## 📊 CHECKLIST DEBUG

Trước khi test:

- [ ] Backend đang chạy
- [ ] App đã Hot Restart (hoặc cài lại)
- [ ] Debug Console đã mở
- [ ] Đã đăng nhập tài khoản mới
- [ ] Sẵn sàng đọc logs (🎤 và 🔑 📤 📥)

Khi thấy lỗi:

- [ ] Copy **TOÀN BỘ** logs từ Console
- [ ] Tìm dòng `🎤 Response Status: ???`
- [ ] Tìm dòng `🎤 Response Data: {...}`
- [ ] Gửi cho tôi để phân tích

---

## 📸 Logs Mong Đợi (Thành Công)

```
[Login]
🔐 Login Response Status: 200
✅ Token saved

[Ghi âm xong, upload STT]
🎤 STT Token exists: true
🎤 STT Token preview: eyJhbGciOiJIUzI1...
🎤 POST http://192.168.1.2:5000/api/ai/stt
🎤 Audio file: audio_20231206.aac
🎤 Response Status: 200
🎤 Response Data: {"success":true,"data":{"transcript":"I eat an apple every day"}}

[Chấm điểm]
🔑 Token exists: true
📤 POST http://192.168.1.2:5000/api/pronunciation/compare
📥 Response Status: 200
📥 Response Body: {"success":true,"data":{"score":92.31,...}}

✅ HOÀN TOÀN THÀNH CÔNG!
```

---

## 🎯 KẾT LUẬN

**Lỗi thực sự**: Token bị reject tại endpoint `/api/ai/stt` (STT), không phải endpoint chấm điểm.

**Bước tiếp theo**: 
1. Hot Restart app
2. Test và gửi logs cho tôi
3. Hoặc tạm bỏ `auth` middleware để test chấm điểm trước

**Tác giả**: GitHub Copilot  
**Ngày**: 6 tháng 12, 2025  
**Status**: 🔍 Đã tìm ra nguyên nhân, đang chờ logs
