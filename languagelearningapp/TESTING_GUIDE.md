# Hướng dẫn Test Màn hình Danh sách Từ vựng

## Bước 1: Chuẩn bị môi trường

### 1.1 Khởi động Backend Server

```powershell
cd backend
npm start
```

Đảm bảo server chạy ở port 5000.

### 1.2 Kiểm tra IP máy

```powershell
ipconfig
```

Tìm địa chỉ IPv4 (ví dụ: 192.168.1.9) và cập nhật trong file:
`lib/core/constants/api_constants.dart`

```dart
static const String baseUrl = 'http://192.168.1.9:5000/api';
```

### 1.3 Cài đặt dependencies

```powershell
cd languagelearningapp
flutter pub get
```

## Bước 2: Chạy ứng dụng

### Option 1: Android Emulator
```powershell
flutter run
```

### Option 2: Thiết bị vật lý (qua USB)
1. Bật USB Debugging trên điện thoại
2. Kết nối USB
3. Chạy: `flutter run`

## Bước 3: Test các chức năng

### 3.1 Đăng nhập/Đăng ký
1. Mở app → Đăng nhập hoặc tạo tài khoản mới
2. Đăng nhập thành công → Vào màn hình chính

### 3.2 Thêm một số từ vựng
1. Click tab "Từ điển" (icon book)
2. Nhập từ tiếng Anh (ví dụ: "hello", "world", "computer")
3. Click search hoặc Enter
4. Từ sẽ được thêm vào danh sách

**Lặp lại 10-20 lần để có đủ dữ liệu test phân trang**

### 3.3 Truy cập màn hình Danh sách Từ vựng
1. Ở màn hình Từ điển
2. Click nút **"Danh sách"** ở góc phải trên
3. Màn hình danh sách từ vựng xuất hiện

## Bước 4: Test từng tính năng

### ✅ Test 1: Hiển thị danh sách từ Database

**Mục đích:** Kiểm tra dữ liệu từ backend hiển thị đúng

**Các bước:**
1. Mở màn hình Danh sách Từ vựng
2. Quan sát loading shimmer (animation xám nhấp nháy)
3. Sau 1-2 giây, danh sách từ xuất hiện

**Kết quả mong đợi:**
- ✅ Shimmer loading hiển thị khi đang tải
- ✅ Danh sách từ hiển thị đầy đủ thông tin:
  - Từ vựng (in đậm, to)
  - Nghĩa (chữ xám)
  - Loại từ (tag màu: noun=xanh, verb=xanh lá, adj=cam, adv=tím)
  - Ví dụ (nếu có, trong box màu xanh nhạt)
  - Topic (nếu có, với icon label)
- ✅ Checkbox ở bên trái mỗi từ
- ✅ Icon delete (thùng rác) ở bên phải
- ✅ Stats bar hiển thị tổng số từ

---

### ✅ Test 2: Cuộn mượt mà (Jank-free)

**Mục đích:** Kiểm tra performance khi cuộn danh sách dài

**Các bước:**
1. Đảm bảo có ít nhất 50 từ trong danh sách
   - Nếu chưa đủ: quay lại màn Từ điển và thêm từ
2. Cuộn nhanh lên xuống nhiều lần
3. Quan sát độ mượt của animation

**Kết quả mong đợi:**
- ✅ Cuộn mượt mà, không giật lag
- ✅ Không bị tải lại toàn bộ danh sách khi cuộn
- ✅ Items render/unrender tự động (chỉ hiển thị items visible)

---

### ✅ Test 3: Phân trang (Infinite Scroll)

**Mục đích:** Kiểm tra tự động tải thêm khi cuộn đến cuối

**Các bước:**
1. Cuộn xuống đến gần cuối danh sách
2. Khi đến ~80% chiều dài list, tự động tải thêm
3. Quan sát loading indicator ở cuối danh sách

**Kết quả mong đợi:**
- ✅ Tại 80% chiều dài → CircularProgressIndicator xuất hiện
- ✅ Tải thêm 20 từ (hoặc số còn lại nếu < 20)
- ✅ Loading indicator biến mất sau khi tải xong
- ✅ Danh sách tiếp tục kéo dài
- ✅ Khi hết dữ liệu → Không load thêm

---

### ✅ Test 4: Pull to Refresh

**Mục đích:** Kiểm tra refresh danh sách

