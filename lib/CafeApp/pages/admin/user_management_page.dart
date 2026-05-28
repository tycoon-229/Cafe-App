import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin_controller.dart';

class UserManagementPage extends StatelessWidget {
  UserManagementPage({super.key});

  final controller = Get.find<AdminController>();

  @override
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// HEADER + SEARCH
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
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
              hintText: 'Tìm kiếm username hoặc email...',
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: Colors.grey.shade600,
              ),
              filled: true,
              fillColor: const Color(0xfff5f7fb),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
              ),
            ),
          ),
        ),

        /// USER LIST
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final approvedUsers = controller.filteredUsers
                .where(
                  (user) =>
              user['account_status'] ==
                  'approved',
            )
                .toList();

            if (approvedUsers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 90,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không có dữ liệu',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh:
              controller.refreshUsers,
              child: ListView.builder(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                itemCount:
                approvedUsers.length,
                itemBuilder: (_, index) {
                  final user =
                  approvedUsers[index];

                  final isActive =
                      user['is_active'] ??
                          true;

                  final cafes =
                  user['cafes'] as List?;

                  final cafe =
                  cafes != null &&
                      cafes.isNotEmpty
                      ? cafes.first
                      : null;

                  return InkWell(
                    borderRadius:
                    BorderRadius.circular(
                      24,
                    ),
                    onTap: () {
                      _showUserDetail(
                        user,
                      );
                    },
                    child: Container(
                      margin:
                      const EdgeInsets.only(
                        bottom: 18,
                      ),
                      padding:
                      const EdgeInsets.all(
                        20,
                      ),
                      decoration:
                      BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(
                          28,
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 14,
                            spreadRadius: 1,
                            color: Colors.black
                                .withOpacity(
                              0.05,
                            ),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          /// USER INFO
                          Row(
                            children: [
                              Hero(
                                tag:
                                user['id'],
                                child:
                                CircleAvatar(
                                  radius: 34,
                                  backgroundColor:
                                  Colors
                                      .grey
                                      .shade200,
                                  backgroundImage:
                                  user['avatar_url'] !=
                                      null
                                      ? NetworkImage(
                                    user[
                                    'avatar_url'],
                                  )
                                      : null,
                                  child: user[
                                  'avatar_url'] ==
                                      null
                                      ? const Icon(
                                    Icons
                                        .person,
                                    size:
                                    34,
                                  )
                                      : null,
                                ),
                              ),

                              const SizedBox(
                                  width: 18),

                              /// USER TEXT
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [
                                    Text(
                                      user['username'] ??
                                          'Chưa có tên',
                                      style:
                                      const TextStyle(
                                        fontWeight:
                                        FontWeight
                                            .bold,
                                        fontSize:
                                        18,
                                      ),
                                    ),

                                    const SizedBox(
                                        height:
                                        6),

                                    Text(
                                      user['email'] ??
                                          '',
                                      style:
                                      TextStyle(
                                        color:
                                        Colors.grey.shade600,
                                      ),
                                    ),

                                    if (cafe !=
                                        null)
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(
                                          top:
                                          8,
                                        ),
                                        child:
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.storefront_rounded,
                                              size:
                                              16,
                                              color:
                                              Colors.brown,
                                            ),
                                            const SizedBox(
                                                width:
                                                6),
                                            Text(
                                              cafe['cafe_name'] ??
                                                  '',
                                              style:
                                              const TextStyle(
                                                color:
                                                Colors.brown,
                                                fontWeight:
                                                FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              /// STATUS
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
                                  color: isActive
                                      ? Colors.green
                                      .withOpacity(
                                      0.12)
                                      : Colors.red
                                      .withOpacity(
                                      0.12),
                                  borderRadius:
                                  BorderRadius.circular(
                                    50,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize:
                                  MainAxisSize.min,
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
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    const SizedBox(
                                        width:
                                        6),
                                    Text(
                                      isActive
                                          ? 'Active'
                                          : 'Blocked',
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
                            ],
                          ),

                          const SizedBox(
                              height: 24),

                          Divider(
                            color:
                            Colors.grey.shade200,
                          ),

                          const SizedBox(
                              height: 16),

                          /// ACTIONS
                          Row(
                            children: [
                              /// ROLE
                              Expanded(
                                child:
                                DropdownButtonFormField<
                                    String>(
                                  value:
                                  user['role'] ??
                                      'user',
                                  decoration:
                                  InputDecoration(
                                    labelText:
                                    'Role',
                                    filled:
                                    true,
                                    fillColor:
                                    const Color(
                                      0xfff5f7fb,
                                    ),
                                    border:
                                    OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(
                                        18,
                                      ),
                                      borderSide:
                                      BorderSide.none,
                                    ),
                                  ),
                                  items:
                                  const [
                                    DropdownMenuItem(
                                      value:
                                      'user',
                                      child:
                                      Text(
                                        'User',
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value:
                                      'admin',
                                      child:
                                      Text(
                                        'Admin',
                                      ),
                                    ),
                                  ],
                                  onChanged:
                                      (value) {
                                    if (value ==
                                        null) {
                                      return;
                                    }

                                    controller
                                        .updateUserRole(
                                      userId:
                                      user[
                                      'id'],
                                      role:
                                      value,
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(
                                  width:
                                  12),

                              /// BLOCK BUTTON
                              Expanded(
                                child:
                                ElevatedButton.icon(
                                  onPressed:
                                      () {
                                    controller
                                        .toggleUserStatus(
                                      userId:
                                      user[
                                      'id'],
                                      currentStatus:
                                      isActive,
                                    );
                                  },
                                  icon: Icon(
                                    isActive
                                        ? Icons
                                        .block_rounded
                                        : Icons
                                        .check_circle_rounded,
                                  ),
                                  label:
                                  Text(
                                    isActive
                                        ? 'Khóa'
                                        : 'Mở khóa',
                                  ),
                                  style:
                                  ElevatedButton.styleFrom(
                                    elevation:
                                    0,
                                    minimumSize:
                                    const Size(
                                      0,
                                      56,
                                    ),
                                    shape:
                                    RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(
                                        18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(
                                  width:
                                  12),

                              /// DELETE
                              Container(
                                decoration:
                                BoxDecoration(
                                  color: Colors
                                      .red
                                      .withOpacity(
                                      .1),
                                  borderRadius:
                                  BorderRadius.circular(
                                    18,
                                  ),
                                ),
                                child:
                                IconButton(
                                  onPressed:
                                      () {
                                    _showDeleteDialog(
                                      user,
                                    );
                                  },
                                  icon:
                                  const Icon(
                                    Icons
                                        .delete_outline_rounded,
                                    color:
                                    Colors.red,
                                  ),
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