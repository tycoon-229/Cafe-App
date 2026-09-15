import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin_controller.dart';
import 'cafe_approval_page.dart';

class CafeManagementPage extends StatelessWidget {
  CafeManagementPage({super.key});

  final controller = Get.find<AdminController>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshCafes();
    });

    return Column(
      children: [
        // SEARCH & DUYỆT QUÁN
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xffe2e8f0)),
                  ),
                  child: TextField(
                    onChanged: (value) => controller.searchCafeText.value = value,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Tìm quán cafe, hotline...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, color: Colors.black45, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Obx(() {
                final pendingCount = controller.cafes
                    .where((e) => e['approval_status'] == 'pending')
                    .length;

                return Badge(
                  isLabelVisible: pendingCount > 0,
                  label: Text('$pendingCount'),
                  backgroundColor: const Color(0xffef4444),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffd97706),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _showApprovalPopup,
                    icon: const Icon(Icons.approval_rounded, size: 18),
                    label: const Text('Duyệt quán', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                );
              }),
            ],
          ),
        ),

        // DANH SÁCH QUÁN ĐÃ DUYỆT
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: Color(0xffd97706), strokeWidth: 2));
            }

            final approvedCafes = controller.filteredCafes
                .where((c) => c['approval_status'] == 'approved')
                .toList();

            if (approvedCafes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.storefront_outlined, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Text('Chưa có quán cafe nào được duyệt', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: const Color(0xffd97706),
              onRefresh: controller.refreshCafes,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: approvedCafes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final cafe = approvedCafes[index];
                  final owner = cafe['profiles'];

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xffe2e8f0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xfffef3c7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.coffee_rounded, color: Color(0xffd97706), size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cafe['cafe_name'] ?? 'Chưa đặt tên',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    cafe['address'] ?? 'Chưa có địa chỉ',
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 18, color: Color(0xfff1f5f9)),

                        // FIX OVERFLOW EMAIL TẠI ĐÂY:
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xfff8fafc),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.account_circle_outlined, size: 16, color: Color(0xff64748b)),
                              const SizedBox(width: 6),
                              Text(
                                "Chủ quán: ",
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                              Expanded(
                                child: Text(
                                  "${owner?['username'] ?? 'Trống'} (${owner?['email'] ?? 'Không có email'})",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff0f172a),
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 38,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xff2563eb),
                                    side: const BorderSide(color: Color(0xffbfdbfe)),
                                    backgroundColor: const Color(0xffeff6ff),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () => _showEditCafeDialog(cafe),
                                  icon: const Icon(Icons.edit_rounded, size: 14),
                                  label: const Text('Đổi chủ / Sửa', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 38,
                              width: 38,
                              child: IconButton(
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xfffef2f2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () => _showDeleteDialog(cafe),
                                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xffef4444), size: 18),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  void _showApprovalPopup() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xfff8fafc),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Duyệt quán cafe mới", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close_rounded, size: 20)),
                ],
              ),
            ),
            const Divider(color: Color(0xffe2e8f0), height: 1),
            const Expanded(child: CafeApprovalPage()),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showDeleteDialog(Map<String, dynamic> cafe) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa quán cafe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: Text("Bạn có chắc chắn muốn xóa '${cafe['cafe_name']}'? Toàn bộ dữ liệu bàn, đơn hàng của quán sẽ bị hủy bỏ."),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Hủy', style: TextStyle(color: Colors.black54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffef4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Get.back();
              controller.deleteCafe(cafe['id']);
            },
            child: const Text('Xác nhận xóa'),
          ),
        ],
      ),
    );
  }

  void _showEditCafeDialog(Map<String, dynamic> cafe) {
    String selectedOwnerId = cafe['owner_id'];
    final nameController = TextEditingController(text: cafe['cafe_name']);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Chỉnh sửa quán cafe", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Tên quán",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 14),
              const Text("Đổi chủ sở hữu:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: controller.users.any((u) => u['id'] == selectedOwnerId) ? selectedOwnerId : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: controller.users.map((user) {
                  return DropdownMenuItem<String>(
                    value: user['id'],
                    child: Text(
                      "${user['username']} (${user['email']})",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) selectedOwnerId = val;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563eb),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    await controller.supabase.from('cafes').update({
                      'cafe_name': nameController.text,
                      'owner_id': selectedOwnerId,
                    }).eq('id', cafe['id']);

                    controller.refreshCafes();
                    Get.back();
                    Get.snackbar("Thành công", "Đã cập nhật thông tin quán");
                  },
                  child: const Text("Lưu thay đổi", style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}