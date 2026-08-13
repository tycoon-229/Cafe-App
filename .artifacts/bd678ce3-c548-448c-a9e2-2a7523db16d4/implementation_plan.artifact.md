# Chế độ hiển thị sản phẩm với hiệu ứng Parallax

Tôi sẽ thay đổi cách hiển thị danh sách sản phẩm từ dạng lưới (Grid) sang danh sách dọc (List) với hiệu ứng Parallax cho mỗi sản phẩm, dựa trên ví dụ bạn cung cấp.

## User Review Required

> [!IMPORTANT]
> Thay đổi này sẽ chuyển từ giao diện lưới 2 cột sang danh sách 1 cột. Điều này có nghĩa là mỗi sản phẩm sẽ chiếm nhiều diện tích màn hình hơn (tỉ lệ 16:9), phù hợp để trưng bày hình ảnh đẹp.

## Proposed Changes

### [UI Components]

Tôi sẽ tách logic Parallax ra một widget riêng để giữ cho mã nguồn sạch sẽ và dễ bảo trì.

#### [NEW] [product_parallax_item.dart](file:///D:/Android/Cafe-App/lib/CafeApp/widgets/product_parallax_item.dart)
Tạo widget hiển thị sản phẩm với hiệu ứng parallax.
- Sử dụng `Flow` và `ParallaxFlowDelegate` để xử lý hiệu ứng cuộn.
- Hiển thị tên sản phẩm, mô tả và giá trên nền ảnh có hiệu ứng.
- Thêm lớp phủ Gradient để đảm bảo chữ luôn dễ đọc.

#### [MODIFY] [product_page.dart](file:///D:/Android/Cafe-App/lib/CafeApp/pages/product/product_page.dart)
Cập nhật trang sản phẩm để sử dụng giao diện mới.
- Thay thế `GridView.builder` bằng `ListView.builder`.
- Sử dụng `ProductParallaxItem` cho mỗi hàng.

## Verification Plan

### Manual Verification
- Kiểm tra danh sách sản phẩm cuộn mượt mà.
- Xác nhận hình ảnh sản phẩm có hiệu ứng di chuyển chậm hơn so với tốc độ cuộn (parallax).
- Kiểm tra việc nhấn vào sản phẩm vẫn mở được Popup chi tiết sản phẩm.
- Kiểm tra tính năng tìm kiếm và lọc theo danh mục vẫn hoạt động chính xác với danh sách mới.
