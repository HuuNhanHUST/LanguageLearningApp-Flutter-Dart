# 🔍 DEBUG LỖI 401 - HƯỚNG DẪN CHI TIẾT

## ✅ Backend API HOẠT ĐỘNG TỐT!

Tôi đã test backend:
- ✅ Login thành công → Token được tạo
- ✅ Pronunciation API sẵn sàng
- ✅ Auth middleware hoạt động

**VẬY LỖI 401 Ở ĐÂU?** → **Ở Flutter App!**

---

## 🎯 NGUYÊN NHÂN VÀ GIẢI PHÁP

### Vấn đề 1: Token không được gửi đúng

Mở **Flutter DevTools Console** và xem log khi bạn nhấn "Chấm điểm":

```
🔑 Token exists: true/false     ← Kiểm tra dòng này
🔑 Token preview: eyJhbGciOiJ... ← Token có hiện không?
📤 POST http://192.168.1.2:5000/api/pronunciation/compare
📋 Headers: {Content-Type: application/json, Authorization: Bearer ...}
📦 Body: {"target":"...","transcript":"..."}
📥 Response Status: 401          ← Nếu vẫn 401
📥 Response Body: {...}          ← Xem message lỗi
```

#### Nếu thấy `Token exists: false`:
**Vấn đề**: Token không được lưu sau khi login.

**Giải pháp**:
1. Kiểm tra AuthService có lưu token không
2. Xem file `lib/features/auth/services/auth_service.dart`
3. Method `_saveAuthData()` phải lưu vào SecureStorage

#### Nếu thấy `Token exists: true` nhưng vẫn 401:
**Vấn đề**: Token bị sai format hoặc JWT_SECRET khác nhau.

**Giải pháp**:
1. Kiểm tra `backend/.env` → `JWT_SECRET`
2. Nếu vừa thay đổi JWT_SECRET → **Đăng nhập lại**
3. Token cũ sẽ không hợp lệ với SECRET mới

---

### Vấn đề 2: URL sai

Kiểm tra `api_constants.dart`:

```dart
static const String baseUrl = 'http://192.168.1.2:5000/api';
```

#### Test URL đúng không:

1. Mở browser trên điện thoại/emulator
2. Truy cập: `http://192.168.1.2:5000/api/health`
3. Nếu không mở được → **Sai URL**

**Sửa**:
- Android Emulator: `http://10.0.2.2:5000/api`
- Physical Device: `http://<IP máy tính>:5000/api`
- Tìm IP: `ipconfig` (Windows) → IPv4 Address

---

### Vấn đề 3: Headers không đúng format

Kiểm tra `api_constants.dart`:

```dart
static Map<String, String> getHeaders({String? token}) {
  final headers = {'Content-Type': 'application/json'};
  
  if (token != null) {
    headers['Authorization'] = 'Bearer $token'; // ← PHẢI CÓ "Bearer "
  }
  
  return headers;
}
```

**Lưu ý**: Phải có khoảng trắng sau "Bearer"!
- ✅ Đúng: `Bearer eyJhbGciOiJ...`
- ❌ Sai: `Bearereyأب

JhbGciOiJ...`
- ❌ Sai: `eyJhbGciOiJ...` (thiếu "Bearer")

---

## 🛠️ CÁCH DEBUG TỪNG BƯỚC

### Bước 1: Enable Debug Logs

Tôi đã thêm debug logs vào `pronunciation_service.dart`. Giờ:

1. **Hot Restart** Flutter app
2. Login vào app
3. Vào màn hình Phát âm
4. Ghi âm (hoặc nhấn nút test nếu còn)
5. Nhấn "Chấm điểm"
6. Xem **Console** trong VS Code / Android Studio

### Bước 2: Đọc Logs

Bạn sẽ thấy:

```
🔑 Token exists: true
🔑 Token preview: eyJhbGciOiJIUzI1NiI...
📤 POST http://192.168.1.2:5000/api/pronunciation/compare
📋 Headers: {Content-Type: application/json, Authorization: Bearer eyJ...}
📦 Body: {"target":"I eat an apple every day","transcript":"I eat a apple every day"}
📥 Response Status: 401
📥 Response Body: {"success":false,"message":"Token has expired"}
❌ Error message: Token has expired
```

