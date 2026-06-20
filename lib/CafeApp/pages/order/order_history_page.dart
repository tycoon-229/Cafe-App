import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/order_controller.dart';
import '../../controllers/expense_controller.dart'; // THÊM IMPORT NÀY

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({
    super.key,
  });

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final controller = Get.find<OrderController>();

  // Khởi tạo ExpenseController (dùng Get.put để đảm bảo nó luôn tồn tại ở trang này)
  final expenseController = Get.put(ExpenseController());

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();

    // Gọi dữ liệu cho cả THU (Đơn hàng) và CHI (Expense)
    controller.fetchDoneOrders(
      month: selectedMonth,
      year: selectedYear,
    );
    expenseController.fetchExpensesForStats(
      month: selectedMonth,
      year: selectedYear,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Thống kê tổng hợp",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          /// FILTER
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        value: selectedMonth,
                        items: List.generate(
                          12,
                              (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text('Tháng ${index + 1}'),
                          ),
                        ),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            selectedMonth = value;
                            selectedDate = null;
                          });

                          // Cập nhật cả thu và chi
                          controller.fetchDoneOrders(month: selectedMonth, year: selectedYear);
                          expenseController.fetchExpensesForStats(month: selectedMonth, year: selectedYear);
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildDropdown(
                        value: selectedYear,
                        items: List.generate(
                          5,
                              (index) {
                            final year = DateTime.now().year - index;
                            return DropdownMenuItem(
                              value: year,
                              child: Text('$year'),
                            );
                          },
                        ),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            selectedYear = value;
                            selectedDate = null;
                          });

                          // Cập nhật cả thu và chi
                          controller.fetchDoneOrders(month: selectedMonth, year: selectedYear);
                          expenseController.fetchExpensesForStats(month: selectedMonth, year: selectedYear);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDate == null) return;

                    setState(() {
                      selectedDate = pickedDate;
                    });

                    // Cập nhật cả thu và chi theo NGÀY
                    controller.fetchDoneOrders(date: pickedDate);
                    expenseController.fetchExpensesForStats(date: pickedDate);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, color: Colors.orange),
                        const SizedBox(width: 12),
                        Text(
                          selectedDate == null
                              ? 'Chọn ngày'
                              : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                        ),
                        const Spacer(),
                        if (selectedDate != null)
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectedDate = null;
                              });

                              // Reset về tháng
                              controller.fetchDoneOrders(month: selectedMonth, year: selectedYear);
                              expenseController.fetchExpensesForStats(month: selectedMonth, year: selectedYear);
                            },
                            child: const Icon(Icons.close, color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// REVENUE CARD (ĐÃ CẬP NHẬT HIỂN THỊ THU CHI)
          Obx(() {
            final tongThu = controller.totalRevenue;
            final tongChi = expenseController.totalExpense;
            final loiNhuan = tongThu - tongChi;

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xffff9800),
                    Color(0xffffb74d),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        selectedDate != null
                            ? "Kỳ: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                            : "Kỳ: Tháng $selectedMonth/$selectedYear",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Dòng Tổng Thu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Tổng thu (Đơn hàng):", style: TextStyle(color: Colors.white70, fontSize: 15)),
                      Text(
                        "+ ${tongThu.toStringAsFixed(0)}đ",
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Dòng Tổng Chi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Tổng chi (Hoạt động):", style: TextStyle(color: Colors.white70, fontSize: 15)),
                      Text(
                        "- ${tongChi.toStringAsFixed(0)}đ",
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Colors.white54, height: 1),
                  ),

                  // Dòng Lợi Nhuận Thực Tế
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "LỢI NHUẬN",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${loiNhuan.toStringAsFixed(0)}đ",
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),

          /// LIST
          Expanded(
            child: Obx(() {
              if (controller.doneOrders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text("Chưa có đơn hoàn thành", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text("Dữ liệu sẽ hiển thị tại đây", style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.doneOrders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, i) {
                  final order = controller.doneOrders[i];
                  return InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () async {
                      final items = await controller.fetchDetails(orderId: order.id, updateState: false);
                      _showOrderDetailDialog(order, items);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 62,
                            height: 62,
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(Icons.table_restaurant, color: Colors.orange, size: 30),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(order.tableName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(_formatDate(order.createdAt), style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${order.total.toInt()}đ",
                                style: const TextStyle(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () async {
                                  await controller.deleteOrder(order.id);
                                  controller.fetchDoneOrders(month: selectedMonth, year: selectedYear);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
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
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        isExpanded: true,
        underline: const SizedBox(),
      ),
    );
  }

  void _showOrderDetailDialog(dynamic order, List items) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(order.tableName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text("${order.total.toInt()}đ", style: const TextStyle(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              SizedBox(
                height: 300,
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text("Size ${item.sizeName} × ${item.quantity}", style: TextStyle(color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                        Text("${item.subtotal.toInt()}đ", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text("Đóng", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
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