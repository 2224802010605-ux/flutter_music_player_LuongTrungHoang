#  Simple Offline Music Player (Flutter)

##  Giới thiệu
Đây là ứng dụng **Simple Offline Music Player** được xây dựng bằng **Flutter**, cho phép người dùng phát nhạc **offline** từ bộ nhớ thiết bị Android.  
Ứng dụng được thực hiện đúng theo yêu cầu của **LAB 5 – Simple Offline Music App**, không mở rộng nâng cao ngoài phạm vi bài lab.

---

## 🛠 Công nghệ sử dụng
- Flutter SDK: **3.38.4**
- Dart
- State Management: **Provider**
- Audio playback: **just_audio**
- Query nhạc offline: **on_audio_query**
- Permission handling: **permission_handler**

---

##  Chức năng chính
- Quét và hiển thị danh sách bài hát từ bộ nhớ thiết bị
- Phát / tạm dừng nhạc
- Chuyển bài trước / sau
- Shuffle (phát ngẫu nhiên)
- Repeat (Off / All / One)
- Thanh tiến trình (seek)
- Màn hình Now Playing
- Mini Player
- Xử lý quyền truy cập bộ nhớ
- Hoạt động với thư viện nhạc rỗng
- Hiển thị an toàn với metadata thiếu
- Giao diện xử lý tốt với tên bài hát dài

---

##  Cấu trúc thư mục chính
lib/
├── models/ // SongModel, PlaybackStateModel
├── providers/ // AudioProvider, ThemeProvider
├── services/ // AudioPlayerService, PlaylistService, PermissionService
├── screens/ // HomeScreen, AllSongsScreen, NowPlayingScreen
├── widgets/ // SongTile, MiniPlayer, PlayerControls, ProgressBar
├── utils/ // constants, helpers
└── main.dart

---

## 🔐 Quyền truy cập (Android)
Ứng dụng yêu cầu quyền truy cập nhạc để quét và phát file audio:
- Android 13+: `READ_MEDIA_AUDIO`
- Android < 13: `READ_EXTERNAL_STORAGE`

Nếu người dùng từ chối quyền, ứng dụng sẽ hiển thị màn hình yêu cầu cấp quyền và cho phép mở **App Settings**.

---

##  Test case bắt buộc theo LAB

###  Test phát nhạc mp3, m4a, flac
- Ứng dụng phát thành công các định dạng nhạc offline phổ biến
- File nhạc được copy vào `/sdcard/Music/`

###  Test background playback
- Nhạc vẫn tiếp tục phát khi chuyển app sang nền (phạm vi basic theo LAB)

###  Test deny permission
- Khi người dùng từ chối quyền:
  - App không crash
  - Hiển thị thông báo yêu cầu cấp quyền
  - Có nút mở Settings

###  Test thư viện rỗng
- Khi không có file nhạc:
  - App hiển thị “No Music Found”
  - Không xảy ra lỗi

###  Test metadata thiếu
- File nhạc không có artist / album:
  - App hiển thị “Unknown”
  - Không crash

###  Test tên bài hát dài
- Tên bài hát rất dài:
  - Danh sách hiển thị ellipsis (`...`)
  - Now Playing hiển thị tối đa 2 dòng
  - Giao diện không bị tràn

---

##  Cách chạy project

### Bước 1: Cài dependency
```bash
flutter pub get
Bước 2: Chạy ứng dụng
flutter run
