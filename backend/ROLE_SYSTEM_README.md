# Hệ Thống Phân Quyền (Role-Based Access Control)

## Tổng Quan

Hệ thống phân quyền với 3 vai trò:
- **User** (Người dùng): Vai trò mặc định khi đăng ký
- **Teacher** (Giáo viên): Có thể tạo lớp học và bài tập
- **Admin** (Quản lý): Quản lý toàn bộ hệ thống

## 🎯 Tính Năng Theo Vai Trò

### 👤 User (Người Dùng)
- Học từ vựng, ngữ pháp, phát âm
- Tham gia lớp học bằng mã lớp
- Làm bài tập trong lớp
- Xem điểm số và thành tích

### 👨‍🏫 Teacher (Giáo Viên)
- Tất cả quyền của User
- Tạo và quản lý lớp học
- Tạo câu hỏi ngữ pháp cho lớp
- Xem danh sách học sinh
- Xóa học sinh khỏi lớp
- Xem thống kê lớp học

### 👑 Admin (Quản Lý)
- Tất cả quyền của Teacher
- Quản lý tất cả users
- Nâng cấp User lên Teacher
- Hạ cấp Teacher xuống User
- Kích hoạt/vô hiệu hóa tài khoản
- Xem thống kê toàn hệ thống

## 🚀 Cài Đặt & Khởi Động

### 1. Tạo Admin Account Đầu Tiên

```bash
cd backend
node scripts/create-admin.js
```

Thông tin đăng nhập mặc định:
- Email: `admin@languageapp.com`
- Password: `Admin@123456`

**⚠️ QUAN TRỌNG**: Đổi mật khẩu ngay sau khi đăng nhập lần đầu!

### 2. Khởi Động Backend

```bash
cd backend
npm install
npm start
```

## 📡 API Endpoints

### Class Management (Lớp Học)

#### Giáo Viên tạo lớp mới
```http
POST /api/classes
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "English Advanced Class",
  "description": "Lớp tiếng Anh nâng cao",
  "maxStudents": 50,
  "settings": {
    "allowLateSubmission": true,
    "showResults": true,
    "randomizeQuestions": false
  }
}
```

#### Học sinh tham gia lớp bằng mã
```http
POST /api/classes/join
Authorization: Bearer {token}
Content-Type: application/json

{
  "classCode": "ABC123"
}
```

#### Lấy danh sách lớp của giáo viên
```http
GET /api/classes/my-classes
Authorization: Bearer {token}
```

#### Lấy danh sách lớp đã tham gia
```http
GET /api/classes/enrolled
Authorization: Bearer {token}
```

#### Xem chi tiết lớp học
```http
GET /api/classes/:id
Authorization: Bearer {token}
```

#### Cập nhật thông tin lớp
```http
PUT /api/classes/:id
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Updated Class Name",
  "description": "Updated description"
}
```

#### Xóa học sinh khỏi lớp (Teacher only)
```http
DELETE /api/classes/:id/students/:studentId
Authorization: Bearer {token}
```

#### Rời khỏi lớp (Student)
```http
POST /api/classes/:id/leave
Authorization: Bearer {token}
```

#### Xóa lớp học
```http
DELETE /api/classes/:id
Authorization: Bearer {token}
```

### Grammar Questions (Câu Hỏi Ngữ Pháp)

#### Giáo viên tạo câu hỏi cho lớp
```http
POST /api/grammar/class-questions
Authorization: Bearer {token}
Content-Type: application/json

{
  "word": "beautiful",
  "question": "Choose the correct form: She is ___ than her sister.",
  "options": [
    "more beautiful",
    "beautifuler",
    "most beautiful",
    "beautifullest"
  ],
  "correctIndex": 0,
  "explanation": "Use 'more' with adjectives of 2+ syllables",
  "difficulty": "intermediate",
  "classId": "65abc123...",
  "isPublic": false
}
```

#### Lấy câu hỏi của lớp
```http
GET /api/grammar/class/:classId
Authorization: Bearer {token}
```

#### Lấy câu hỏi do giáo viên tạo
```http
GET /api/grammar/my-questions?classId=65abc123...&difficulty=beginner
Authorization: Bearer {token}
```

