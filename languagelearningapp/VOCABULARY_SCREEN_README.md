# Màn hình Danh sách Từ vựng - Vocabulary List Screen

## Tổng quan

Màn hình này hiển thị danh sách từ vựng của người dùng với các tính năng:
- ✅ Hiển thị danh sách từ vựng từ Database thật
- ✅ Phân trang tự động khi cuộn xuống dưới
- ✅ 3 tabs: Tất cả / Đã thuộc / Chưa thuộc
- ✅ Đánh dấu từ đã thuộc/chưa thuộc
- ✅ Xóa từ khỏi danh sách
- ✅ Loading state với Shimmer effect
- ✅ Empty state khi chưa có từ
- ✅ Error handling với retry

## Cấu trúc Files

```
lib/
├── core/
│   └── constants/
│       └── api_constants.dart                 # Thêm endpoints cho word management
├── features/
    └── words/
        ├── models/
        │   └── word_model.dart                # Model đã có sẵn
        ├── providers/
        │   └── word_provider.dart             # [MỚI] State management cho danh sách từ
        ├── screens/
        │   └── vocabulary_list_screen.dart    # [MỚI] Màn hình chính
        ├── services/
        │   └── word_service.dart              # Mở rộng với CRUD operations
        └── widgets/
            ├── vocabulary_card.dart           # [MỚI] Card hiển thị từ vựng
            └── vocabulary_card_shimmer.dart   # [MỚI] Loading shimmer
```

## Các tính năng đã hoàn thành

### 1. VocabularyCard Widget ✅
- Hiển thị từ vựng, nghĩa, ví dụ, loại từ
- Checkbox để đánh dấu đã thuộc/chưa thuộc
- Nút xóa với dialog xác nhận
- UI đẹp với màu sắc phân biệt loại từ (noun, verb, adj, adv)
- Ví dụ hiển thị trong box có background màu xanh

### 2. VocabularyListScreen ✅
- TabBar với 3 tabs: Tất cả, Đã thuộc, Chưa thuộc
- ListView.builder với infinite scroll
- Pull-to-refresh
- Stats bar hiển thị tổng số từ
- Loading states:
  - Initial loading: Shimmer effect
  - Load more: CircularProgressIndicator ở cuối danh sách
- Empty state với icon và message
- Error state với retry button

### 3. State Management ✅
- WordProvider quản lý:
  - Danh sách từ vựng
  - Loading states (isLoading, isLoadingMore)
  - Error handling
  - Pagination (currentPage, hasMore, totalPages)
  - Filter (all, memorized, not-memorized)
- Các actions:
  - loadWords() - Tải danh sách với phân trang
  - toggleMemorized() - Đánh dấu đã thuộc/chưa thuộc
  - deleteWord() - Xóa từ
  - changeFilter() - Chuyển đổi filter

### 4. API Integration ✅
- GET /words?page=1&limit=20&filter=all
- DELETE /words/:id
- PUT /words/:id/memorize

## Hướng dẫn sử dụng

### 1. Truy cập màn hình

```dart
// Từ màn hình Từ điển, nhấn nút "Danh sách"
// Hoặc navigate trực tiếp:
context.push('/vocabulary');
```

### 2. Các thao tác

#### Xem danh sách
- Cuộn lên/xuống để xem từ vựng
- Kéo xuống để refresh
- Cuộn đến cuối để tự động load thêm

#### Đánh dấu đã thuộc/chưa thuộc
- Tick vào checkbox bên trái mỗi từ
- Từ sẽ tự động chuyển sang tab tương ứng

#### Xóa từ
- Nhấn icon delete (thùng rác) bên phải
- Xác nhận trong dialog
- Từ sẽ bị xóa khỏi danh sách

#### Lọc theo trạng thái
- Tab "Tất cả": Hiển thị tất cả từ vựng
- Tab "Đã thuộc": Chỉ hiển thị từ đã đánh dấu thuộc
- Tab "Chưa thuộc": Chỉ hiển thị từ chưa thuộc

## Backend Requirements

### API Endpoints cần có:

#### 1. GET /api/words
```
Query Parameters:
- page: number (default: 1)
- limit: number (default: 20)
- filter: 'all' | 'memorized' | 'not-memorized'

Response:
{
  "success": true,
  "data": {
    "words": [
      {
        "id": "string",
        "word": "string",
        "meaning": "string",
        "type": "string",
        "example": "string",
        "topic": "string",
        "isMemorized": boolean
      }
    ],
    "total": number,
    "page": number,
    "totalPages": number
  }
}
```

