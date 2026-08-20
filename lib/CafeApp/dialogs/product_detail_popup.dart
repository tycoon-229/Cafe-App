import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/product_detail_controller.dart';
import '../models/product.dart';

class ProductDetailPopup extends StatelessWidget {
  final Product product;

  const ProductDetailPopup({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Khởi tạo controller riêng cho popup này
    final controller = Get.put(
      ProductDetailController(product: product),
      tag: product.id,
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Obx(
        () => controller.isLoading.value
            ? const SizedBox(
                height: 300,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// HANDLE
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

                  /// CONTENT
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// IMAGE
                          Hero(
                            tag: product.id,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: product.imageUrl != null
                                    ? Image.network(
                                        product.imageUrl!,
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

                          /// TITLE & PRICE
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
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
                                '${controller.currentPrice.toInt()}đ',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          /// DESCRIPTION
                          Text(
                            product.description?.isNotEmpty == true
                                ? product.description!
                                : 'Chưa có mô tả cho sản phẩm này.',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 32),

                          /// SIZE SELECTION
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
                              children: controller.sizes.map((size) {
                                final isSelected =
                                    controller.selectedSize.value?.id ==
                                    size.id;

                                return GestureDetector(
                                  onTap: () => controller.selectSize(size),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.orange.withValues(alpha: 0.1)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.orange
                                            : Colors.grey.shade300,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          size.name,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.orange
                                                : Colors.black87,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${size.price.toInt()}đ',
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.orange.shade700
                                                : Colors.grey.shade600,
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

                          /// QUANTITY SELECTION
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
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: controller.quantity.value > 1
                                            ? controller.decrementQuantity
                                            : null,
                                        icon: Icon(
                                          Icons.remove_rounded,
                                          color: controller.quantity.value > 1
                                              ? Colors.orange
                                              : Colors.grey.shade400,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 30,
                                        child: Text(
                                          controller.quantity.value.toString(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: controller.incrementQuantity,
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

                  /// BOTTOM BUTTON
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
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
                          onPressed: controller.addToOrder,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_shopping_cart_rounded,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Thêm • ${controller.totalPrice.toInt()}đ',
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
      ),
    );
  }
}
