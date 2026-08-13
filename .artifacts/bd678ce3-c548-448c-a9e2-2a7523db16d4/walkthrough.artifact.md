# Hoàn thành Custom Animated Menu cho TablePage

Tôi đã thay thế Drawer mặc định của trang `TablePage` bằng một Menu tùy chỉnh với hiệu ứng Staggered Animation mượt mà và giao diện hiện đại hơn.

## Các thay đổi chính

### 1. Chuyển đổi `TablePage` sang `StatefulWidget`
Để quản lý `AnimationController` cho việc đóng/mở Menu, `TablePage` đã được chuyển sang dạng `Stateful`. Cấu trúc trang giờ đây sử dụng `Stack` để hiển thị Menu trượt đè lên nội dung chính.

### 2. Widget `CustomAnimatedMenu` mới
Tạo một widget chuyên biệt xử lý giao diện Menu:
- **Hiệu ứng Staggered**: Các mục menu (Thông tin tài khoản, Quản lý sản phẩm,...) xuất hiện lần lượt với hiệu ứng trượt và mờ dần (Opacity).
- **Ảnh nền Assets**: Sử dụng ảnh `assets/images/auth_bg.jpg` làm hình nền mờ cho Menu, tạo chiều sâu cho giao diện.
- **Header Gradient**: Hiển thị tên quán và địa chỉ trên nền Gradient cam đặc trưng của ứng dụng.
- **Nút Đăng xuất**: Được thiết kế nổi bật ở phía dưới với hiệu ứng Elastic (đàn hồi) khi xuất hiện.
- **Ảnh nền mới**: Áp dụng ảnh `phaiandcy.jpg` làm hình nền cho trang Quản lý bàn, giúp giao diện trở nên sinh động và mang đậm phong cách riêng.

### 3. Tích hợp đầy đủ chức năng
Tất cả các tính năng từ Drawer cũ đã được chuyển sang Menu mới:
- Thông tin tài khoản & Thông tin quán.
- Đổi mật khẩu.
- Quản lý đơn hàng, sản phẩm và thu chi.
- Chức năng đăng xuất với dialog xác nhận.

## Hướng dẫn kiểm tra
1. Mở ứng dụng và vào trang **Quản lý bàn**.
2. Nhấn vào biểu tượng **Menu** (ba dấu gạch) ở góc phải AppBar.
3. Quan sát hiệu ứng trượt của Menu từ trái sang phải và cách các mục menu xuất hiện lần lượt.
4. Kiểm tra việc điều hướng đến các trang khác (như Quản lý sản phẩm) từ Menu mới.
5. Nhấn nút **X** trên AppBar hoặc chọn một mục menu để đóng Menu.
