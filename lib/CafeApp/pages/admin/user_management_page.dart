import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin_controller.dart';
import 'account_approval_page.dart';

class UserManagementPage extends StatelessWidget {
  UserManagementPage({super.key});

  final controller = Get.find<AdminController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// HEADER: SEARCH + NÚT DUYỆT TÀI KHOẢN
        Container(
          margin: const EdgeInsets.all(20),
          child: Row(
            children: [
              /// Ô Tìm kiếm
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 12,
                        spreadRadius: 1,
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) {
                      controller.searchText.value = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Tìm username hoặc email...',
                      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade600),
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

              /// Nút Mở Popup Duyệt Tài Khoản
              Obx(() {
                final pendingCount = controller.users
                    .where((e) => e['account_status'] == 'pending')
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
                            colors: [Color(0xffFF9F43), Color(0xffFF7A00)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
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

                    // Badge đếm số lượng tài khoản chờ duyệt
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

        /// USER LIST (TÀI KHOẢN ĐÃ DUYỆT)
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final approvedUsers = controller.filteredUsers
                .where((user) => user['account_status'] == 'approved')
                .toList();

            if (approvedUsers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline_rounded, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Không có dữ liệu',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.refreshUsers,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: approvedUsers.length,
                itemBuilder: (_, index) {
                  final user = approvedUsers[index];
                  final isActive = user['is_active'] ?? true;
                  final cafes = user['cafes'] as List?;
                  final cafe = cafes != null && cafes.isNotEmpty ? cafes.first : null;

                  return InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => _showUserDetail(user),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            spreadRadius: 0,
                            color: Colors.black.withOpacity(0.04),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          /// USER INFO (THÔNG TIN CHÍNH)
                          Row(
                            children: [
                              Hero(
                                tag: user['id'],
                                child: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.grey.shade100,
                                  backgroundImage: user['avatar_url'] != null ? NetworkImage(user['avatar_url']) : null,
                                  child: user['avatar_url'] == null ? const Icon(Icons.person, size: 28, color: Colors.grey) : null,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user['username'] ?? 'Chưa có tên',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user['email'] ?? '',
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                    ),
                                    if (cafe != null) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.storefront_rounded, size: 14, color: Colors.brown),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              cafe['cafe_name'] ?? '',
                                              style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.w600, fontSize: 12),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              /// TRẠNG THÁI ACTIVE/BLOCKED
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(isActive ? Icons.check_circle : Icons.block, size: 14, color: isActive ? Colors.green : Colors.red),
                                    const SizedBox(width: 4),
                                    Text(
                                      isActive ? 'Active' : 'Blocked',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isActive ? Colors.green : Colors.red),
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

                          /// ACTIONS (CHỨC NĂNG)
                          Row(
                            children: [
                              /// ROLE DROPDOWN
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xfff5f7fb),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: user['role'] ?? 'user',
                                      isExpanded: true,
                                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                                      style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.w600),
                                      items: const [
                                        DropdownMenuItem(value: 'user', child: Text('User')),
                                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                                      ],
                                      onChanged: (value) {
                                        if (value != null) {
                                          controller.updateUserRole(userId: user['id'], role: value);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              /// NÚT KHÓA/MỞ KHÓA
                              Expanded(
                                flex: 3,
                                child: SizedBox(
                                  height: 40,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      controller.toggleUserStatus(userId: user['id'], currentStatus: isActive);
                                    },
                                    icon: Icon(isActive ? Icons.lock_outline_rounded : Icons.lock_open_rounded, size: 16),
                                    label: Text(isActive ? 'Khóa' : 'Mở khóa', style: const TextStyle(fontSize: 13)),
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: isActive ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                      foregroundColor: isActive ? Colors.orange : Colors.green,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              /// NÚT XÓA
                              SizedBox(
                                height: 40,
                                width: 40,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.red.withOpacity(0.1),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () => _showDeleteDialog(user),
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                                ),
                              ),
                            ],
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
    );
  }

  // =========================================================================
  // HÀM HIỂN THỊ POPUP DUYỆT TÀI KHOẢN
  // =========================================================================
  void _showApprovalPopup() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8, // Chiếm 80% chiều cao màn hình
        decoration: const BoxDecoration(
          color: Color(0xfff5f7fb),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            // Thanh gạt (Drag Handle)
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

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Duyệt tài khoản mới",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Nội dung (Nhúng giao diện AccountApprovalPage vào đây)
            const Expanded(
              child: AccountApprovalPage(),
            ),
          ],
        ),
      ),
      isScrollControlled: true, // Cho phép BottomSheet cao theo ý muốn
    );
  }

  void _showDeleteDialog(
      Map<String, dynamic> user,
      ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),

        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFFFEBEE),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
            ),
            SizedBox(width: 14),
            Text(
              'Xóa tài khoản',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        content: Text(
          'Bạn có chắc muốn xóa tài khoản "${user['username'] ?? 'Unknown'}"?\n\nHành động này không thể hoàn tác.',
          style: TextStyle(
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),

        actionsPadding: const EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20,
        ),

        actions: [
          OutlinedButton(
            onPressed: Get.back,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(
                100,
                48,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(16),
              ),
            ),
            child: const Text('Hủy'),
          ),

          ElevatedButton.icon(
            onPressed: () async {
              Get.back();

              await controller.deleteUser(
                user['id'],
              );
            },

            icon: const Icon(Icons.delete),

            label: const Text(
              'Xóa',
            ),

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor:
              Colors.white,
              minimumSize:
              const Size(110, 48),
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                  16,
                ),
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showUserDetail(
      Map<String, dynamic> user,
      ) {
    final cafes =
    user['cafes'] as List?;

    final cafe =
    cafes != null &&
        cafes.isNotEmpty
        ? cafes.first
        : null;

    final isActive =
        user['is_active'] ?? true;

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight:
          Get.height * .9,
        ),

        decoration:
        const BoxDecoration(
          color: Color(0xfff5f7fb),
          borderRadius:
          BorderRadius.vertical(
            top: Radius.circular(
              32,
            ),
          ),
        ),

        child:
        SingleChildScrollView(
          padding:
          const EdgeInsets.all(
            24,
          ),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,

            children: [
              /// HANDLE
              Center(
                child: Container(
                  width: 60,
                  height: 6,
                  decoration:
                  BoxDecoration(
                    color: Colors
                        .grey[300],
                    borderRadius:
                    BorderRadius
                        .circular(
                      100,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              /// HEADER
              const Text(
                'Thông tin người dùng',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              /// USER CARD
              Container(
                padding:
                const EdgeInsets.all(
                  24,
                ),

                decoration:
                BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius
                      .circular(
                    28,
                  ),

                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors
                          .black
                          .withOpacity(
                        0.05,
                      ),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor:
                      Colors
                          .brown
                          .shade100,

                      backgroundImage:
                      user['avatar_url'] !=
                          null
                          ? NetworkImage(
                        user[
                        'avatar_url'],
                      )
                          : null,

                      child:
                      user['avatar_url'] ==
                          null
                          ? const Icon(
                        Icons.person,
                        size: 45,
                        color:
                        Colors.brown,
                      )
                          : null,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    Text(
                      user['username'] ??
                          'Chưa có tên',
                      style:
                      const TextStyle(
                        fontSize: 22,
                        fontWeight:
                        FontWeight
                            .bold,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      user['email'] ?? '',
                      style: TextStyle(
                        color:
                        Colors.grey[600],
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment:
                      WrapAlignment
                          .center,

                      children: [
                        Container(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal:
                            14,
                            vertical:
                            8,
                          ),

                          decoration:
                          BoxDecoration(
                            color:
                            isActive
                                ? Colors
                                .green
                                .withOpacity(
                                .12)
                                : Colors
                                .red
                                .withOpacity(
                                .12),

                            borderRadius:
                            BorderRadius.circular(
                              30,
                            ),
                          ),

                          child: Row(
                            mainAxisSize:
                            MainAxisSize
                                .min,
                            children: [
                              Icon(
                                isActive
                                    ? Icons
                                    .check_circle
                                    : Icons
                                    .block,
                                size: 18,
                                color:
                                isActive
                                    ? Colors
                                    .green
                                    : Colors
                                    .red,
                              ),

                              const SizedBox(
                                width: 6,
                              ),

                              Text(
                                isActive
                                    ? 'Đang hoạt động'
                                    : 'Đã khóa',
                                style:
                                TextStyle(
                                  fontWeight:
                                  FontWeight.bold,
                                  color:
                                  isActive
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal:
                            14,
                            vertical:
                            8,
                          ),

                          decoration:
                          BoxDecoration(
                            color: Colors
                                .brown
                                .withOpacity(
                              .12,
                            ),

                            borderRadius:
                            BorderRadius.circular(
                              30,
                            ),
                          ),

                          child: Text(
                            user['role']
                                ?.toUpperCase() ??
                                'USER',
                            style:
                            const TextStyle(
                              color:
                              Colors
                                  .brown,
                              fontWeight:
                              FontWeight
                                  .bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    const Divider(),

                    _infoTile(
                      Icons.email_outlined,
                      'Email',
                      user['email'],
                    ),

                    _infoTile(
                      Icons.phone_outlined,
                      'Số điện thoại',
                      user['phone'],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 22,
              ),

              /// CAFE INFO
              if (cafe != null)
                Container(
                  decoration:
                  BoxDecoration(
                    color:
                    Colors.white,
                    borderRadius:
                    BorderRadius
                        .circular(
                      28,
                    ),

                    boxShadow: [
                      BoxShadow(
                        blurRadius: 20,
                        color: Colors
                            .black
                            .withOpacity(
                          0.05,
                        ),
                      ),
                    ],
                  ),

                  child: ExpansionTile(
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius
                          .circular(
                        28,
                      ),
                    ),

                    collapsedShape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius
                          .circular(
                        28,
                      ),
                    ),

                    tilePadding:
                    const EdgeInsets.symmetric(
                      horizontal:
                      24,
                      vertical: 8,
                    ),

                    leading:
                    const CircleAvatar(
                      backgroundColor:
                      Color(
                        0xFFF3E5F5,
                      ),
                      child: Icon(
                        Icons.storefront,
                        color:
                        Colors.brown,
                      ),
                    ),

                    title: const Text(
                      'Thông tin quán cafe',
                      style: TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      cafe['cafe_name'] ??
                          '',
                    ),

                    childrenPadding:
                    const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      bottom: 24,
                    ),

                    children: [
                      _infoTile(
                        Icons.store,
                        'Tên quán',
                        cafe['cafe_name'],
                      ),

                      _infoTile(
                        Icons.location_on,
                        'Địa chỉ',
                        cafe['address'],
                      ),

                      _infoTile(
                        Icons.phone,
                        'SĐT quán',
                        cafe['phone'],
                      ),

                      _infoTile(
                        Icons.description,
                        'Mô tả',
                        cafe['description'],
                      ),

                      _infoTile(
                        Icons.pending_actions,
                        'Trạng thái',
                        cafe[
                        'approval_status'],
                      ),
                    ],
                  ),
                ),

              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _infoTile(
      IconData icon,
      String title,
      dynamic value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 8,
      ),

      child: Container(
        padding:
        const EdgeInsets.all(16),

        decoration:
        BoxDecoration(
          color: Colors.grey[50],
          borderRadius:
          BorderRadius.circular(
            18,
          ),
        ),

        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor:
              Colors.brown
                  .shade50,
              child: Icon(
                icon,
                color:
                Colors.brown,
                size: 22,
              ),
            ),

            const SizedBox(
              width: 14,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [
                  Text(
                    title,
                    style:
                    TextStyle(
                      color: Colors
                          .grey[600],
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    value
                        ?.toString()
                        .isNotEmpty ==
                        true
                        ? value
                        .toString()
                        : 'Chưa có dữ liệu',

                    style:
                    const TextStyle(
                      fontSize: 15,
                      fontWeight:
                      FontWeight
                          .w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}