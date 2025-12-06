# ⚠️ NHỚ BẬT LẠI AUTH SAU KHI TEST!

## 📝 File Cần Sửa Lại

**File**: `backend/src/routes/aiRoutes.js`

### Code Hiện Tại (TẠM THỜI):
```javascript
router.post(
  '/stt',
  // auth,  // ⚠️ TẠM THỜI comment để test - NHỚ BẬT LẠI SAU!
  upload.single('audio'),
  aiController.transcribeAudio,
);
```

### Code ĐÚNG (Sau khi test xong):
```javascript
router.post(
  '/stt',
  auth,  // ✅ ĐÃ BẬT LẠI
  upload.single('audio'),
  aiController.transcribeAudio,
);
```

---

## 🔧 Cách Bật Lại

1. Mở file `backend/src/routes/aiRoutes.js`
2. Bỏ comment (`//`) ở dòng `auth,`
3. Save file
4. Restart backend: `Ctrl+C` → `node server.js`

---

## ❌ Tại Sao Phải Bật Lại?

Hiện tại **BẤT KỲ AI** cũng có thể upload audio lên server mà không cần đăng nhập!

→ Tốn tài nguyên AssemblyAI (API có giới hạn miễn phí)  
→ Không an toàn  
→ Không track được ai dùng  

**Chỉ dùng tạm để test chức năng!**

---

**Tác giả**: GitHub Copilot  
**Ngày**: 6 tháng 12, 2025