#### Cập nhật câu hỏi
```http
PUT /api/grammar/:questionId
Authorization: Bearer {token}
Content-Type: application/json

{
  "question": "Updated question text",
  "options": ["A", "B", "C", "D"],
  "correctIndex": 2
}
```

#### Xóa câu hỏi
```http
DELETE /api/grammar/:questionId
Authorization: Bearer {token}
```

### Admin Endpoints

#### Lấy danh sách tất cả users
```http
GET /api/users/admin/all?role=user&page=1&limit=20&search=john
Authorization: Bearer {admin_token}
```

#### Nâng User lên Teacher
```http
PUT /api/users/admin/promote/:userId
Authorization: Bearer {admin_token}
```

#### Hạ Teacher xuống User
```http
PUT /api/users/admin/demote/:userId
Authorization: Bearer {admin_token}
```

#### Đổi role trực tiếp
```http
PUT /api/users/admin/role/:userId
Authorization: Bearer {admin_token}
Content-Type: application/json

{
  "role": "teacher"
}
```

#### Kích hoạt/vô hiệu hóa user
```http
PUT /api/users/admin/toggle-active/:userId
Authorization: Bearer {admin_token}
```

#### Thống kê users
```http
GET /api/users/admin/stats
Authorization: Bearer {admin_token}
```

## 📊 Database Models

### User Model
```javascript
{
  username: String,
  email: String,
  password: String,
  role: 'user' | 'teacher' | 'admin',  // ⭐ NEW
  firstName: String,
  lastName: String,
  isActive: Boolean,
  // ... các fields khác
}
```

### Class Model (NEW)
```javascript
{
  name: String,
  description: String,
  classCode: String,              // Mã lớp tự động (6 ký tự)
  teacher: ObjectId,              // Giáo viên tạo lớp
  students: [ObjectId],           // Danh sách học sinh
  assignments: [{
    grammarQuestionSetId: ObjectId,
    title: String,
    dueDate: Date
  }],
  isActive: Boolean,
  maxStudents: Number,
  settings: {
    allowLateSubmission: Boolean,
    showResults: Boolean,
    randomizeQuestions: Boolean
  }
}
```

### GrammarQuestion Model (Updated)
```javascript
{
  word: String,
  question: String,
  options: [String],
  correctIndex: Number,
  explanation: String,
  difficulty: 'beginner' | 'intermediate' | 'advanced',
  createdBy: ObjectId,           // ⭐ NEW - Giáo viên tạo
  classId: ObjectId,             // ⭐ NEW - Lớp học (optional)
  isPublic: Boolean,             // ⭐ NEW - Public hay chỉ cho lớp
  // ... các fields khác
}
```

## 🔐 Middleware

### Role-based Middleware
```javascript
// auth.js exports
- auth: Xác thực JWT token
- isAdmin: Chỉ cho admin
- isTeacher: Chỉ cho teacher
- isTeacherOrAdmin: Cho teacher hoặc admin
- authorize(...roles): Cho nhiều roles
```

### Sử dụng trong routes
```javascript
const { auth, isAdmin, isTeacherOrAdmin } = require('../middleware/auth');

// Chỉ teacher hoặc admin
router.post('/classes', auth, isTeacherOrAdmin, createClass);

// Chỉ admin
router.get('/admin/users', auth, isAdmin, getAllUsers);

// Multiple roles
router.get('/data', auth, authorize('admin', 'teacher'), getData);
```

## 🎓 Luồng Hoạt Động

### Tạo và Tham Gia Lớp Học

1. **Giáo viên tạo lớp**
   - POST /api/classes
   - Hệ thống tự động tạo mã lớp (VD: `ABC123`)

2. **Học sinh tham gia lớp**
   - Student nhập mã lớp
   - POST /api/classes/join với `classCode`
   - Hệ thống thêm student vào danh sách

3. **Giáo viên tạo bài tập**
   - POST /api/grammar/class-questions
   - Set `classId` và `isPublic: false`

4. **Học sinh làm bài**
   - GET /api/grammar/class/:classId
   - Hiển thị câu hỏi A, B, C, D
   - Submit answers

### Quản Lý Quyền

1. **Admin nâng User lên Teacher**
   - PUT /api/users/admin/promote/:userId
   - User có thêm quyền tạo lớp và bài tập

