import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/order_controller.dart';
import 'order_detail_page.dart';
import 'order_history_page.dart';

class OrderListPage extends StatelessWidget {
  OrderListPage({super.key});

  final controller = Get.find<OrderController>();

  @override
  Widget build(BuildContext context) {
    controller.fetchOrders();

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,

        title: const Text(
          "Danh sách đơn",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Get.to(() => const OrderHistoryPage());
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.orange,
                ),
              ),
            ),
          ),
        ],
      ),

      body: Obx(() {
        if (controller.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),

                const SizedBox(height: 16),

                const Text(
                  "Chưa có đơn nào",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Các đơn mới sẽ hiển thị tại đây",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.fetchOrders();
          },

          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.orders.length,

            separatorBuilder: (_, __) =>
            const SizedBox(height: 14),

            itemBuilder: (context, i) {
              final order = controller.orders[i];

              return InkWell(
                borderRadius: BorderRadius.circular(22),

                onTap: () async {
                  await controller.getOrCreateOrder(
                    order.tableId,
                  );

                  Get.to(() => OrderDetailPage());
                },

                child: Container(
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(22),

                    boxShadow: [
                      BoxShadow(
                        color:
                        Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),

                  child: Row(
                    children: [
                      /// ICON
                      Container(
                        width: 62,
                        height: 62,

                        decoration: BoxDecoration(
                          color:
                          Colors.orange.withOpacity(
                            0.12,
                          ),
                          borderRadius:
                          BorderRadius.circular(
                            18,
                          ),
                        ),

                        child: const Icon(
                          Icons.table_restaurant,
                          color: Colors.orange,
                          size: 30,
                        ),
                      ),

                      const SizedBox(width: 16),

                      /// INFO
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.tableName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color:
                                  Colors.grey.shade600,
                                ),

                                const SizedBox(width: 5),

                                Text(
                                  _formatTime(
                                    order.createdAt,
                                  ),
                                  style: TextStyle(
                                    color:
                                    Colors.grey
                                        .shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      /// RIGHT SIDE
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${order.total.toInt()}đ",
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 20,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          InkWell(
                            borderRadius:
                            BorderRadius.circular(
                              12,
                            ),

                            onTap: () async {
                              final confirm =
                              await Get.dialog<bool>(
                                AlertDialog(
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      22,
                                    ),
                                  ),

                                  title: const Text(
                                    "Xóa đơn?",
                                  ),

                                  content: const Text(
                                    "Hành động này không thể hoàn tác",
                                  ),

                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Get.back(
                                          result: false,
                                        );
                                      },
                                      child:
                                      const Text(
                                        "Hủy",
                                      ),
                                    ),

                                    ElevatedButton(
                                      style:
                                      ElevatedButton
                                          .styleFrom(
                                        backgroundColor:
                                        Colors.red,
                                        shape:
                                        RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),

                                      onPressed: () {
                                        Get.back(
                                          result: true,
                                        );
                                      },

                                      child:
                                      const Text(
                                        "Xóa",
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await controller
                                    .deleteOrder(
                                  order.id,
                                );
                              }
                            },

                            child: Container(
                              padding:
                              const EdgeInsets.all(
                                9,
                              ),

                              decoration:
                              BoxDecoration(
                                color: Colors.red
                                    .withOpacity(
                                  0.1,
                                ),
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  12,
                                ),
                              ),

                              child: const Icon(
                                Icons
                                    .delete_outline_rounded,
                                color: Colors.red,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  static String _formatTime(DateTime? time) {
    if (time == null) return "";

    final diff =
    DateTime.now().difference(time);

    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} phút trước";
    }

    if (diff.inHours < 24) {
      return "${diff.inHours} giờ trước";
    }

    return "${diff.inDays} ngày trước";
  }
}