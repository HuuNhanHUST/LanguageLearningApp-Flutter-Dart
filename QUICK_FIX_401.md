# ⚡ HƯỚNG DẪN NHANH - Sửa Lỗi 401

## 🎯 Nguyên Nhân

Lỗi 401 xảy ra tại **STT endpoint** (`/api/ai/stt`), không phải pronunciation endpoint.

App bị "chặn" ngay khi upload audio → Không đến được bước chấm điểm.

---

## 🚀 CÁCH 1: DEBUG (Tìm Nguyên Nhân Chính Xác)

### 1. Hot Restart App
Trong terminal đang chạy `flutter run`, nhấn: **`r`**

### 2. Test và Đọc Logs
1. Login
2. Vào màn Phát âm → Ghi âm → "Đã ghi âm thành công!"
3. **Mở Debug Console** trong VS Code
4. Tìm các dòng:
   ```
   🎤 STT Token exists: ???
   🎤 Response Status: ???
   🎤 Response Data: ???
   ```

### 3. Gửi Logs Cho Tôi
Copy toàn bộ logs → Tôi sẽ biết nguyên nhân chính xác

---

## 🔧 CÁCH 2: FIX NHANH (Test Ngay)

### Tạm Bỏ Auth Cho STT (Chỉ để test!)

**File**: `backend/src/routes/aiRoutes.js`

```javascript
router.post(
  '/stt',
  // auth,  ← Comment dòng này
  upload.single('audio'),
  aiController.transcribeAudio,
);
```

**Restart backend**:
```powershell
cd backend
# Ctrl+C rồi:
node server.js
```

**Hot Restart app**: Nhấn `r`

**Test lại**: Ghi âm → Sẽ thành công → Chấm điểm OK!

⚠️ **Sau khi test xong nhớ bật lại `auth`!**

---

## 🎯 Chọn Cách Nào?

- **CÁCH 1** nếu muốn tìm và sửa đúng nguyên nhân
- **CÁCH 2** nếu muốn test chức năng chấm điểm ngay lập tức

---

**Tác giả**: GitHub Copilot  
**Ngày**: 6 tháng 12, 2025
