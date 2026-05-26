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

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xfff8f8f8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          /// HANDLE
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// IMAGE
                  Hero(
                    tag: p.id,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: p.imageUrl != null
                          ? Image.network(
                        p.imageUrl!,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                          : Container(
                        height: 220,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.fastfood,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// NAME
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// DESCRIPTION
                  Text(
                    p.description ?? 'Không có mô tả',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// SIZE
                  const Text(
                    'Chọn size',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

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
                              horizontal: 18,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.orange
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.orange
                                    : Colors.grey.shade300,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  size.name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${size.price.toInt()}đ',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white70
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// QUANTITY
                  const Text(
                    'Số lượng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              if (quantity > 1) {
                                setState(() => quantity--);
                              }
                            },
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.orange,
                            ),
                          ),
                          Text(
                            quantity.toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => quantity++),
                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// BOTTOM BUTTON
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 56,
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
                    Get.snackbar('Lỗi', 'Vui lòng chọn size');
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
                    'Đã thêm $quantity món',
                    snackPosition: SnackPosition.TOP,
                  );
                },
                child: Text(
                  'Thêm vào đơn • ${((selectedSize?.price ?? 0) * quantity).toInt()}đ',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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