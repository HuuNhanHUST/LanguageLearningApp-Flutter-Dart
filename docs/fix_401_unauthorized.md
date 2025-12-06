# 🔐 Sửa lỗi 401 Unauthorized

## ❌ Lỗi bạn đang gặp

```
Gửi STT thất bại: Exception: Request failed with status code 401
```

**Nguyên nhân**: Token xác thực (JWT) đã hết hạn hoặc không hợp lệ.

---

## ✅ GIẢI PHÁP

### Cách 1: Đăng xuất và Đăng nhập lại (Nhanh nhất)

1. Trong app, nhấn **Menu** (hoặc icon profile)
2. Chọn **"Đăng xuất"**
3. Đăng nhập lại với tài khoản của bạn
4. Token mới sẽ được tạo → Vấn đề giải quyết! ✅

---

### Cách 2: Kiểm tra cấu hình Backend

#### Bước 1: Kiểm tra JWT_SECRET

Mở file `backend/.env`:

```properties
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRE=30d
```

Đảm bảo:
- ✅ `JWT_SECRET` có giá trị (không trống)
- ✅ `JWT_EXPIRE` là `30d` (30 ngày)

#### Bước 2: Khởi động lại Backend

Nếu bạn vừa sửa `.env`, cần restart:

```powershell
cd backend
# Ctrl+C để dừng
node server.js
```

---

### Cách 3: Test Token trong Postman

#### Test login để lấy token mới:

**POST** `http://localhost:5000/api/users/login`

**Body** (JSON):
```json
{
  "email": "your-email@example.com",
  "password": "your-password"
}
```

**Response thành công**:
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": { ... }
  }
}
```

Copy `token` và test API pronunciation:

**POST** `http://localhost:5000/api/pronunciation/compare`

**Headers**:
```
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Body**:
```json
{
  "target": "Hello world",
  "transcript": "Hello world"
}
```

Nếu response 200 → Token OK, vấn đề ở app.
Nếu vẫn 401 → Vấn đề ở backend.

---

## 🔍 Debug Chi Tiết

### Kiểm tra Token trong Flutter App

Thêm code debug vào `pronunciation_service.dart`:

```dart
Future<PronunciationResultModel> comparePronunciation({
  required String target,
  required String transcript,
}) async {
  final token = await _authService.getAccessToken();
  
  // 🔍 DEBUG: In token ra console
  print('🔑 Token: ${token?.substring(0, 20)}...');
  
  if (token == null) {
    throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
  }
  
  // ...existing code...
}
```

Sau đó check console khi chạy app:
- Nếu in ra `🔑 Token: null` → Chưa đăng nhập
- Nếu in ra `🔑 Token: eyJhbGciOiJIUzI1...` → Token có tồn tại

### Kiểm tra Response Error

Sửa catch block để xem chi tiết lỗi:

```dart
} catch (e) {
  print('❌ Error details: $e'); // In chi tiết lỗi
  print('📝 Response: ${response.body}'); // In response body
  
  final error = jsonDecode(response.body) as Map<String, dynamic>;
  throw Exception(error['message'] ?? 'Lỗi kết nối máy chủ');
}
```

---

## 🛠️ Sửa Lỗi Thường Gặp

### Lỗi 1: "Token has expired"
**Nguyên nhân**: Token đã quá 30 ngày.
**Giải pháp**: Đăng xuất và đăng nhập lại.

### Lỗi 2: "Invalid token"
**Nguyên nhân**: Token bị sai hoặc JWT_SECRET thay đổi.
**Giải pháp**: 
1. Kiểm tra `JWT_SECRET` trong `.env`
2. Nếu vừa đổi → Đăng nhập lại
3. Nếu không → Clear app data và đăng nhập

### Lỗi 3: "User not found"
**Nguyên nhân**: User đã bị xóa khỏi database.
**Giải pháp**: Đăng ký lại tài khoản mới.

### Lỗi 4: "Account has been deactivated"
**Nguyên nhân**: Tài khoản bị vô hiệu hóa.
**Giải pháp**: Liên hệ admin hoặc tạo tài khoản mới.

---

## 🔄 Flow Authentication Đúng

```
User opens app
    ↓
Check token in SecureStorage
    ↓
Token exists? → Validate with backend
    ↓
Valid (200) → Continue using app
    ↓
Invalid (401) → Show login screen
    ↓
User logs in → Get new token
    ↓
Save token → Continue using app
```

---

## ✅ Checklist Giải Quyết

- [ ] Đã thử đăng xuất và đăng nhập lại?
- [ ] Backend đang chạy? (`http://localhost:5000/api/health`)
- [ ] JWT_SECRET có trong `.env`?
- [ ] Token có được lưu trong app? (check SecureStorage)
- [ ] Test API với Postman thành công?
- [ ] Console có hiển thị lỗi chi tiết?

---

## 📝 Lưu Ý Quan Trọng

1. **Token hết hạn là BÌNHnhư THƯỜNG**: Sau 30 ngày, user phải đăng nhập lại.

2. **Không lưu password**: App chỉ lưu token, không lưu password.

3. **Secure Storage**: Token được lưu an toàn trong `flutter_secure_storage`.

4. **Auto logout**: Khi gặp 401, app nên tự động:
   - Xóa token cũ
   - Chuyển về màn hình login
   - Thông báo cho user

---

## 🚀 Sau Khi Sửa Xong

Khi đã đăng nhập lại với token mới:

1. ✅ Vào màn hình Phát âm
2. ✅ Ghi âm một câu
3. ✅ Đợi STT chuyển đổi (cần ASSEMBLYAI_API_KEY)
4. ✅ Nhấn "Chấm điểm phát âm"
5. ✅ Xem kết quả chi tiết! 🎉

---

**Tóm lại**: Lỗi 401 là do token hết hạn. Giải pháp đơn giản nhất: **Đăng xuất và đăng nhập lại**!
