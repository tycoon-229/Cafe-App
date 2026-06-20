import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/order_controller.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';
import '../models/product_size.dart';

class ProductDetailPopup extends StatefulWidget {
  final Product product;

  const ProductDetailPopup({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailPopup> createState() => _ProductDetailPopupState();
}

class _ProductDetailPopupState extends State<ProductDetailPopup> {
  List<ProductSize> sizes = [];
  ProductSize? selectedSize;
  int quantity = 1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSizes();
  }

  Future<void> loadSizes() async {
    final data = await ProductController.to.getSizes(widget.product.id);

    setState(() {
      sizes = data;
      if (sizes.isNotEmpty) selectedSize = sizes.first;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final currentPrice = selectedSize?.price ?? 0;

    return Container(
      // Tự động thu phóng theo nội dung, giới hạn tối đa 90% màn hình
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: isLoading
          ? const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator(color: Colors.orange)),
      )
          : Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// HANDLE (Thanh gạt nhỏ trên cùng)
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          /// NỘI DUNG CHÍNH CÓ THỂ CUỘN
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ẢNH SẢN PHẨM
                  Hero(
                    tag: p.id,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: p.imageUrl != null
                            ? Image.network(
                          p.imageUrl!,
                          height: 240,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                            : Container(
                          height: 240,
                          width: double.infinity,
                          color: Colors.grey.shade100,
                          child: const Icon(
                            Icons.fastfood_rounded,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// TIÊU ĐỀ & GIÁ
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            color: Color(0xff2D3142),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${currentPrice.toInt()}đ',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// MÔ TẢ
                  Text(
                    p.description?.isNotEmpty == true
                        ? p.description!
                        : 'Chưa có mô tả cho sản phẩm này.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// CHỌN SIZE
                  const Text(
                    'Kích cỡ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff2D3142),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Center(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: sizes.map((size) {
                        final isSelected = selectedSize?.id == size.id;

                        return GestureDetector(
                          onTap: () => setState(() => selectedSize = size),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.orange.withOpacity(0.1) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? Colors.orange : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  size.name,
                                  style: TextStyle(
                                    color: isSelected ? Colors.orange : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${size.price.toInt()}đ',
                                  style: TextStyle(
                                    color: isSelected ? Colors.orange.shade700 : Colors.grey.shade600,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// CHỌN SỐ LƯỢNG (Hàng ngang)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xfff8f9fb),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Số lượng',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff2D3142),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: quantity > 1
                                    ? () => setState(() => quantity--)
                                    : null,
                                icon: Icon(
                                  Icons.remove_rounded,
                                  color: quantity > 1 ? Colors.orange : Colors.grey.shade400,
                                ),
                              ),
                              SizedBox(
                                width: 30,
                                child: Text(
                                  quantity.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => setState(() => quantity++),
                                icon: const Icon(
                                  Icons.add_rounded,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          /// BOTTOM STICKY BUTTON
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    if (selectedSize == null) {
                      Get.snackbar(
                        'Nhắc nhở',
                        'Vui lòng chọn kích cỡ trước khi thêm vào đơn',
                        backgroundColor: Colors.amber,
                        colorText: Colors.black,
                      );
                      return;
                    }

                    await Get.find<OrderController>().addProduct(
                      productId: p.id,
                      productName: p.name,
                      sizeId: selectedSize!.id,
                      sizeName: selectedSize!.name,
                      price: selectedSize!.price.toDouble(),
                      quantity: quantity,
                    );

                    Get.back();

                    Get.snackbar(
                      'Thành công',
                      'Đã thêm $quantity ${p.name} vào đơn',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.TOP,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_shopping_cart_rounded, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Thêm • ${(currentPrice * quantity).toInt()}đ',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}