import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin_controller.dart';
import 'cafe_approval_page.dart';

class CafeManagementPage extends StatelessWidget {
  CafeManagementPage({super.key});

  final controller = Get.find<AdminController>();

  @override
  Widget build(BuildContext context) {
    // Gọi tải dữ liệu khi mở trang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshCafes();
    });

    return Column(
      children: [
        /// HEADER: SEARCH + NÚT DUYỆT QUÁN
        Container(
          margin: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 12,
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) =>
                        controller.searchCafeText.value = value,
                    decoration: InputDecoration(
                      hintText: 'Tìm tên quán hoặc SĐT...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.grey.shade600,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              /// NÚT DUYỆT QUÁN CÓ BADGE ĐỎ
              Obx(() {
                final pendingCount = controller.cafes
                    .where((e) => e['approval_status'] == 'pending')
                    .length;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _showApprovalPopup(),
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xff6C63FF),
                              Color(0xff5145CD),
                            ], // Màu tím cho Quán
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff6C63FF).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.storefront_rounded, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "Duyệt",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (pendingCount > 0)
                      Positioned(
                        top: -5,
                        right: -5,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            pendingCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ],
          ),
        ),

        /// LIST QUÁN ĐÃ DUYỆT
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final approvedCafes = controller.filteredCafes
                .where((c) => c['approval_status'] == 'approved')
                .toList();

            if (approvedCafes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.storefront_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có quán nào',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.refreshCafes,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: approvedCafes.length,
                itemBuilder: (_, index) {
                  final cafe = approvedCafes[index];
                  final owner = cafe['profiles'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.04),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.brown.withOpacity(0.1),
                              child: const Icon(
                                Icons.coffee_rounded,
                                color: Colors.brown,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cafe['cafe_name'] ?? 'Chưa có tên',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    cafe['address'] ?? 'Chưa có địa chỉ',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),

                        // Thông tin Chủ sở hữu
                        Row(
                          children: [
                            const Icon(
                              Icons.person_pin_rounded,
                              size: 18,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Chủ sở hữu: ${owner?['username'] ?? 'Trống'} (${owner?['email'] ?? ''})",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blueGrey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Các nút hành động
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: SizedBox(
                                height: 40,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showEditCafeDialog(cafe),
                                  icon: const Icon(
                                    Icons.edit_rounded,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'Đổi chủ / Sửa',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: Colors.blue.withOpacity(
                                      0.1,
                                    ),
                                    foregroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              height: 40,
                              width: 40,
                              child: IconButton(
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.red.withOpacity(0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => _showDeleteDialog(cafe),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red,
                                  size: 20,
                                ),
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

  // ==========================================
  // POPUP DUYỆT QUÁN
  // ==========================================
  void _showApprovalPopup() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xfff5f7fb),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Duyệt quán cafe mới",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Nhúng giao diện CafeApprovalPage
            const Expanded(child: CafeApprovalPage()),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ==========================================
  // XÓA QUÁN
  // ==========================================
  void _showDeleteDialog(Map<String, dynamic> cafe) {
    Get.defaultDialog(
      title: "Xóa quán cafe",
      middleText:
          "Bạn có chắc muốn xóa quán '${cafe['cafe_name']}'?\nThao tác này sẽ xóa mọi dữ liệu liên quan.",
      textConfirm: "Xóa",
      textCancel: "Hủy",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        controller.deleteCafe(cafe['id']);
      },
    );
  }

  // ==========================================
  // SỬA / ĐỔI CHỦ SỞ HỮU
  // ==========================================
  void _showEditCafeDialog(Map<String, dynamic> cafe) {
    // Để cho chức năng đổi chủ sở hữu mượt mà, Admin sẽ chọn từ 1 danh sách Dropdown những User đã được duyệt.
    String selectedOwnerId = cafe['owner_id'];
    final nameController = TextEditingController(text: cafe['cafe_name']);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Chỉnh sửa thông tin quán",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Tên quán",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Đổi chủ sở hữu (Chọn User):",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Lấy danh sách các user hợp lệ để làm chủ
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: controller.users.any((u) => u['id'] == selectedOwnerId)
                    ? selectedOwnerId
                    : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                items: controller.users.map((user) {
                  return DropdownMenuItem<String>(
                    value: user['id'],
                    child: Text(
                      "${user['username']} (${user['email']})",
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) selectedOwnerId = val;
                },
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    // Cập nhật lên Supabase
                    await controller.supabase
                        .from('cafes')
                        .update({
                          'cafe_name': nameController.text,
                          'owner_id': selectedOwnerId,
                        })
                        .eq('id', cafe['id']);

                    controller.refreshCafes();
                    Get.back();
                    Get.snackbar("Thành công", "Đã cập nhật thông tin quán");
                  },
                  child: const Text("Lưu thay đổi"),
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
