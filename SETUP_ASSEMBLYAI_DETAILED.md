# 🔑 HƯỚNG DẪN CHI TIẾT: Lấy AssemblyAI API Key

## 📋 Tổng Quan

AssemblyAI là dịch vụ chuyển giọng nói thành văn bản (Speech-to-Text).  
App cần API key này để có thể ghi nhận phát âm của bạn.

**Miễn phí**: 100 giờ transcribe/tháng (đủ để test!)

---

## 🚀 BƯỚC 1: Đăng Ký Tài Khoản

### 1.1. Truy cập trang đăng ký
Mở trình duyệt và vào: **https://www.assemblyai.com/dashboard/signup**

### 1.2. Điền thông tin
- **Email**: Dùng email thật của bạn
- **Password**: Tạo mật khẩu mạnh
- **Full Name**: Tên của bạn
- **Company** (optional): Có thể bỏ trống hoặc ghi "Personal"

### 1.3. Nhấn "Sign Up"
- Kiểm tra email xác nhận
- Click link trong email để xác nhận tài khoản

---

## 🔑 BƯỚC 2: Lấy API Key

### 2.1. Đăng nhập
Sau khi xác nhận email, đăng nhập vào: **https://www.assemblyai.com/dashboard**

### 2.2. Tìm API Key
Bạn sẽ thấy trang Dashboard với:
- Sidebar bên trái có menu
- Click vào **"Settings"** hoặc **"API Keys"**
- Hoặc trực tiếp vào: https://www.assemblyai.com/app/account

### 2.3. Copy API Key
Bạn sẽ thấy:
```
Your API Key
[xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx]  [Copy]
```

Nhấn nút **Copy** hoặc chọn và copy toàn bộ chuỗi.

**Ví dụ API key**:
```
12a34b56c78d90e12f34g56h78i90j12
```
(Đây là key giả, key thật dài khoảng 32 ký tự)

---

## ⚙️ BƯỚC 3: Thêm Vào Backend

### 3.1. Mở file .env
Trong VS Code, mở file: `backend/.env`

### 3.2. Tìm dòng ASSEMBLYAI_API_KEY
Bạn sẽ thấy:
```properties
# AssemblyAI Configuration (Speech-to-Text)
# Get your API key from: https://www.assemblyai.com/dashboard/signup
ASSEMBLYAI_API_KEY=your-assemblyai-api-key-here
```

### 3.3. Thay thế bằng key thật
**XÓA** `your-assemblyai-api-key-here`  
**DÁN** key bạn vừa copy từ AssemblyAI

**Ví dụ**:
```properties
ASSEMBLYAI_API_KEY=12a34b56c78d90e12f34g56h78i90j12
```

### 3.4. Save file
**Ctrl + S** hoặc **File > Save**

---

## 🔄 BƯỚC 4: Restart Backend

### 4.1. Dừng backend hiện tại
Trong terminal đang chạy backend:
- Nhấn **Ctrl + C**
- Đợi process dừng hoàn toàn

### 4.2. Chạy lại backend
```powershell
cd backend
node server.js
```

### 4.3. Kiểm tra log
Khi backend khởi động, bạn **KHÔNG** được thấy dòng warning:
```
❌ KHÔNG NÊN THẤY:
[STT] ASSEMBLYAI_API_KEY is missing. Speech-to-text endpoint will fail...
```

Nếu không thấy warning → **Thành công!** ✅

---

## 🧪 BƯỚC 5: Test Lại App

### 5.1. Hot Restart Flutter App
Trong terminal Flutter, nhấn: **r**

### 5.2. Test STT
1. Login vào app
2. Vào "Luyện phát âm cơ bản"
3. Nhấn mic 🎤 → Ghi âm
4. Nhấn "Đã ghi âm thành công!"

### 5.3. Xem logs
Trong **Debug Console**, tìm:
```
🎤 STT Token exists: true
🎤 POST http://192.168.1.2:5000/api/ai/stt
🎤 Response Status: 200  ✅ ← Phải thấy 200!
🎤 Response Data: {"success":true,"data":{"transcript":"I eat an apple every day"}}
```

### 5.4. Xem kết quả chấm điểm
Nếu STT thành công (200) → Sẽ tự động chấm điểm và hiển thị dialog!

```
┌─────────────────────────────────┐
│   Kết quả chấm điểm             │
│        ╭───────╮                │
│        │  95   │  Xuất sắc! 🎉  │
│        │ điểm  │                │
│        ╰───────╯                │
└─────────────────────────────────┘
```

---

## 🐛 TROUBLESHOOTING

### Lỗi 1: "ASSEMBLYAI_API_KEY is not configured"
**Nguyên nhân**: 
- Chưa thay key trong `.env`
- Hoặc backend chưa restart

**Giải pháp**:
1. Kiểm tra file `.env` có key chưa
2. Restart backend: Ctrl+C → `node server.js`

---

### Lỗi 2: "Authentication error" hoặc "Invalid token"
**Nguyên nhân**: API key sai hoặc đã hết hạn

**Giải pháp**:
1. Đăng nhập lại AssemblyAI dashboard
2. Tạo API key mới (nếu cần)
3. Copy key mới vào `.env`
4. Restart backend

---