**Các bước:**
1. Kéo danh sách xuống từ trên cùng
2. Thả tay ra
3. Quan sát refresh indicator

**Kết quả mong đợi:**
- ✅ Refresh indicator xuất hiện
- ✅ Danh sách được tải lại từ đầu (page 1)
- ✅ Scroll position về top
- ✅ Total count được cập nhật

---

### ✅ Test 5: Chuyển đổi Tabs

**Mục đích:** Kiểm tra filter theo trạng thái

**Các bước:**
1. Ở tab "Tất cả" → Quan sát số lượng từ
2. Click tab "Đã thuộc" → Danh sách thay đổi
3. Click tab "Chưa thuộc" → Danh sách thay đổi
4. Quay lại tab "Tất cả"

**Kết quả mong đợi:**
- ✅ Tab "Tất cả": Hiển thị tất cả từ vựng
- ✅ Tab "Đã thuộc": Chỉ hiển thị từ đã tick checkbox
- ✅ Tab "Chưa thuộc": Chỉ hiển thị từ chưa tick
- ✅ Loading shimmer khi chuyển tab
- ✅ Stats bar cập nhật số lượng đúng

---

### ✅ Test 6: Đánh dấu Đã thuộc/Chưa thuộc

**Mục đích:** Kiểm tra toggle memorized status

**Các bước:**
1. Ở tab "Tất cả"
2. Click checkbox của một từ → Tick
3. Quan sát snackbar "Đã đánh dấu thuộc"
4. Chuyển sang tab "Đã thuộc" → Từ vừa tick xuất hiện
5. Quay lại tab "Tất cả", click checkbox lần nữa → Untick
6. Quan sát snackbar "Đã đánh dấu chưa thuộc"

**Kết quả mong đợi:**
- ✅ Tick checkbox → Update UI ngay lập tức
- ✅ Hiển thị snackbar xác nhận
- ✅ Từ xuất hiện đúng tab
- ✅ Untick → Trạng thái quay lại chưa thuộc

**Test edge case:**
1. Ở tab "Đã thuộc"
2. Untick checkbox → Từ biến mất khỏi tab này
3. Chuyển sang tab "Chưa thuộc" → Từ xuất hiện

**Kết quả mong đợi:**
- ✅ Từ tự động remove khỏi tab không phù hợp
- ✅ Từ xuất hiện ở tab phù hợp

---

### ✅ Test 7: Xóa từ vựng

**Mục đích:** Kiểm tra delete word

**Các bước:**
1. Click icon delete (thùng rác) của một từ
2. Dialog xác nhận xuất hiện
3. Click "Hủy" → Dialog đóng, từ vẫn còn
4. Click delete lần nữa
5. Click "Xóa" → Từ biến mất
6. Quan sát snackbar "Đã xóa từ vựng"

**Kết quả mong đợi:**
- ✅ Dialog xác nhận với tên từ cần xóa
- ✅ "Hủy" → Không xóa
- ✅ "Xóa" → Từ biến mất khỏi danh sách
- ✅ Snackbar thông báo thành công
- ✅ Total count giảm đi 1

---

### ✅ Test 8: Empty State

**Mục đích:** Kiểm tra giao diện khi chưa có từ

**Các bước:**
1. Xóa hết tất cả từ vựng (hoặc tạo tài khoản mới)
2. Mở màn hình Danh sách Từ vựng

**Kết quả mong đợi:**
- ✅ Icon sách lớn màu xám
- ✅ Text "Chưa có từ vựng nào"
- ✅ Subtext "Hãy tra cứu và thêm từ vựng mới"
- ✅ Không hiển thị shimmer

**Test Empty State theo tab:**
1. Thêm vài từ nhưng không đánh dấu thuộc
2. Chuyển sang tab "Đã thuộc"

**Kết quả mong đợi:**
- ✅ Empty state xuất hiện ở tab "Đã thuộc"
- ✅ Tab "Chưa thuộc" vẫn có dữ liệu

---

### ✅ Test 9: Error Handling

**Mục đích:** Kiểm tra xử lý lỗi

**Test 9.1: Lỗi network khi load**
1. Tắt backend server
2. Mở màn hình Danh sách Từ vựng
3. Quan sát error state

**Kết quả mong đợi:**
- ✅ Icon lỗi màu đỏ
- ✅ Text "Đã xảy ra lỗi"
- ✅ Message chi tiết lỗi
- ✅ Nút "Thử lại"

