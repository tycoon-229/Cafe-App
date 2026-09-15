import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/order_controller.dart';
import '../../controllers/expense_controller.dart';
import '../../dialogs/confirm_dialog.dart';

class OrderHistoryPage extends GetView<OrderController> {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseController = Get.find<ExpenseController>();

    Future.microtask(() {
      controller.fetchDoneOrders(
        month: controller.historyMonth.value,
        year: controller.historyYear.value,
      );
      expenseController.fetchExpensesForStats(
        month: controller.historyMonth.value,
        year: controller.historyYear.value,
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Báo cáo thống kê",
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        shape: const Border(
          bottom: BorderSide(color: Color(0xffe5e5e5), width: 1),
        ),
      ),
      body: RefreshIndicator(
        color: Colors.black,
        onRefresh: () async {
          await controller.fetchDoneOrders(
            month: controller.historyMonth.value,
            year: controller.historyYear.value,
          );
          await expenseController.fetchExpensesForStats(
            month: controller.historyMonth.value,
            year: controller.historyYear.value,
          );
        },
        child: Column(
          children: [
            /// FILTER SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                              () => _buildDropdown(
                            value: controller.historyMonth.value,
                            items: List.generate(
                              12,
                                  (index) => DropdownMenuItem(
                                value: index + 1,
                                child: Text('Tháng ${index + 1}', style: const TextStyle(fontSize: 14)),
                              ),
                            ),
                            onChanged: (value) {
                              if (value != null) controller.updateHistoryMonth(value);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(
                              () => _buildDropdown(
                            value: controller.historyYear.value,
                            items: List.generate(5, (index) {
                              final year = DateTime.now().year - index;
                              return DropdownMenuItem(
                                value: year,
                                child: Text('$year', style: const TextStyle(fontSize: 14)),
                              );
                            }),
                            onChanged: (value) {
                              if (value != null) controller.updateHistoryYear(value);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => controller.pickHistoryDate(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xfffafafa),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xffe5e5e5)),
                      ),
                      child: Obx(() {
                        final selectedDate = controller.historyDate.value;
                        return Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, color: Colors.black54, size: 18),
                            const SizedBox(width: 10),
                            Text(
                              selectedDate == null ? 'Chọn ngày cụ thể' : '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                              style: TextStyle(
                                color: selectedDate == null ? Colors.grey.shade500 : Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            if (selectedDate != null)
                              InkWell(
                                onTap: controller.clearHistoryDateFilter,
                                child: const Icon(Icons.close, color: Colors.black54, size: 18),
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            /// STATS SUMMARY CARD (Minimal Monochrome)
            Obx(() {
              final tongThu = controller.totalRevenue;
              final tongChi = expenseController.totalExpense;
              final loiNhuan = tongThu - tongChi;

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "LỢI NHUẬN RÒNG",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Obx(() {
                          final selectedDate = controller.historyDate.value;
                          return Text(
                            selectedDate != null
                                ? "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"
                                : "Tháng ${controller.historyMonth.value}/${controller.historyYear.value}",
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${loiNhuan.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(color: Colors.white24, height: 1),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Tổng doanh thu", style: TextStyle(color: Colors.white54, fontSize: 12)),
                              const SizedBox(height: 2),
                              Text(
                                "+${tongThu.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ",
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Tổng chi phí", style: TextStyle(color: Colors.white54, fontSize: 12)),
                              const SizedBox(height: 2),
                              Text(
                                "-${tongChi.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ",
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),

            /// LIST DONE ORDERS
            Expanded(
              child: Obx(() {
                if (controller.doneOrders.isEmpty) {
                  return ListView(
                    children: [
                      SizedBox(height: Get.height * 0.08),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 52, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            const Text(
                              "Chưa có đơn hàng hoàn thành",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Các hóa đơn đã thanh toán sẽ hiển thị tại đây",
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  itemCount: controller.doneOrders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final order = controller.doneOrders[i];
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final items = await controller.fetchDetails(
                          orderId: order.id,
                          updateState: false,
                        );
                        _showOrderDetailDialog(order, items);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xfffafafa),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xffe5e5e5)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.tableName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(order.createdAt),
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "${order.total.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              iconSize: 18,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                ConfirmDialog.show(
                                  title: "Xóa đơn lưu trữ?",
                                  message: "Hành động này sẽ xóa vĩnh viễn đơn khỏi doanh thu.",
                                  confirmText: "Xóa",
                                  confirmColor: Colors.black,
                                  onConfirm: () async {
                                    await controller.deleteOrder(order.id);
                                    controller.fetchDoneOrders(
                                      month: controller.historyMonth.value,
                                      year: controller.historyYear.value,
                                    );
                                  },
                                );
                              },
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.black38,
                              ),
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
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xfffafafa),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe5e5e5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54, size: 20),
        ),
      ),
    );
  }

  void _showOrderDetailDialog(dynamic order, List items) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xffe5e5e5)),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              order.tableName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3),
            ),
            Text(
              "${order.total.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ",
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: items.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text("Không có chi tiết đơn hàng", style: TextStyle(color: Colors.black45))),
          )
              : ListView.separated(
            shrinkWrap: true,
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(color: Color(0xfff0f0f0), height: 14),
            itemBuilder: (context, index) {
              final item = items[index];
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Size ${item.sizeName} × ${item.quantity}",
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "${item.subtotal.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ",
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ],
              );
            },
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () => Get.back(),
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime? time) {
    if (time == null) return '';
    final day = time.day.toString().padLeft(2, '0');
    final month = time.month.toString().padLeft(2, '0');
    final year = time.year;
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}