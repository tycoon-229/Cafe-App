import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/table.dart';
import 'confirm_dialog.dart';

class TableDialogs {
  static void showAddTable(Function(int) onAdd) {
    final txt = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xffe5e5e5)),
        ),
        title: const Text(
          "Thêm bàn nhanh",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: -0.3),
        ),
        content: TextField(
          controller: txt,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: "Số lượng bàn cần tạo thêm",
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
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Hủy", style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () {
              final count = int.tryParse(txt.text) ?? 0;
              if (count > 0) {
                onAdd(count);
              }
              Get.back();
            },
            child: const Text("Thêm"),
          ),
        ],
      ),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Wrap(
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.drive_file_rename_outline_rounded, color: Colors.black87),
                  title: const Text("Đổi tên bàn", style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () {
                    Get.back();
                    _showRenameDialog(table.name, onRename);
                  },
                ),
                const Divider(color: Color(0xfff0f0f0), height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.black),
                  title: const Text("Xóa bàn", style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () {
                    Get.back();
                    ConfirmDialog.show(
                      title: "Xóa bàn?",
                      message: "Bạn có chắc muốn xóa bàn \"${table.name}\" khỏi hệ thống?",
                      confirmText: "Xóa",
                      confirmColor: Colors.black,
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
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xffe5e5e5)),
        ),
        title: const Text(
          "Đổi tên bàn",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: -0.3),
        ),
        content: TextField(
          controller: txt,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
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
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Hủy", style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () {
              if (txt.text.trim().isNotEmpty) {
                onRename(txt.text.trim());
              }
              Get.back();
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Wrap(
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.check_circle_outline_rounded, color: Colors.black87),
                  title: const Text("Thanh toán & Đóng bàn", style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () {
                    Get.back();
                    onPay();
                  },
                ),
                const Divider(color: Color(0xfff0f0f0), height: 1),
                ListTile(
                  leading: const Icon(Icons.call_split_rounded, color: Colors.black87),
                  title: const Text("Gộp đơn sang bàn khác", style: TextStyle(fontWeight: FontWeight.w500)),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Wrap(
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.link_rounded, color: Colors.black87),
                  title: const Text("Ghép vào bàn khác", style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () {
                    Get.back();
                    onLink();
                  },
                ),
                const Divider(color: Color(0xfff0f0f0), height: 1),
                ListTile(
                  leading: const Icon(Icons.tune_rounded, color: Colors.black87),
                  title: const Text("Tùy chỉnh bàn (Đổi tên / Xóa)", style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () {
                    Get.back();
                    onEdit();
                  },
                ),
              ],
            ),
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
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xffe5e5e5)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: -0.3),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        content: SizedBox(
          height: 280,
          width: double.maxFinite,
          child: items.isEmpty
              ? const Center(
            child: Text("Không có bàn phù hợp", style: TextStyle(color: Colors.black45)),
          )
              : ListView.separated(
            shrinkWrap: true,
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(color: Color(0xfff0f0f0), height: 1),
            itemBuilder: (context, index) {
              final t = items[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                leading: Icon(
                  t.status == 'occupied'
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: Colors.black87,
                  size: 20,
                ),
                title: Text(
                  t.name,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                trailing: Text(
                  t.status == 'occupied' ? 'Đang dùng' : 'Trống',
                  style: TextStyle(
                    fontSize: 12,
                    color: t.status == 'occupied' ? Colors.black : Colors.grey.shade500,
                    fontWeight: t.status == 'occupied' ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                onTap: () {
                  Get.back();
                  onSelected(t);
                },
              );
            },
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Đóng", style: TextStyle(color: Colors.black54)),
          ),
        ],
      ),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Wrap(
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.link_off_rounded, color: Colors.black87),
                  title: const Text("Hủy ghép bàn (Tách bàn)", style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () {
                    Get.back();
                    onUnlink();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}