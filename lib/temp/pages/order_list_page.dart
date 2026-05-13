import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/order_controller.dart';
import 'order_detail_page.dart';

class OrderListPage extends StatelessWidget {
  OrderListPage({super.key});

  final controller = Get.find<OrderController>();

  @override
  Widget build(BuildContext context) {
    controller.fetchOrders();

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),

      appBar: AppBar(
        title: const Text("Danh sách đơn"),
        centerTitle: true,
      ),

      body: Obx(() {
        if (controller.orders.isEmpty) {
          return const Center(
            child: Text(
              "Chưa có đơn nào",
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.orders.length,
          separatorBuilder: (_, __) =>
          const SizedBox(height: 12),

          itemBuilder: (context, i) {
            final o = controller.orders[i];

            return InkWell(
              borderRadius: BorderRadius.circular(18),

              onTap: () async {
                await controller.getOrCreateOrder(
                  o.tableId,
                );

                Get.to(() => OrderDetailPage());
              },

              child: Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
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
                        color: Colors.orange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: const Icon(
                        Icons.table_restaurant,
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

                          /// TABLE NAME
                          Text(
                            o.tableName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          /// TIME
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey,
                              ),

                              const SizedBox(width: 4),

                              Text(
                                _formatTime(o.createdAt),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// RIGHT
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.end,
                      children: [

                        /// TOTAL
                        Text(
                          "${o.total.toInt()}đ",
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

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
                                  "Xóa đơn?",
                                ),

                                content: const Text(
                                  "Hành động này không thể hoàn tác",
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
                              await controller
                                  .deleteOrder(o.id);
                            }
                          },

                          child: Container(
                            padding:
                            const EdgeInsets.all(8),

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
        );
      }),
    );
  }

  static String _formatTime(DateTime? time) {
    if (time == null) return "";

    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} phút trước";
    }

    if (diff.inHours < 24) {
      return "${diff.inHours} giờ trước";
    }

    return "${diff.inDays} ngày trước";
  }
}