Dựa vào message, bạn biết chính xác lỗi gì!

### Bước 3: Sửa theo Message

| Message Lỗi | Nguyên Nhân | Giải Pháp |
|-------------|-------------|-----------|
| Token has expired | Token hết hạn | Đăng xuất + Đăng nhập lại |
| Invalid token | Token sai format | Check JWT_SECRET, đăng nhập lại |
| User not found | User bị xóa | Tạo user mới |
| Access denied. No token provided | Token không được gửi | Check getHeaders() |
| Invalid token format | Thiếu "Bearer " | Sửa getHeaders() |

---

## 📋 CHECKLIST DEBUG

Làm theo thứ tự:

- [ ] **1. Backend đang chạy?**
  ```powershell
  cd backend
  node server.js
  ```
  
- [ ] **2. URL đúng?**
  - Browser trên điện thoại: `http://192.168.1.2:5000/api/health`
  - Thấy `{"status":"OK"}` → Đúng
  - Không mở được → Sửa IP

- [ ] **3. Đã đăng nhập lại?**
  - Đăng xuất
  - Đăng nhập với tài khoản MỚI vừa tạo
  - (Hoặc tài khoản cũ nếu chắc còn trong DB)

- [ ] **4. Xem logs trong Console?**
  - Hot Restart app
  - Thử chấm điểm
  - Đọc logs

- [ ] **5. Token có tồn tại?**
  - Xem log: `🔑 Token exists: true/false`
  - Nếu false → Vấn đề ở login/storage

- [ ] **6. Response 401 message là gì?**
  - Xem log: `❌ Error message: ...`
  - Sửa theo bảng trên

---

## 🎯 GIẢI PHÁP NHANH NHẤT

**90% trường hợp lỗi 401 sau khi tạo tài khoản mới là do:**

### 1. **JWT_SECRET khác nhau**

Backend có thể đã khởi động lại với JWT_SECRET mới:

**Sửa**:
```powershell
# Dừng backend (Ctrl+C)
# Xóa file .env cũ, tạo lại
cd backend
node server.js
```

Sau đó **ĐỔI TÀI KHOẢN KHÁC** đăng nhập (hoặc tạo mới).

### 2. **Token từ app cũ**

App có thể đang dùng token của lần đăng nhập trước.

**Sửa**:
1. **Uninstall app** hoàn toàn
2. **Install lại**
3. Đăng nhập với tài khoản mới

### 3. **Cache issues**

Flutter có thể cache network requests.

**Sửa**:
```powershell
cd languagelearningapp
flutter clean
flutter pub get
flutter run
```

---

## 🚀 TEST CUỐI CÙNG

Sau khi làm theo các bước trên:

1. ✅ Uninstall app
2. ✅ `flutter clean && flutter pub get`
3. ✅ Restart backend: `node server.js`
4. ✅ `flutter run`
5. ✅ Tạo tài khoản MỚI trong app
6. ✅ Login
7. ✅ Vào màn hình Phát âm
8. ✅ Ghi âm
9. ✅ Xem Console logs
10. ✅ Nhấn "Chấm điểm"

Nếu vẫn lỗi → **Gửi cho tôi TOÀN BỘ logs trong Console!**

---

## 📸 Logs Mẫu Thành Công

```
🔐 Login Request to: http://192.168.1.2:5000/api/users/login
🔐 Login Response Status: 200
🔐 Login Response Body: {"success":true,"message":"Login successful","data":{"token":"eyJ..."}}
✅ Saved token to SecureStorage

🔑 Token exists: true
🔑 Token preview: eyJhbGciOiJIUzI1NiI...
📤 POST http://192.168.1.2:5000/api/pronunciation/compare
📋 Headers: {Content-Type: application/json, Authorization: Bearer eyJ...}
📦 Body: {"target":"I eat an apple every day","transcript":"I eat a apple every day"}
📥 Response Status: 200
📥 Response Body: {"success":true,"data":{"score":92.31,"accuracy":85,...}}
✅ Chấm điểm thành công!
```

---

**TÓM LẠI**: Backend OK! Vấn đề ở Flutter app. Làm theo checklist trên sẽ tìm ra nguyên nhân!
