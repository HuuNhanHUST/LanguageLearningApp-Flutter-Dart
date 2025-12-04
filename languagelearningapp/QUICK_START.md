# 🚀 Quick Start Guide - Vocabulary List Screen

## ⚡ Chạy thử ngay (5 phút)

### Bước 1: Start Backend (1 phút)
```powershell
cd backend
npm start
```
✅ Server chạy tại: http://localhost:5000

### Bước 2: Update IP (30 giây)
```powershell
ipconfig
```
Tìm IPv4 address (ví dụ: 192.168.1.9)

Mở file: `lib/core/constants/api_constants.dart`
```dart
static const String baseUrl = 'http://192.168.1.9:5000/api';
```

### Bước 3: Run App (1 phút)
```powershell
cd languagelearningapp
flutter run
```

### Bước 4: Test Feature (2 phút)
1. **Đăng nhập** → Nhập username/password
2. **Thêm từ vựng** → Click tab "Từ điển" → Nhập "hello", "world", "computer"
3. **Xem danh sách** → Click nút "Danh sách" → Màn hình từ vựng xuất hiện! 🎉

---

## 📱 Screenshots Demo

### Màn hình Danh sách Từ vựng
```
┌─────────────────────────────────────┐
│ ←  Từ vựng          [Danh sách]    │  <- AppBar
├─────────────────────────────────────┤
│  Tất cả | Đã thuộc | Chưa thuộc    │  <- Tabs
├─────────────────────────────────────┤
│  📚 Tổng: 42 từ                     │  <- Stats
├─────────────────────────────────────┤
│  ┌───────────────────────────────┐ │
│  │ ☑ Hello                    🗑️ │ │  <- Word Card
│  │   n  Xin chào                │ │
│  │   📝 "Hello, how are you?"   │ │
│  └───────────────────────────────┘ │
│  ┌───────────────────────────────┐ │
│  │ ☐ World                    🗑️ │ │
│  │   n  Thế giới                │ │
│  └───────────────────────────────┘ │
│  ┌───────────────────────────────┐ │
│  │ ☐ Computer                 🗑️ │ │
│  │   n  Máy tính                │ │
│  │   📝 "I use a computer"      │ │
│  └───────────────────────────────┘ │
│  ⭕ Loading more...               │  <- Load more
└─────────────────────────────────────┘
```

---

## 🎮 Features Test Speedrun

### ✅ Test 1: Xem danh sách (10 giây)
- Mở màn hình → Thấy shimmer loading → Danh sách xuất hiện
- **Expected:** Hiển thị từ vựng với đầy đủ thông tin

### ✅ Test 2: Đánh dấu đã thuộc (5 giây)
- Click checkbox → Tick
- **Expected:** Snackbar "Đã đánh dấu thuộc"

### ✅ Test 3: Chuyển tab (5 giây)
- Click "Đã thuộc" tab
- **Expected:** Chỉ hiển thị từ đã tick

### ✅ Test 4: Xóa từ (10 giây)
- Click 🗑️ → Confirm "Xóa"
- **Expected:** Từ biến mất + snackbar "Đã xóa"

### ✅ Test 5: Load more (5 giây)
- Cuộn xuống cuối → Tự động load thêm
- **Expected:** CircularProgressIndicator → Thêm 20 từ

### ✅ Test 6: Pull to refresh (5 giây)
- Kéo xuống từ trên → Thả ra
- **Expected:** Refresh indicator → Load lại

**Total test time: 40 giây** ⚡

---

## 🔧 Troubleshooting

### ❌ Problem: "Network Error"
**Solution:**
```powershell
# Check backend running
netstat -ano | findstr :5000

# Restart backend
cd backend
npm start
```

### ❌ Problem: "Empty list"
**Solution:**
```
1. Vào tab "Từ điển"
2. Thêm vài từ (hello, world, computer)
3. Quay lại "Danh sách"
```

### ❌ Problem: "Shimmer không dừng"
**Solution:**
```
1. Check backend logs
2. Verify API baseUrl trong api_constants.dart
3. Restart app
```

### ❌ Problem: "Checkbox không update"
**Solution:**
```
1. Check backend endpoint: PATCH /words/:id/memorize
2. Check backend logs
3. Verify WordProvider đã wrap MaterialApp
```

---

## 📝 Quick Reference

### Navigation
```dart
// Từ anywhere
context.push('/vocabulary');

// Từ màn hình Từ điển
// Click nút "Danh sách" ở góc phải trên
```

### API Endpoints
```
GET    /api/words?page=1&limit=20&filter=all
DELETE /api/words/:id
PATCH  /api/words/:id/memorize
```

### Filters
- `all` - Tất cả từ
- `memorized` - Đã thuộc
- `not-memorized` - Chưa thuộc

### Files to Know
```
lib/features/words/
├── screens/vocabulary_list_screen.dart  # Main screen
├── widgets/vocabulary_card.dart         # Word card
├── providers/word_provider.dart         # State management
└── services/word_service.dart           # API calls
```

---

## 🎯 Success Criteria Checklist

Tick ✅ sau khi test thành công:

- [ ] Loading shimmer hiển thị khi mở màn hình
- [ ] Danh sách từ vựng hiển thị đúng
- [ ] Stats bar hiển thị tổng số từ
- [ ] Cuộn mượt mà, không lag
- [ ] Load more tự động khi cuộn xuống
- [ ] Pull to refresh hoạt động
- [ ] 3 tabs filter đúng
- [ ] Checkbox toggle memorized
- [ ] Delete word với confirmation
- [ ] Snackbar notifications hiển thị
- [ ] Empty state hiển thị khi chưa có từ
- [ ] Error state với retry button

**All checked?** 🎉 Congratulations! Feature hoàn thành!

---

## 📚 Documentation

Để biết thêm chi tiết:

- **Feature Overview:** `VOCABULARY_SCREEN_README.md`
- **Testing Guide:** `TESTING_GUIDE.md`
- **Sprint Summary:** `SPRINT_SUMMARY.md`

---

## 💡 Tips

### Performance Tips
- Có >= 50 từ để test infinite scroll tốt hơn
- Cuộn nhanh để test jank-free
- Test trên thiết bị thật tốt hơn emulator

### Demo Tips
- Thêm đa dạng loại từ (noun, verb, adj, adv)
- Thêm ví dụ cho từ để UI đẹp hơn
- Test cả 3 tabs để thấy filter hoạt động

### Debug Tips
```dart
// Bật debug logs trong WordProvider
print('Loading words: page=$_currentPage, filter=$_currentFilter');
```

---

**Ready?** Let's test! 🚀

Run: `flutter run` và enjoy! 🎉
