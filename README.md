# ☕ Cafe App - Ứng dụng Quản lý Quán Cà Phê

Ứng dụng di động quản lý quán cà phê hiện đại được xây dựng bằng **Flutter** và **Supabase**, sử dụng **GetX** làm giải pháp quản lý trạng thái (State Management) và định tuyến. Dự án hỗ trợ quản lý toàn diện từ phía người dùng (nhân viên/chủ quán) đến hệ thống quản trị cấp cao (Admin).

---

## 🚀 Công nghệ sử dụng (Tech Stack)

- **Frontend:** [Flutter](https://flutter.dev/) (Dart ^3.11.1)
- **State Management & Routing:** [GetX](https://pub.dev/packages/get) (`get`, `get_storage`)
- **Backend & Database:** [Supabase](https://supabase.com/) (`supabase_flutter`, `supabase_auth_ui`)
- **UI & Tiện ích hỗ trợ:**
  - `flutter_slidable`: Vuốt hiển thị thao tác (xóa, sửa) trên danh sách.
  - `flutter_rating_bar`: Đánh giá sản phẩm/dịch vụ.
  - `image_picker`: Chọn ảnh sản phẩm/cá nhân.
  - `path`: Xử lý đường dẫn file.

---

## ✨ Tính năng chính (Key Features)

### 1. 🔐 Xác thực & Quản lý tài khoản (Authentication & Authorization)
- Đăng nhập / Đăng ký tài khoản.
- Quên mật khẩu & xác thực mã OTP.
- Đổi mật khẩu, chỉnh sửa thông tin cá nhân (`edit_profile_page.dart`).
- Trạng thái chờ phê duyệt tài khoản (`waiting_account_approval_page.dart`).

### 2. ☕ Quản lý Quán Cà Phê (Cafe Management)
- Đăng ký thông tin quán cà phê mới (`cafe_registration_page.dart`).
- Chỉnh sửa thông tin quán (`edit_cafe_page.dart`).
- Trạng thái chờ Admin phê duyệt quán (`waiting_cafe_approval_page.dart`).

### 3. 📦 Quản lý Sản phẩm & Thực đơn (Product Management)
- Xem danh sách sản phẩm, chi tiết sản phẩm (`product_detail_popup.dart`).
- Thêm / Sửa / Xóa sản phẩm (`product_form_page.dart`, `product_manage_page.dart`).
- Quản lý kích thước sản phẩm (`product_size.dart`).

### 4. 🪑 Quản lý Bàn & Gọi món (Table & Order Management)
- Quản lý sơ đồ bàn trong quán (`table_page.dart`).
- Tạo đơn hàng mới, xem chi tiết đơn hàng (`order_list_page.dart`, `order_detail_page.dart`, `order_history_page.dart`).

### 5. 💰 Quản lý Thu Chi & Chi Phí (Expense Management)
- Theo dõi và quản lý các khoản chi phí của quán (`expense_manage_page.dart`).

### 6. 👑 Hệ thống Quản trị Admin (Admin Dashboard)
- Trang tổng quan Admin (`dashboard_page.dart`, `admin_page.dart`).
- Phê duyệt tài khoản người dùng (`account_approval_page.dart`, `user_management_page.dart`).
- Phê duyệt và quản lý các quán cà phê (`cafe_approval_page.dart`, `cafe_management_page.dart`).

---

## 📁 Cấu trúc dự án (Project Structure)

```text
lib/
├── CafeApp/
│   ├── controllers/         # Quản lý logic & state bằng GetX
│   │   ├── admin_controller.dart
│   │   ├── auth_controller.dart
│   │   ├── cafe_profile_controller.dart
│   │   ├── expense_controller.dart
│   │   ├── order_controller.dart
│   │   ├── product_controller.dart
│   │   ├── product_detail_controller.dart
│   │   ├── product_form_controller.dart
│   │   ├── profile_controller.dart
│   │   └── table_controller.dart
│   ├── dialogs/             # Các hộp thoại popup (xác nhận, thêm/sửa nhanh)
│   │   ├── confirm_dialog.dart
│   │   ├── expense_dialogs.dart
│   │   ├── order_dialogs.dart
│   │   ├── product_detail_popup.dart
│   │   ├── product_dialogs.dart
│   │   ├── table_dialog.dart
│   │   └── table_dialogs.dart
│   ├── models/              # Cấu trúc dữ liệu & kết nối Supabase
│   │   ├── auth.dart
│   │   ├── cafe.dart
│   │   ├── expense.dart
│   │   ├── order.dart
│   │   ├── order_detail.dart
│   │   ├── product.dart
│   │   ├── product_size.dart
│   │   ├── supabase_helper.dart
│   │   └── table.dart
│   └── pages/               # Giao diện các màn hình ứng dụng
│       ├── admin/           # Trang quản trị dành cho Admin
│       ├── auth/            # Màn hình đăng nhập, đăng ký, OTP
│       ├── cafe/            # Đăng ký & quản lý quán cà phê
│       ├── order/           # Quản lý đơn hàng & chi phí
│       ├── product/         # Quản lý sản phẩm & thực đơn
│       ├── app_router_page.dart
│       └── table_page.dart  # Quản lý bàn
assets/                      # Hình ảnh và tài nguyên tĩnh
android/                     # Cấu hình Android
```

---

## 🛠️ Hướng dẫn cài đặt & Chạy dự án (Getting Started)

### Yêu cầu hệ thống
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (phiên bản `^3.11.1` hoặc mới hơn)
- Dart SDK
- Android Studio / VS Code với extension Flutter & Dart

### Các bước thực hiện:

1. **Clone repository** hoặc mở thư mục dự án trong IDE của bạn.

2. **Cài đặt các gói phụ thuộc (Dependencies):**
   ```bash
   flutter pub get
   ```

3. **Cấu hình Supabase:**
   Đảm bảo cấu hình thông tin kết nối Supabase trong `lib/CafeApp/models/supabase_helper.dart` hoặc file cấu hình môi trường của bạn.

4. **Chạy ứng dụng:**
   ```bash
   flutter run
   ```

---

## 📌 Đóng góp & Phát triển
Mọi đóng góp, báo cáo lỗi hoặc đề xuất tính năng mới đều hoan nghênh. Vui lòng tạo pull request hoặc liên hệ nhóm phát triển.
