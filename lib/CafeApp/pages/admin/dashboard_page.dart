import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin_controller.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  final controller = Get.find<AdminController>();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshUsers,
      child: Obx(
        () => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              _buildHeader(),

              const SizedBox(height: 24),

              /// STATS
              LayoutBuilder(
                builder: (_, constraints) {
                  int count = 4; // Mặc định 4 cột trên màn hình to

                  if (constraints.maxWidth < 1100) {
                    count = 4;
                  }

                  if (constraints.maxWidth < 650) {
                    count = 2; // Hiển thị 2 cột trên điện thoại thay vì 1
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: count,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio:
                          1.1, // Tỷ lệ gần vuông giúp ô nhỏ gọn hơn
                      children: [
                        _buildCompactStatCard(
                          title: 'Tất cả',
                          value: controller.totalUsers.value.toString(),
                          icon: Icons.people,
                          gradient: const [
                            Color(0xffFF9F43),
                            Color(0xffFF7A00),
                          ],
                          onTap: () {
                            _showUserListBottomSheet(
                              "Tất cả tài khoản",
                              controller.users,
                            );
                          },
                        ),
                        _buildCompactStatCard(
                          title: 'Admin',
                          value: controller.totalAdmins.value.toString(),
                          icon: Icons.admin_panel_settings,
                          gradient: const [
                            Color(0xff6C63FF),
                            Color(0xff5145CD),
                          ],
                          onTap: () {
                            final filtered = controller.users
                                .where((u) => u['role'] == 'admin')
                                .toList();
                            _showUserListBottomSheet(
                              "Danh sách Admin",
                              filtered,
                            );
                          },
                        ),
                        _buildCompactStatCard(
                          title: 'Hoạt động',
                          value: controller.totalActiveUsers.value.toString(),
                          icon: Icons.check_circle,
                          gradient: const [
                            Color(0xff2ECC71),
                            Color(0xff27AE60),
                          ],
                          onTap: () {
                            // Giả sử field xác định hoạt động là is_active (bạn có thể đổi theo logic thực tế)
                            final filtered = controller.users
                                .where((u) => u['is_active'] == true)
                                .toList();
                            _showUserListBottomSheet(
                              "Tài khoản đang hoạt động",
                              filtered,
                            );
                          },
                        ),
                        _buildCompactStatCard(
                          title: 'Đã khóa',
                          value: controller.totalBlockedUsers.value.toString(),
                          icon: Icons.block,
                          gradient: const [
                            Color(0xffFF6B6B),
                            Color(0xffE74C3C),
                          ],
                          onTap: () {
                            final filtered = controller.users
                                .where((u) => u['is_active'] == false)
                                .toList();
                            _showUserListBottomSheet(
                              "Tài khoản đã khóa",
                              filtered,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              /// RECENT USERS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildRecentUsers(),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xffFF9F43), Color(0xffFF7A00)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.dashboard_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Quản lý hệ thống',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: controller.refreshUsers,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Widget thiết kế lại dạng hình vuông nhỏ gọn
  Widget _buildCompactStatCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentUsers() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(blurRadius: 16, color: Colors.black.withOpacity(.05)),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.people_alt, color: Colors.orange),
              SizedBox(width: 10),
              Text(
                'Người dùng gần đây',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (controller.users.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                children: [
                  Icon(Icons.folder_open, size: 45, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('Chưa có dữ liệu', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          else
            ...controller.users.take(5).map((user) => _buildUserListTile(user)),
        ],
      ),
    );
  }

  // Tách ListTile ra để dùng chung cho cả màn hình chính và BottomSheet
  Widget _buildUserListTile(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xfff8f9fc),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          radius: 22,
          backgroundImage: user['avatar_url'] != null
              ? NetworkImage(user['avatar_url'])
              : null,
          child: user['avatar_url'] == null ? const Icon(Icons.person) : null,
        ),
        title: Text(
          user['username'] ?? 'Chưa có tên',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          user['email'] ?? '',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: user['role'] == 'admin'
                ? Colors.orange.withOpacity(.12)
                : Colors.blue.withOpacity(.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            user['role'] ?? 'user',
            style: TextStyle(
              color: user['role'] == 'admin' ? Colors.orange : Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  // Hàm hiển thị danh sách chi tiết khi bấm vào ô thống kê
  void _showUserListBottomSheet(String title, List<dynamic> filteredUsers) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Thanh gạt (Drag handle)
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            // Tiêu đề BottomSheet
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${filteredUsers.length} tài khoản",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            // Danh sách User
            Expanded(
              child: filteredUsers.isEmpty
                  ? const Center(
                      child: Text(
                        "Không có dữ liệu phù hợp",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        return _buildUserListTile(filteredUsers[index]);
                      },
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled:
          false, // Chiếm 50% màn hình, nếu muốn full màn hình đổi thành true
    );
  }
}
