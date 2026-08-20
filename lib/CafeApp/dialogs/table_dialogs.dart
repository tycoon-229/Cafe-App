import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/table.dart';
import '../controllers/table_controller.dart';
import 'confirm_dialog.dart';

class TableDialogs {
  static void showAddTable(Function(int) onAdd) {
    final txt = TextEditingController();
    Get.defaultDialog(
      title: "Thêm bàn",
      content: TextField(
        controller: txt,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: "Nhập số lượng bàn cần thêm",
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      textConfirm: "Thêm",
      textCancel: "Hủy",
      confirmTextColor: Colors.white,
      buttonColor: Colors.orange,
      onConfirm: () {
        final count = int.tryParse(txt.text) ?? 0;
        if (count > 0) {
          onAdd(count);
        }
        Get.back();
      },
    );
  }

  static void showEditTableMenu({
    required BuildContext context,
    required CafeTable table,
    required Function(String) onRename,
    required VoidCallback onDelete,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Wrap(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit, color: Colors.orange),
                  ),
                  title: const Text("Sửa tên bàn"),
                  onTap: () {
                    Get.back();
                    _showRenameDialog(table.name, onRename);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                  title: const Text("Xóa bàn"),
                  onTap: () {
                    Get.back();
                    ConfirmDialog.show(
                      title: "Xóa bàn?",
                      message: "Bạn có chắc muốn xóa bàn \"${table.name}\"?",
                      confirmText: "Xóa",
                      confirmColor: Colors.red,
                      onConfirm: onDelete,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _showRenameDialog(String currentName, Function(String) onRename) {
    final txt = TextEditingController(text: currentName);
    Get.defaultDialog(
      title: "Đổi tên bàn",
      content: TextField(
        controller: txt,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      textConfirm: "Lưu",
      textCancel: "Hủy",
      confirmTextColor: Colors.white,
      buttonColor: Colors.orange,
      onConfirm: () {
        if (txt.text.trim().isNotEmpty) {
          onRename(txt.text.trim());
        }
        Get.back();
      },
    );
  }

  static void showOccupiedMenu({
    required BuildContext context,
    required CafeTable table,
    required VoidCallback onPay,
    required VoidCallback onMerge,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.payment, color: Colors.green),
                  title: const Text("Thanh toán / Xong đơn"),
                  onTap: () {
                    Get.back();
                    onPay();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.merge_type, color: Colors.blue),
                  title: const Text("Gộp đơn vào bàn khác"),
                  onTap: () {
                    Get.back();
                    onMerge();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showEmptyMenu({
    required BuildContext context,
    required CafeTable table,
    required VoidCallback onLink,
    required VoidCallback onEdit,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.link, color: Colors.blue),
                title: const Text("Ghép vào bàn khác"),
                onTap: () {
                  Get.back();
                  onLink();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(
                  Icons.settings_outlined,
                  color: Colors.orange,
                ),
                title: const Text("Quản lý bàn (Sửa/Xóa)"),
                onTap: () {
                  Get.back();
                  onEdit();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static void showSelectionDialog({
    required String title,
    required List<CafeTable> items,
    required Function(CafeTable) onSelected,
  }) {
    Get.defaultDialog(
      title: title,
      content: SizedBox(
        height: 300,
        width: double.maxFinite,
        child: items.isEmpty
            ? const Center(child: Text("Không có bàn phù hợp"))
            : ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final t = items[index];
                  return ListTile(
                    leading: Icon(
                      t.status == 'occupied'
                          ? Icons.restaurant
                          : Icons.event_seat,
                      color: t.status == 'occupied'
                          ? Colors.orange
                          : Colors.green,
                    ),
                    title: Text(t.name),
                    onTap: () {
                      Get.back();
                      onSelected(t);
                    },
                  );
                },
              ),
      ),
      textCancel: "Đóng",
    );
  }

  static void showMergedMenu({
    required BuildContext context,
    required VoidCallback onUnlink,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.link_off, color: Colors.red),
                title: const Text("Tách bàn (Hủy ghép)"),
                onTap: () {
                  Get.back();
                  onUnlink();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
