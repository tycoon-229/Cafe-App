import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/order_controller.dart';

class OrderHistoryPage
    extends StatefulWidget {
  const OrderHistoryPage({
    super.key,
  });

  @override
  State<OrderHistoryPage>
  createState() =>
      _OrderHistoryPageState();
}

class _OrderHistoryPageState
    extends State<OrderHistoryPage> {
  final controller =
  Get.find<OrderController>();

  int selectedMonth =
      DateTime.now().month;

  int selectedYear =
      DateTime.now().year;

  @override
  void initState() {
    super.initState();

    controller.fetchDoneOrders(
      month: selectedMonth,
      year: selectedYear,
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      const Color(0xfff5f5f5),

      appBar: AppBar(
        title: const Text(
          "Thống kê đơn hàng",
        ),
      ),

      body: Column(
        children: [
          Container(
            padding:
            const EdgeInsets.all(
              16,
            ),
            color: Colors.white,

            child: Row(
              children: [
                Expanded(
                  child:
                  DropdownButton<int>(
                    value:
                    selectedMonth,
                    isExpanded: true,

                    items: List.generate(
                      12,
                          (index) =>
                          DropdownMenuItem(
                            value:
                            index + 1,
                            child: Text(
                              'Tháng ${index + 1}',
                            ),
                          ),
                    ),

                    onChanged: (
                        value,
                        ) {
                      if (value ==
                          null) return;

                      setState(() {
                        selectedMonth =
                            value;
                      });

                      controller
                          .fetchDoneOrders(
                        month:
                        selectedMonth,
                        year:
                        selectedYear,
                      );
                    },
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child:
                  DropdownButton<int>(
                    value:
                    selectedYear,
                    isExpanded: true,

                    items: List.generate(
                      5,
                          (index) {
                        final year =
                            DateTime.now()
                                .year -
                                index;

                        return DropdownMenuItem(
                          value:
                          year,
                          child:
                          Text(
                            '$year',
                          ),
                        );
                      },
                    ),

                    onChanged: (
                        value,
                        ) {
                      if (value ==
                          null) return;

                      setState(() {
                        selectedYear =
                            value;
                      });

                      controller
                          .fetchDoneOrders(
                        month:
                        selectedMonth,
                        year:
                        selectedYear,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Obx(() {
            return Container(
              width:
              double.infinity,
              margin:
              const EdgeInsets
                  .all(16),
              padding:
              const EdgeInsets
                  .all(20),

              decoration:
              BoxDecoration(
                color:
                Colors.orange,
                borderRadius:
                BorderRadius
                    .circular(
                  18,
                ),
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  const Text(
                    "Tổng doanh thu",
                    style: TextStyle(
                      color:
                      Colors.white70,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    "${controller.totalRevenue.toInt()}đ",
                    style:
                    const TextStyle(
                      color:
                      Colors.white,
                      fontSize:
                      28,
                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),
                ],
              ),
            );
          }),

          Expanded(
            child: Obx(() {
              if (controller
                  .doneOrders
                  .isEmpty) {
                return const Center(
                  child: Text(
                    "Chưa có đơn hoàn thành",
                  ),
                );
              }

              return ListView.builder(
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 16,
                ),

                itemCount:
                controller
                    .doneOrders
                    .length,

                itemBuilder:
                    (context, i) {
                  final order =
                  controller
                      .doneOrders[
                  i];

                  return Card(
                    child: ListTile(
                      onTap: () async {
                        final items =
                        await controller.fetchDetails(
                          orderId: order.id,
                          updateState: false,
                        );

                        Get.dialog(
                          AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(18),
                            ),

                            title: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(order.tableName),

                                const SizedBox(height: 4),

                                Text(
                                  "${order.total.toInt()}đ",
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),

                            content: SizedBox(
                              width: double.maxFinite,
                              child: items.isEmpty
                                  ? const Center(
                                child: Text(
                                  "Không có món",
                                ),
                              )
                                  : ListView.separated(
                                shrinkWrap: true,
                                itemCount: items.length,
                                separatorBuilder:
                                    (_, __) =>
                                const Divider(),

                                itemBuilder:
                                    (context, index) {
                                  final item =
                                  items[index];

                                  return Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: [
                                            Text(
                                              item.productName,
                                              style:
                                              const TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .bold,
                                              ),
                                            ),

                                            const SizedBox(
                                              height: 4,
                                            ),

                                            Text(
                                              "Size ${item.sizeName} x${item.quantity}",
                                              style:
                                              const TextStyle(
                                                color:
                                                Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Text(
                                        "${item.subtotal.toInt()}đ",
                                        style:
                                        const TextStyle(
                                          fontWeight:
                                          FontWeight
                                              .bold,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),

                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Get.back(),
                                child:
                                const Text("Đóng"),
                              ),
                            ],
                          ),
                        );
                      },

                      title: Text(
                        order.tableName,
                      ),

                      subtitle: Text(
                        _formatDate(order.createdAt),
                      ),

                      trailing: Row(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [
                          Text(
                            "${order.total.toInt()}đ",
                          ),

                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              controller.deleteOrder(
                                order.id,
                              );

                              controller
                                  .fetchDoneOrders(
                                month:
                                selectedMonth,
                                year:
                                selectedYear,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime? time) {
    if (time == null) return '';

    final day =
    time.day.toString().padLeft(2, '0');

    final month =
    time.month.toString().padLeft(2, '0');

    final year = time.year;

    final hour =
    time.hour.toString().padLeft(2, '0');

    final minute =
    time.minute.toString().padLeft(2, '0');

    final second =
    time.second.toString().padLeft(2, '0');

    return '$day/$month/$year '
        '$hour:$minute:$second';
  }
}