2. **Teacher tạo lớp và quản lý**
   - Tạo lớp, thêm câu hỏi
   - Xem danh sách học sinh
   - Xóa học sinh nếu cần

## 📱 Flutter Frontend Integration

### Models cần tạo

```dart
// lib/models/class_model.dart
class ClassModel {
  final String id;
  final String name;
  final String description;
  final String classCode;
  final String teacherId;
  final List<String> students;
  final bool isActive;
  // ...
}

// lib/models/grammar_question_model.dart
class GrammarQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? classId;
  final String? createdBy;
  final bool isPublic;
  // ...
}
```

### Services cần tạo

```dart
// lib/services/class_service.dart
class ClassService {
  Future<List<ClassModel>> getMyClasses();
  Future<List<ClassModel>> getEnrolledClasses();
  Future<ClassModel> createClass(CreateClassDto dto);
  Future<void> joinClass(String classCode);
  // ...
}

// lib/services/grammar_service.dart (update)
class GrammarService {
  Future<void> createClassQuestion(GrammarQuestionDto dto);
  Future<List<GrammarQuestion>> getClassQuestions(String classId);
  // ...
}
```

### Screens cần tạo

1. **Teacher Dashboard**
   - Danh sách lớp đã tạo
   - Nút tạo lớp mới
   - Thống kê

2. **Class Detail Screen**
   - Thông tin lớp (tên, mã, số học sinh)
   - Danh sách học sinh
   - Danh sách bài tập
   - Nút tạo bài tập mới

3. **Create Question Screen**
   - Form nhập câu hỏi
   - 4 options (A, B, C, D)
   - Chọn đáp án đúng
   - Chọn lớp học

4. **Student Join Class Screen**
   - Input field nhập mã lớp
   - Nút Join
   - Danh sách lớp đã tham gia

5. **Take Test Screen**
   - Hiển thị câu hỏi
   - Radio buttons cho A, B, C, D
   - Nút Submit
   - Hiển thị kết quả

6. **Admin Dashboard**
   - Danh sách users
   - Filter theo role
   - Nút promote/demote
   - Thống kê

## 🧪 Testing

### Test với Postman/Thunder Client

1. **Đăng nhập Admin**
```http
POST /api/users/login
{
  "email": "admin@languageapp.com",
  "password": "Admin@123456"
}
```
Lưu `accessToken` để dùng cho các requests tiếp theo.

2. **Tạo Teacher Account**
- Đăng ký user mới
- Dùng admin token để promote:
```http
PUT /api/users/admin/promote/{userId}
Authorization: Bearer {admin_token}
```

3. **Test Teacher Functions**
- Đăng nhập với teacher account
- Tạo lớp học
- Tạo câu hỏi cho lớp

4. **Test Student Functions**
- Đăng ký user mới
- Join lớp bằng mã
- Xem và làm bài tập

## 🔧 Troubleshooting

### Lỗi thường gặp

1. **403 Forbidden**
   - Kiểm tra role của user
   - Kiểm tra token có đúng không

2. **Class code not found**
   - Đảm bảo mã lớp viết hoa
   - Kiểm tra lớp có active không

3. **Cannot create question**
   - Kiểm tra user có role teacher không
   - Kiểm tra classId có tồn tại không

## 📝 Ghi Chú

- Mã lớp được tự động tạo gồm 6 ký tự viết hoa (VD: `ABC123`)
- User mặc định có role = 'user' khi đăng ký
- Chỉ admin mới có thể thay đổi role
- Teacher chỉ có thể quản lý lớp do mình tạo
- Admin có thể quản lý tất cả lớp học

## 🚧 Tính Năng Sắp Tới

- [ ] Student submission tracking
- [ ] Grading system
- [ ] Leaderboard trong lớp
- [ ] Notifications cho bài tập mới
- [ ] Export kết quả Excel
- [ ] Class analytics dashboard
- [ ] Assignment deadlines
- [ ] Homework reminders

## 📞 Support

Nếu có vấn đề, hãy kiểm tra:
1. MongoDB đã chạy chưa
2. Env variables đã đúng chưa
3. Token có hợp lệ không
4. Role của user đã đúng chưa
