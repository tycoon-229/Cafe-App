import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin/admin_controller.dart';

class UserManagementPage extends StatelessWidget {
  UserManagementPage({super.key});

  final controller = Get.find<AdminController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.all(20),
          child: TextField(
            onChanged: (value) {
              controller.searchText.value = value;
            },
            decoration: InputDecoration(
              hintText: 'Tìm username hoặc email...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
            ),
          ),
        ),

        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (controller.filteredUsers.isEmpty) {
              return const Center(
                child: Text('Không có dữ liệu'),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.refreshUsers,
              child: ListView.builder(
                padding:
                const EdgeInsets.symmetric(horizontal: 20),
                itemCount:
                controller.filteredUsers.length,
                  itemBuilder: (_, index) {
                    final user =
                    controller.filteredUsers[index];

                    final isActive =
                        user['is_active'] ?? true;

                    return GestureDetector(
                      onTap: () {
                        _showUserDetail(user);
                      },

                      child: Container(
                        margin:
                        const EdgeInsets.only(
                          bottom: 16,
                        ),

                        padding:
                        const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(
                            20,
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 8,
                              color: Colors.black
                                  .withOpacity(0.05),
                            ),
                          ],
                        ),

                        child: Column(
                          children: [

                            /// USER INFO
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
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
                                  )
                                      : null,
                                ),

                                const SizedBox(
                                  width: 16,
                                ),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(
                                        user[
                                        'username'] ??
                                            'Chưa có tên',
                                        style:
                                        const TextStyle(
                                          fontWeight:
                                          FontWeight
                                              .bold,
                                          fontSize: 16,
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 4,
                                      ),

                                      Text(
                                        user['email'] ??
                                            '',
                                        style:
                                        const TextStyle(
                                          color:
                                          Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),

                                  decoration:
                                  BoxDecoration(
                                    color: isActive
                                        ? Colors.green
                                        .withOpacity(
                                        0.15)
                                        : Colors.red
                                        .withOpacity(
                                        0.15),

                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      20,
                                    ),
                                  ),

                                  child: Text(
                                    isActive
                                        ? 'Active'
                                        : 'Blocked',

                                    style: TextStyle(
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                      color: isActive
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 20,
                            ),

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

                                      border:
                                      OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                          14,
                                        ),
                                      ),
                                    ),

                                    items: const [
                                      DropdownMenuItem(
                                        value:
                                        'user',
                                        child: Text(
                                          'User',
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value:
                                        'admin',
                                        child: Text(
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
                                        user['id'],
                                        role:
                                        value,
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(
                                  width: 12,
                                ),

                                /// BLOCK BUTTON
                                Expanded(
                                  child:
                                  ElevatedButton
                                      .icon(
                                    onPressed: () {
                                      controller
                                          .toggleUserStatus(
                                        userId:
                                        user['id'],
                                        currentStatus:
                                        isActive,
                                      );
                                    },

                                    icon: Icon(
                                      isActive
                                          ? Icons
                                          .block
                                          : Icons
                                          .check_circle,
                                    ),

                                    label: Text(
                                      isActive
                                          ? 'Khóa'
                                          : 'Mở khóa',
                                    ),

                                    style:
                                    ElevatedButton
                                        .styleFrom(
                                      minimumSize:
                                      const Size(
                                        double.infinity,
                                        55,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width: 12,
                                ),

                                /// DELETE
                                IconButton(
                                  onPressed: () {
                                    _showDeleteDialog(
                                      user,
                                    );
                                  },

                                  style:
                                  IconButton
                                      .styleFrom(
                                    backgroundColor:
                                    Colors.red
                                        .withOpacity(
                                      0.1,
                                    ),
                                  ),

                                  icon: const Icon(
                                    Icons
                                        .delete_outline,
                                    color:
                                    Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }
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
        title:
        const Text('Xóa user'),
        content: Text(
          'Bạn có chắc muốn xóa "${user['username']}"?',
        ),
        actions: [
          TextButton(
            onPressed:
            Get.back,
            child:
            const Text('Hủy'),
          ),
          ElevatedButton(
            style:
            ElevatedButton.styleFrom(
              backgroundColor:
              Colors.red,
              foregroundColor:
              Colors.white,
            ),
            onPressed: () async {
              Get.back();

              await controller
                  .deleteUser(
                user['id'],
              );
            },
            child:
            const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showUserDetail(
      Map<String, dynamic> user,
      ) {
    Get.bottomSheet(
      Container(
        padding:
        const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.vertical(
            top: Radius.circular(
              28,
            ),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CircleAvatar(
                radius: 45,
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
                  size: 40,
                )
                    : null,
              ),

              const SizedBox(
                height: 16,
              ),

              Text(
                user['username'] ??
                    'No name',
                style:
                const TextStyle(
                  fontSize: 22,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              Text(
                user['email'] ??
                    '',
                style:
                const TextStyle(
                  color:
                  Colors.grey,
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              _infoTile(
                Icons.phone,
                'Số điện thoại',
                user['phone'],
              ),

              _infoTile(
                Icons.store,
                'Tên quán',
                user['cafe_name'],
              ),

              _infoTile(
                Icons.location_on,
                'Địa chỉ',
                user['address'],
              ),

              _infoTile(
                Icons.description,
                'Mô tả',
                user['description'],
              ),

              _infoTile(
                Icons.admin_panel_settings,
                'Role',
                user['role'],
              ),

              _infoTile(
                Icons.check_circle,
                'Status',
                user['is_active']
                    == true
                    ? 'Active'
                    : 'Blocked',
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
    return ListTile(
      contentPadding:
      EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        value?.toString().isNotEmpty ==
            true
            ? value.toString()
            : 'Chưa có dữ liệu',
      ),
    );
  }
}