### Lỗi 3: "Rate limit exceeded"
**Nguyên nhân**: Đã dùng hết 100 giờ miễn phí trong tháng

**Giải pháp**:
- Đợi đến tháng sau (quota reset)
- Hoặc upgrade plan (có phí)
- Hoặc tạo tài khoản mới với email khác

---

### Lỗi 4: Backend vẫn báo warning khi start
```
[STT] ASSEMBLYAI_API_KEY is missing...
```

**Nguyên nhân**: File `.env` không được load

**Kiểm tra**:
1. File `.env` có đúng ở thư mục `backend/` không?
2. Có cài package `dotenv` chưa?
   ```powershell
   cd backend
   npm list dotenv
   ```
3. File `server.js` có load dotenv chưa?
   ```javascript
   require('dotenv').config();
   ```

**Giải pháp**:
```powershell
cd backend
npm install dotenv
```

---

## 📊 Kiểm Tra API Key Đang Hoạt Động

### Test thủ công bằng curl (Windows PowerShell):
```powershell
$headers = @{
    "authorization" = "YOUR_API_KEY_HERE"
}

Invoke-RestMethod -Uri "https://api.assemblyai.com/v2/transcript" `
    -Method Get `
    -Headers $headers
```

Nếu thấy response JSON → API key hợp lệ! ✅

---

## 📸 Screenshot Tham Khảo

### 1. Trang Dashboard AssemblyAI:
```
╔══════════════════════════════════════╗
║  AssemblyAI Dashboard                ║
╠══════════════════════════════════════╣
║  📊 Usage This Month                 ║
║  ├─ Transcribed: 0.5 hours           ║
║  └─ Remaining: 99.5 hours            ║
║                                      ║
║  🔑 API Key                          ║
║  ┌──────────────────────────────┐   ║
║  │ 12a34b56...j12  [Copy] [Hide]│   ║
║  └──────────────────────────────┘   ║
╚══════════════════════════════════════╝
```

### 2. File .env đúng:
```properties
# AssemblyAI Configuration
ASSEMBLYAI_API_KEY=12a34b56c78d90e12f34g56h78i90j12
```
✅ **ĐÚNG**: Không có dấu ngoặc, không có khoảng trắng thừa

❌ **SAI**:
```properties
ASSEMBLYAI_API_KEY="12a34b56c78d90e12f34g56h78i90j12"  ← Không dùng ""
ASSEMBLYAI_API_KEY = 12a34b56c78d90e12f34g56h78i90j12  ← Không có space
ASSEMBLYAI_API_KEY=your-assemblyai-api-key-here       ← Chưa thay key
```

---

## ✅ CHECKLIST HOÀN THÀNH

Đánh dấu khi xong:

- [ ] Đã đăng ký tài khoản AssemblyAI
- [ ] Đã xác nhận email
- [ ] Đã đăng nhập dashboard
- [ ] Đã copy API key
- [ ] Đã mở file `backend/.env`
- [ ] Đã thay `your-assemblyai-api-key-here` bằng key thật
- [ ] Đã save file `.env`
- [ ] Đã restart backend (Ctrl+C → node server.js)
- [ ] Không thấy warning khi backend start
- [ ] Đã hot restart Flutter app (r)
- [ ] Đã test ghi âm
- [ ] Thấy Response Status: 200 trong logs
- [ ] Thấy dialog kết quả chấm điểm!

---

## 🎉 KHI HOÀN THÀNH

Bạn sẽ thấy:

**Debug Console**:
```
🎤 POST http://192.168.1.2:5000/api/ai/stt
🎤 Response Status: 200  ✅
🎤 Response Data: {"success":true,"data":{"transcript":"I eat an apple every day"}}

🔑 Token exists: true
📤 POST http://192.168.1.2:5000/api/pronunciation/compare
📥 Response Status: 200  ✅

✅ Pronunciation scoring successful!
```

**App Screen**:
```
┌─────────────────────────────────┐
│   Kết quả chấm điểm             │
├─────────────────────────────────┤
│        ╭───────╮                │
│        │  92   │  Tốt lắm! 👏   │
│        │ điểm  │                │
│        ╰───────╯                │
│    Độ chính xác: 87%            │
├─────────────────────────────────┤
│  ✅ Đúng: 6  ❌ Sai: 0  ⚠️ Gần: 1│
├─────────────────────────────────┤
│ Chi tiết từng từ:               │
│ [✅ I] [✅ eat] [⚠️ a 🔊]        │
│ [✅ apple] [✅ every] [✅ day]   │
│                                 │
│  [🔁 Thử lại]  [➡️ Tiếp tục]   │
└─────────────────────────────────┘
```

**🎊 CHÚC MỪNG! Bạn đã hoàn thành tính năng chấm điểm phát âm!**

---

## 🔗 Liên Kết Hữu Ích

- AssemblyAI Dashboard: https://www.assemblyai.com/app
- AssemblyAI Docs: https://www.assemblyai.com/docs
- AssemblyAI Pricing: https://www.assemblyai.com/pricing (Free tier: 100 giờ/tháng)

---

**Tác giả**: GitHub Copilot  
**Ngày**: 6 tháng 12, 2025  
**Status**: 📚 Hướng dẫn đầy đủ