4. Bật lại backend server
5. Click "Thử lại"

**Kết quả mong đợi:**
- ✅ Loading shimmer xuất hiện
- ✅ Danh sách tải thành công

**Test 9.2: Lỗi khi delete**
1. Tắt backend
2. Click delete một từ → Confirm
3. Quan sát snackbar lỗi

**Kết quả mong đợi:**
- ✅ Snackbar màu đỏ với message lỗi
- ✅ Từ vẫn còn trong danh sách

**Test 9.3: Lỗi khi toggle memorized**
1. Tắt backend
2. Click checkbox một từ
3. Quan sát snackbar lỗi

**Kết quả mong đợi:**
- ✅ Snackbar màu đỏ với message lỗi
- ✅ Checkbox quay lại trạng thái cũ

---

### ✅ Test 10: UI/UX Details

**Mục đích:** Kiểm tra chi tiết giao diện

**Checklist:**
- ✅ AppBar màu deepPurple với text "Từ vựng"
- ✅ TabBar với 3 tabs, indicator màu trắng
- ✅ Stats bar màu deepPurple.shade50
- ✅ Icon book + text tổng số từ
- ✅ Card elevation = 2, border radius = 12
- ✅ Checkbox hình vuông, bo góc
- ✅ Type tag bo tròn, màu sắc phân biệt
- ✅ Example box: background xanh nhạt, border xanh, có icon quote
- ✅ Topic với icon label
- ✅ Delete icon màu đỏ
- ✅ Snackbar màu xanh (success) / đỏ (error)

---

## Bước 5: Kiểm tra Performance

### 5.1 Memory Usage
1. Mở DevTools: `flutter run --observatory-port=8888`
2. Mở Chrome: `http://localhost:8888`
3. Vào tab "Performance"
4. Cuộn danh sách nhiều lần
5. Quan sát Memory graph

**Kết quả mong đợi:**
- ✅ Memory tăng khi load, giảm khi scroll ra khỏi viewport
- ✅ Không bị memory leak

### 5.2 Frame Rate
1. Bật Performance Overlay: `flutter run --profile`
2. Cuộn nhanh danh sách
3. Quan sát FPS counter

**Kết quả mong đợi:**
- ✅ FPS ổn định 60fps
- ✅ Không có frame drop đột ngột

---

## Bước 6: Test trên nhiều thiết bị

### 6.1 Android (API levels)
- [ ] Android 8.0 (API 26)
- [ ] Android 10.0 (API 29)
- [ ] Android 12.0 (API 31)
- [ ] Android 13.0 (API 33)

### 6.2 Screen sizes
- [ ] Phone (5.5", 6", 6.5")
- [ ] Tablet (7", 10")

### 6.3 Orientations
- [ ] Portrait
- [ ] Landscape

---

## Bugs Known & Workarounds

### Issue 1: Backend chưa có endpoint
**Symptom:** Error "404 Not Found" khi gọi API

**Solution:**
- Đảm bảo backend đã update với code mới từ `wordController.js`
- Restart backend server

### Issue 2: Shimmer không hiển thị
**Symptom:** Loading không có animation

**Solution:**
- Kiểm tra provider đã wrap MaterialApp
- Restart app

### Issue 3: Checkbox không update
**Symptom:** Click checkbox nhưng không thay đổi

**Solution:**
- Kiểm tra API endpoint `/words/:id/memorize` hoạt động
- Check backend logs

---

## Checklist Hoàn thành

### Definition of Done
- [x] Màn hình hiển thị đúng danh sách từ Database
- [x] Cuộn mượt mà với 50+ từ
- [x] Phân trang tự động
- [x] UI đúng thiết kế

### Subtasks
- [x] VocabularyCard widget
- [x] VocabularyListScreen với ListView.builder
- [x] Loading (Shimmer) & Empty State
- [x] Tích hợp API GET /words

### Extra Features (Bonus)
- [x] Pull to refresh
- [x] Error handling với retry
- [x] Snackbar notifications
- [x] Delete confirmation dialog
- [x] Auto-filter when toggle memorized

---

## Liên hệ & Support

Nếu gặp vấn đề:
1. Check backend logs: `backend/logs/`
2. Check Flutter logs: `flutter logs`
3. Restart cả backend & app
4. Verify baseUrl trong api_constants.dart

**Status:** ✅ Ready for Production Testing
**Version:** 1.0.0
**Last Updated:** 2025-12-04
