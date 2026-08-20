import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showTableDialog({
  required BuildContext context,
  String? initialName,
  required Function(String) onSubmit,
}) {
  final controller = TextEditingController(text: initialName ?? '');

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(initialName == null ? "Thêm bàn" : "Sửa bàn"),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: "Nhập tên bàn (VD: Bàn 1)"),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Huỷ")),
        ElevatedButton(
          onPressed: () {
            final text = controller.text.trim();

            if (text.isEmpty) return;

            onSubmit(text);
            Get.back();
          },
          child: const Text("Lưu"),
        ),
      ],
    ),
  );
}
