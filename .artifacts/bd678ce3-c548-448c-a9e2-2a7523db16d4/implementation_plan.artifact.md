# Chế độ hiển thị Custom Animated Drawer cho TablePage

Tôi sẽ thay thế Drawer mặc định của `TablePage` bằng một Custom Drawer có hiệu ứng chuyển động Staggered (so le), sử dụng `AnimationController` và `FractionalTranslation` như mẫu bạn cung cấp.

## User Review Required

> [!IMPORTANT]
> - `TablePage` sẽ được chuyển từ `StatelessWidget` sang `StatefulWidget` để quản lý `AnimationController`.
> - Giao diện sẽ sử dụng `Stack` để hiển thị menu đè lên nội dung trang thay vì sử dụng thuộc tính `drawer` mặc định của `Scaffold`.
> - Ảnh nền `assets/images/auth_bg.jpg` sẽ được sử dụng cho Menu.

## Proposed Changes

### [TablePage Component]

#### [MODIFY] [table_page.dart](file:///D:/Android/Cafe-App/lib/CafeApp/pages/table_page.dart)
- Chuyển đổi `TablePage` thành `StatefulWidget`.
- Thêm `AnimationController` để điều khiển hiệu ứng trượt của Menu.
- Thay thế thuộc tính `drawer` của `Scaffold` bằng một `Stack` trong `body`.
- Tích hợp các nút chức năng từ Drawer cũ vào Menu mới:
    - Thông tin tài khoản
    - Thông tin quán
    - Đổi mật khẩu
    - Quản lý đơn hàng
    - Quản lý sản phẩm
    - Quản lý thu chi
    - Đăng xuất
- Thêm logic hiển thị ảnh nền `auth_bg.jpg` cho Menu.

## Verification Plan

### Manual Verification
- Kiểm tra nút Menu trên AppBar hoạt động (Mở/Đóng).
- Kiểm tra hiệu ứng trượt của Menu và hiệu ứng xuất hiện lần lượt của các mục menu (staggered animation).
- Xác nhận các chức năng điều hướng (chuyển trang, đăng xuất) vẫn hoạt động chính xác từ Menu mới.
- Kiểm tra hiển thị ảnh nền trong Menu.