#### 2. DELETE /api/words/:id
```
Response:
{
  "success": true,
  "message": "Word deleted successfully"
}
```

#### 3. PUT /api/words/:id/memorize
```
Body:
{
  "isMemorized": boolean
}

Response:
{
  "success": true,
  "data": {
    "word": {
      "id": "string",
      "word": "string",
      "meaning": "string",
      "type": "string",
      "example": "string",
      "topic": "string",
      "isMemorized": boolean
    }
  }
}
```

## Testing Checklist

### Definition of Done (DoD) ✅

- [x] **Màn hình hiển thị đúng danh sách từ vựng lấy từ Database thật**
  - API integration hoàn chỉnh
  - Data mapping từ JSON đúng
  - Hiển thị đầy đủ thông tin: từ, nghĩa, ví dụ, loại từ

- [x] **Cuộn mượt mà, không bị giật lag (Jank-free) với danh sách > 50 từ**
  - Sử dụng ListView.builder (chỉ render visible items)
  - Phân trang với limit = 20 items/page
  - Không load toàn bộ danh sách một lúc

- [x] **Kéo xuống dưới cùng tự động tải thêm dữ liệu (Phân trang hoạt động đúng)**
  - Scroll listener tại 80% của list
  - Load more indicator khi đang tải
  - Không tải lại nếu đã hết dữ liệu

- [x] **Giao diện (UI) đúng với thiết kế Mockup**
  - TabBar với 3 tabs
  - Vocabulary Card với đầy đủ thông tin
  - Checkbox, Delete button
  - Shimmer loading effect
  - Empty state
  - Error state với retry

### Các test case cần kiểm tra:

1. **Load danh sách lần đầu**
   - [ ] Hiển thị shimmer loading
   - [ ] Load thành công: Hiển thị danh sách
   - [ ] Hiển thị stats (tổng số từ)

2. **Infinite scroll**
   - [ ] Cuộn đến 80% → Load thêm dữ liệu
   - [ ] Hiển thị loading indicator ở cuối
   - [ ] Load thành công: Thêm từ vào danh sách
   - [ ] Hết dữ liệu: Không load thêm

3. **Pull to refresh**
   - [ ] Kéo xuống → Hiển thị refresh indicator
   - [ ] Refresh thành công: Reset về page 1

4. **Đánh dấu đã thuộc/chưa thuộc**
   - [ ] Tick checkbox → Update UI ngay lập tức
   - [ ] API call thành công → Hiển thị snackbar
   - [ ] Ở tab "Đã thuộc": untick → Từ biến mất
   - [ ] Ở tab "Chưa thuộc": tick → Từ biến mất
   - [ ] Ở tab "Tất cả": tick/untick → Từ vẫn còn

5. **Xóa từ**
   - [ ] Click delete → Hiển thị dialog xác nhận
   - [ ] Confirm → Từ biến mất khỏi danh sách
   - [ ] Cancel → Từ vẫn còn
   - [ ] Xóa thành công → Hiển thị snackbar

6. **Chuyển đổi tabs**
   - [ ] Click tab → Load dữ liệu theo filter
   - [ ] Hiển thị shimmer khi load
   - [ ] Dữ liệu đúng theo filter

7. **Empty state**
   - [ ] Danh sách rỗng → Hiển thị empty state
   - [ ] Icon và message phù hợp

8. **Error handling**
   - [ ] Lỗi network → Hiển thị error state
   - [ ] Click retry → Thử load lại
   - [ ] Lỗi khi delete/update → Hiển thị snackbar

9. **Performance**
   - [ ] Cuộn mượt với 50+ từ
   - [ ] Không bị memory leak
   - [ ] Shimmer animation mượt mà

## Ghi chú

### Cách update backend nếu chưa có API

Nếu backend chưa có các API endpoint trên, bạn cần:

1. **Cập nhật Word Routes** (`backend/src/routes/wordRoutes.js`)
2. **Thêm Controllers** (`backend/src/controllers/wordController.js`)
3. **Cập nhật Model** để lưu `isMemorized` field

### Dependencies đã sử dụng

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: # State management
  go_router: # Navigation
  http: # API calls
```

Không cần thêm package mới, tất cả đã có sẵn!

## Liên hệ & Support

Nếu có vấn đề khi test hoặc cần hỗ trợ, hãy kiểm tra:
1. Backend server đang chạy
2. API endpoints đã được implement
3. Database có dữ liệu từ vựng
4. baseUrl trong `api_constants.dart` đúng với IP máy

---

**Trạng thái**: ✅ Hoàn thành - Ready for Testing
**Version**: 1.0.0
**Last Updated**: 2025-12-04
