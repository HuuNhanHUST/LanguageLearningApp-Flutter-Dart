# Backlog & Epics – LanguageLearningApp

## 📅 Dự án: Ứng dụng Hỗ trợ Tự học Ngoại ngữ
* **Công nghệ:** Flutter/Dart (FE) & MongoDB(BE)
* **Mục tiêu:** 9 Sprints (S0-S9) hoàn thành MVP với tính năng AI cốt lõi.

---

## 🌟 Danh sách 9 Epic Cốt lõi (Mappings từ Jira)

Các Epic này được phân bổ trong các Sprint S1 đến S9.

### 1. EP1: AUTH - Authentication & User Management (Sprint 1)
* **Mục tiêu:** Đảm bảo khả năng truy cập an toàn và quản lý danh tính người dùng.
* **Nội dung:**
    * Đăng ký / Đăng nhập an toàn (email/password).
    * Sử dụng **JWT** cho phiên làm việc.
    * Quản lý trạng thái đăng nhập liên tục (**Persist Login State**).
    * API hồ sơ người dùng cơ bản.

### 2. EP2: VOCAB-CRUD - Data & Dashboard Core (Sprint 2)
* **Mục tiêu:** Hoàn thành nền tảng dữ liệu và giao diện chính.
* **Nội dung:**
    * Định nghĩa **Mongoose Schema** cho `Word` (Từ vựng) và `User`.
    * API CRUD cơ bản cho Từ vựng (Tạo, Xem, Xóa).
    * Xây dựng **Flutter Dashboard UI** và **Tab Navigation** chính.

### 3. EP3: AUDIO-PREP - Mobile Audio & File Upload (Sprint 3)
* **Mục tiêu:** Chuẩn bị hạ tầng âm thanh cho tính năng AI.
* **Nội dung:**
    * Triển khai **Flutter Plugin** Ghi âm (Audio Recording).
    * Xử lý **Permissions Microphone** trên Mobile OS.
    * Tích hợp **Text-to-Speech (TTS)** để phát âm chuẩn.
    * API Backend bảo mật cho **Upload File Audio** (sử dụng Rate Limiter).

### 4. EP4: AI-PRONUNCIATION - Core Speaking Evaluation (Sprint 4)
* **Mục tiêu:** Tích hợp AI để chấm điểm khả năng phát âm.
* **Nội dung:**
    * Xây dựng Proxy API gọi dịch vụ **Speech-to-Text (STT)**.
    * Logic Backend **So sánh và Chấm điểm** phát âm (Similarity Scoring).
    * Màn hình Phát âm Flutter gửi audio và hiển thị kết quả/gợi ý sửa lỗi.

### 5. EP5: AI-CHATBOT - Conversational LLM (Sprint 5)
* **Mục tiêu:** Xây dựng tính năng hội thoại tương tác với AI.
* **Nội dung:**
    * Proxy API kết nối an toàn đến dịch vụ **LLM** (Mô hình Ngôn ngữ Lớn).
    * Logic **Context Chat** (lưu trữ lịch sử hội thoại).
    * Giao diện Chat Mobile UI/UX cơ bản (Flutter Widgets).
    * Tích hợp TTS cho phản hồi của Chatbot.

### 6. EP6: GAME-LEADERBOARD - XP, Level & Ranking (Sprint 6)
* **Mục tiêu:** Triển khai hệ thống cấp độ và xếp hạng.
* **Nội dung:**
    * Mở rộng Schema User để bao gồm **XP** và **Level**.
    * API Logic **Tính XP** dựa trên hoạt động (BE).
    * API Leaderboard (Sắp xếp theo XP).
    * Cải tiến Dashboard Flutter để hiển thị **XP Bar** và **Level**.

### 7. EP7: GAME-BADGES - Rewards & Profile Stats (Sprint 7)