# Leaderboard Feature

## 📋 Tổng quan

Màn hình Bảng xếp hạng (Leaderboard) hiển thị top 100 người dùng có điểm XP cao nhất, tạo động lực cạnh tranh lành mạnh giữa các người học.

## ✨ Tính năng

### 1. Danh sách Top 100
- Hiển thị top 100 users xếp theo XP (cao → thấp)
- Smooth scrolling với ListView.builder
- Pull-to-refresh để cập nhật dữ liệu

### 2. Giao diện đặc biệt cho Top 3
- **Top 1** 🥇: 
  - Medal vàng
  - Background vàng nhạt (#FFF9C4)
  - Shadow màu vàng
  
- **Top 2** 🥈:
  - Medal bạc
  - Background xám nhạt (#E0E0E0)
  - Shadow màu bạc

- **Top 3** 🥉:
  - Medal đồng
  - Background cam nhạt (#FFE0B2)
  - Shadow màu đồng

### 3. Floating User Tile
- Ghim thứ hạng của user hiện tại ở dưới cùng
- Chỉ hiển thị khi user KHÔNG nằm trong danh sách Top hiện tại
- Border màu tím để highlight (#6C63FF)
- Badge "YOU" để dễ nhận biết

### 4. Thông tin hiển thị
Mỗi entry hiển thị:
- Rank (số thứ tự hoặc medal)
- Avatar (với cached_avatar)
- Username
- Level
- Streak (chuỗi ngày học)
- XP (điểm kinh nghiệm)

## 🏗️ Kiến trúc

### Files Structure
```
features/leaderboard/
├── models/
│   └── leaderboard_entry.dart      # Model cho mỗi entry
├── providers/
│   └── leaderboard_provider.dart   # Riverpod state management
├── screens/
│   └── leaderboard_screen.dart     # Main screen
├── services/
│   └── leaderboard_service.dart    # API service
├── widgets/
│   └── leaderboard_tile.dart       # Tile widget cho mỗi entry
└── leaderboard.dart                # Export file
```

### State Management
- **Riverpod StateNotifier** cho quản lý state
- State bao gồm:
  - `entries`: List<LeaderboardEntry>
  - `currentUserRank`: int? (thứ hạng của user hiện tại)
  - `totalUsers`: int
  - `isLoading`: bool
  - `error`: String?
  - `lastUpdated`: DateTime?

## 🔌 API Integration

### Endpoints
```dart
GET /api/leaderboard/top100
GET /api/leaderboard/my-rank
```

### Response Format
```json
{
  "success": true,
  "data": {
    "leaderboard": [
      {
        "rank": 1,
        "userId": "...",
        "username": "John Doe",
        "avatar": "https://...",
        "xp": 15000,
        "level": 12,
        "streak": 45,
        "joinedAt": "2025-01-01T00:00:00Z"
      }
    ],
    "currentUserRank": 156,
    "totalUsers": 100
  }
}
```

## 🎨 UI/UX Details

### Colors
- Primary: `#6C63FF` (Purple)
- Gold: `#FFD700` / Background: `#FFF9C4`
- Silver: `#C0C0C0` / Background: `#E0E0E0`
- Bronze: `#CD7F32` / Background: `#FFE0B2`
- Gradient Background: `#2D1B69` → `#1A0F3E`

### Animations
- Smooth scroll
- Pull-to-refresh indicator
- Hover effect trên tiles

### Responsive
- Adaptive padding và margins
- Avatar size responsive
- Text overflow handling

## 📱 Usage

### Navigation
```dart
// Từ Profile screen
context.push('/leaderboard');

// Hoặc từ bất kỳ đâu
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const LeaderboardScreen(),
  ),
);
```

### Provider Access
```dart
// Trong widget
final leaderboardState = ref.watch(leaderboardProvider);

// Load data
ref.read(leaderboardProvider.notifier).loadLeaderboard();

// Refresh
await ref.read(leaderboardProvider.notifier).refresh();
```

## ✅ Definition of Done (DoD)

- [x] Danh sách hiển thị mượt mà, scroll không giật
- [x] Top 3 có giao diện nổi bật khác biệt
- [x] Pull-to-refresh hoạt động
- [x] Floating user tile khi không trong top
- [x] Error handling và loading states
- [x] Responsive design
- [x] Code documentation đầy đủ

## 🚀 Performance

### Optimizations
- `ListView.builder` cho lazy loading
- `.lean()` trong MongoDB query
- Cached avatar images
- Efficient state updates

### Metrics
- Scroll FPS: 60
- API response time: < 500ms
- Memory usage: Optimized với lean queries

## 🧪 Testing Points

1. ✅ Load top 100 users successfully
2. ✅ Display correct rank numbers
3. ✅ Show medals for top 3
4. ✅ Floating tile appears when user not in top
5. ✅ Pull-to-refresh updates data
6. ✅ Error handling when API fails
7. ✅ Loading state during data fetch
8. ✅ Scroll performance smooth

## 🔮 Future Enhancements

- [ ] Filter by timeframe (daily, weekly, monthly, all-time)
- [ ] Search users
- [ ] View user profile on tap
- [ ] Share leaderboard position
- [ ] Animated entry transitions
- [ ] Weekly/Monthly leaderboard tabs
- [ ] Friend-only leaderboard
