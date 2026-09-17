import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/product_detail_controller.dart';
import '../models/product.dart';

class ProductDetailPopup extends StatelessWidget {
  final Product product;

  const ProductDetailPopup({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ProductDetailController(product: product),
      tag: product.id,
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Obx(
            () => controller.isLoading.value
            ? const SizedBox(
          height: 250,
          child: Center(
            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
          ),
        )
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// HANDLE
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            /// CONTENT
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// IMAGE
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xffe5e5e5)),
                        color: const Color(0xfffafafa),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: product.imageUrl != null
                            ? Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                        )
                            : const Icon(
                          Icons.fastfood_outlined,
                          size: 54,
                          color: Colors.black26,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// TITLE & PRICE
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.4,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${controller.currentPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    /// DESCRIPTION
                    Text(
                      product.description?.isNotEmpty == true
                          ? product.description!
                          : 'Chưa có mô tả cho món này.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),

                    /// SIZE SELECTION
                    const Text(
                      'Kích cỡ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Center(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: controller.sizes.map((size) {
                          final isSelected = controller.selectedSize.value?.id == size.id;

                          return GestureDetector(
                            onTap: () => controller.selectSize(size),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.black : const Color(0xfffafafa),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? Colors.black : const Color(0xffe5e5e5),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    size.name,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${size.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ',
                                    style: TextStyle(
                                      color: isSelected ? Colors.white70 : Colors.grey.shade500,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    /// QUANTITY SELECTION
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xfffafafa),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xffe5e5e5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Số lượng',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                iconSize: 18,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: controller.quantity.value > 1
                                    ? controller.decrementQuantity
                                    : null,
                                icon: Icon(
                                  Icons.remove_rounded,
                                  color: controller.quantity.value > 1 ? Colors.black : Colors.black26,
                                ),
                              ),
                              SizedBox(
                                width: 36,
                                child: Text(
                                  controller.quantity.value.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                iconSize: 18,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: controller.incrementQuantity,
                                icon: const Icon(
                                  Icons.add_rounded,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            /// BOTTOM BUTTON
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xfff0f0f0)),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: controller.addToOrder,
                    child: Text(
                      'Thêm vào đơn • ${controller.totalPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}