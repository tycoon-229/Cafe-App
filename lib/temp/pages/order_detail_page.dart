import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/order_controller.dart';

class OrderDetailPage extends StatelessWidget {
  OrderDetailPage({super.key});

  final controller = Get.find<OrderController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),

      appBar: AppBar(
        title: const Text("Chi tiết đơn"),
        centerTitle: true,
      ),

      body: Column(
        children: [

          /// LIST
          Expanded(
            child: Obx(() {
              if (controller.details.isEmpty) {
                return const Center(
                  child: Text(
                    "Chưa có món nào",
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.details.length,

                separatorBuilder: (_, __) =>
                const SizedBox(height: 12),

                itemBuilder: (context, i) {
                  final item = controller.details[i];

                  return Container(
                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(18),

                      boxShadow: [
                        BoxShadow(
                          color:
                          Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Row(
                      children: [

                        /// ICON
                        Container(
                          width: 55,
                          height: 55,

                          decoration: BoxDecoration(
                            color:
                            Colors.orange.withOpacity(0.12),
                            borderRadius:
                            BorderRadius.circular(14),
                          ),

                          child: const Icon(
                            Icons.fastfood,
                            color: Colors.orange,
                            size: 28,
                          ),
                        ),

                        const SizedBox(width: 14),

                        /// INFO
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [

                              /// PRODUCT NAME
                              Text(
                                item.productName,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              /// SIZE + PRICE
                              Text(
                                "${item.sizeName} • ${item.price.toInt()}đ",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(height: 8),

                              /// SUBTOTAL
                              Text(
                                "Thành tiền: ${item.subtotal.toInt()}đ",
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// ACTIONS
                        Column(
                          children: [

                            /// DELETE
                            InkWell(
                              borderRadius:
                              BorderRadius.circular(10),

                              onTap: () async {
                                final confirm =
                                await Get.dialog(
                                  AlertDialog(
                                    shape:
                                    RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(
                                          16),
                                    ),

                                    title: const Text(
                                      "Xóa sản phẩm?",
                                    ),

                                    content: const Text(
                                      "Sản phẩm sẽ bị xóa khỏi đơn",
                                    ),

                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Get.back(
                                              result: false,
                                            ),
                                        child:
                                        const Text("Hủy"),
                                      ),

                                      ElevatedButton(
                                        style:
                                        ElevatedButton.styleFrom(
                                          backgroundColor:
                                          Colors.red,
                                        ),

                                        onPressed: () =>
                                            Get.back(
                                              result: true,
                                            ),

                                        child:
                                        const Text("Xóa"),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  controller.updateQty(
                                    item,
                                    0,
                                  );
                                }
                              },

                              child: Container(
                                padding:
                                const EdgeInsets.all(6),

                                decoration: BoxDecoration(
                                  color:
                                  Colors.red.withOpacity(
                                      0.1),
                                  borderRadius:
                                  BorderRadius.circular(
                                      10),
                                ),

                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            /// QTY
                            Container(
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),

                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius:
                                BorderRadius.circular(
                                    12),
                              ),

                              child: Row(
                                mainAxisSize:
                                MainAxisSize.min,
                                children: [

                                  /// MINUS
                                  InkWell(
                                    onTap: () {
                                      if (item.quantity >
                                          1) {
                                        controller.updateQty(
                                          item,
                                          item.quantity - 1,
                                        );
                                      }
                                    },

                                    child: const Icon(
                                      Icons.remove,
                                      size: 20,
                                    ),
                                  ),

                                  Padding(
                                    padding:
                                    const EdgeInsets
                                        .symmetric(
                                      horizontal: 12,
                                    ),

                                    child: Text(
                                      "${item.quantity}",
                                      style:
                                      const TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                        FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  /// PLUS
                                  InkWell(
                                    onTap: () {
                                      controller.updateQty(
                                        item,
                                        item.quantity + 1,
                                      );
                                    },

                                    child: const Icon(
                                      Icons.add,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),

          /// BOTTOM TOTAL
          Obx(() {
            final total = controller.details.fold(
              0.0,
                  (sum, e) => sum + e.subtotal,
            );

            return Container(
              padding: const EdgeInsets.all(20),

              decoration: const BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),

              child: SafeArea(
                top: false,

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    /// TOTAL
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                      children: [
                        const Text(
                          "Tổng cộng",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        Text(
                          "${total.toInt()}đ",
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// PAY BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 52,

                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,

                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(16),
                          ),
                        ),

                        onPressed: () async {
                          await controller.pay();

                          Get.back();

                          Get.snackbar(
                            "Hoàn tất",
                            "Đã thanh toán đơn",
                            backgroundColor:
                            Colors.green,
                            colorText: Colors.white,
                          );
                        },

                        icon: const Icon(Icons.check),

                        label: const Text(
                          "Hoàn thành đơn",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}