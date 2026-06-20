import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/expense_controller.dart';

class ExpenseManagePage extends StatefulWidget {
  const ExpenseManagePage({super.key});

  @override
  State<ExpenseManagePage> createState() => _ExpenseManagePageState();
}

class _ExpenseManagePageState extends State<ExpenseManagePage> {
  final controller = Get.put(ExpenseController());

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    // Tải dữ liệu tháng hiện tại khi mở trang
    controller.fetchExpenses(month: selectedMonth, year: selectedYear);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: const Text("Quản lý thu chi"),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        onPressed: () => _showAddExpenseDialog(controller),
        icon: const Icon(Icons.add),
        label: const Text("Thêm chi phí"),
      ),

      body: Column(
        children: [
          /// FILTER HEADER (Tương tự OrderHistoryPage)
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
                          controller.fetchExpenses(month: selectedMonth, year: selectedYear);
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
                          controller.fetchExpenses(month: selectedMonth, year: selectedYear);
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
                    controller.fetchExpenses(date: pickedDate);
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
                              ? 'Chọn ngày cụ thể'
                              : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                        ),
                        const Spacer(),
                        if (selectedDate != null)
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectedDate = null;
                              });
                              controller.fetchExpenses(month: selectedMonth, year: selectedYear);
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

          /// EXPENSES LIST
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final expenses = controller.expenses;

              if (expenses.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_wallet_outlined, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("Chưa có khoản thu chi nào", style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await controller.fetchExpenses(
                    month: selectedDate == null ? selectedMonth : null,
                    year: selectedDate == null ? selectedYear : null,
                    date: selectedDate,
                  );
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final item = expenses[index];
                    final timeStr = item.createdAt != null
                        ? "${item.createdAt!.hour.toString().padLeft(2, '0')}:${item.createdAt!.minute.toString().padLeft(2, '0')} - ${item.createdAt!.day}/${item.createdAt!.month}/${item.createdAt!.year}"
                        : "";

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.red.withOpacity(0.1),
                          child: const Icon(Icons.arrow_downward, color: Colors.red),
                        ),
                        title: Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(item.description ?? "Không có mô tả"),
                            if (timeStr.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(timeStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ]
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "-${item.amount.toInt()}đ",
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _showDeleteConfirm(controller, item.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // --- HÀM HỖ TRỢ XÂY DỰNG DROPDOWN ---
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

  // --- CÁC POPUP CŨ GIỮ NGUYÊN ---
  void _showAddExpenseDialog(ExpenseController controller) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final descController = TextEditingController();

    Get.defaultDialog(
      title: "Thêm khoản chi",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Tên khoản chi",
                hintText: "Ví dụ: Mua đá, Mua ly...",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Số tiền chi",
                suffixText: "đ",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: "Ghi chú bổ sung (nếu có)",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),

      textConfirm: "Xác nhận",
      textCancel: "Hủy",
      confirmTextColor: Colors.white,
      buttonColor: Colors.orange,

      onConfirm: () async {
        final title = titleController.text.trim();
        final amount = double.tryParse(amountController.text.trim()) ?? 0;
        final desc = descController.text.trim();

        if (title.isEmpty) {
          Get.snackbar("Nhắc nhở", "Vui lòng nhập tên khoản chi", backgroundColor: Colors.amber);
          return;
        }
        if (amount <= 0) {
          Get.snackbar("Nhắc nhở", "Số tiền chi phải hợp lệ", backgroundColor: Colors.amber);
          return;
        }

        // Gọi Controller để thêm dữ liệu lên Supabase
        await controller.addExpense(title, amount, desc);

        // Load lại danh sách sau khi thêm khớp với bộ lọc hiện tại
        controller.fetchExpenses(
          month: selectedDate == null ? selectedMonth : null,
          year: selectedDate == null ? selectedYear : null,
          date: selectedDate,
        );
      },
    );
  }

  void _showDeleteConfirm(ExpenseController controller, String id) {
    Get.defaultDialog(
      title: "Xác nhận xóa",
      middleText: "Bạn có chắc muốn xóa khoản chi này không?",
      textConfirm: "Xóa",
      textCancel: "Hủy",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        await controller.deleteExpense(id);

        // Load lại danh sách sau khi xóa khớp với bộ lọc hiện tại
        controller.fetchExpenses(
          month: selectedDate == null ? selectedMonth : null,
          year: selectedDate == null ? selectedYear : null,
          date: selectedDate,
        );
      },
    );
  }
}