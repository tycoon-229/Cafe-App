import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpenseDialogs {
  static void showExpenseForm({
    required Function(String title, double amount, String desc) onSubmit,
  }) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xffe5e5e5)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Ghi nhận chi phí",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              _buildField(
                controller: titleCtrl,
                label: "Khoản chi",
                hint: "Nhập tên khoản chi (mua nguyên liệu, đá...)",
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: amountCtrl,
                label: "Số tiền (VNĐ)",
                hint: "Nhập số tiền",
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: descCtrl,
                label: "Ghi chú thêm",
                hint: "Chi tiết bổ sung (tùy chọn)",
                maxLines: 3,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xffe5e5e5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: Colors.black87,
                      ),
                      onPressed: () => Get.back(),
                      child: const Text("Hủy", style: TextStyle(fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        final title = titleCtrl.text.trim();
                        final amount = double.tryParse(amountCtrl.text) ?? 0;
                        if (title.isNotEmpty && amount > 0) {
                          Get.back();
                          onSubmit(title, amount, descCtrl.text.trim());
                        } else {
                          Get.snackbar(
                            "Thông báo",
                            "Vui lòng nhập đầy đủ thông tin hợp lệ",
                            backgroundColor: Colors.black87,
                            colorText: Colors.white,
                          );
                        }
                      },
                      child: const Text("Lưu chi phí", style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            filled: true,
            fillColor: const Color(0xfffafafa),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xffe5e5e5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xffe5e5e5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}