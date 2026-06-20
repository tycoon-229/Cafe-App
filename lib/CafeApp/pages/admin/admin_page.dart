import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin_controller.dart';
import 'account_approval_page.dart';
import 'cafe_approval_page.dart';
import 'cafe_management_page.dart';
import 'dashboard_page.dart';
import 'user_management_page.dart';

class AdminPage extends StatelessWidget {
  AdminPage({super.key});

  final controller = Get.put(AdminController());

  final selectedIndex = 0.obs;

  // Danh sách các trang
  final pages = <Widget>[
    DashboardPage(),
    UserManagementPage(),
    CafeManagementPage(),
  ];

  // Tiêu đề tương ứng
  final titles = [
    'Dashboard',
    'Quản lý Người Dùng',
    'Quản lý Quán Cafe',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb), // Nền xám xanh nhạt dịu mắt

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Obx(
              () => Text(
            titles[selectedIndex.value],
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 22,
              color: Color(0xff2D3142), // Màu chữ xanh đen hiện đại
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                _actionButton(
                  icon: Icons.refresh_rounded,
                  color: Colors.blue,
                  onTap: controller.refreshUsers,
                ),
                const SizedBox(width: 12),
                _actionButton(
                  icon: Icons.logout_rounded,
                  color: Colors.red,
                  onTap: _showLogoutDialog,
                ),
              ],
            ),
          ),
        ],
        // Thêm shadow rất mỏng ở viền dưới AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey.withOpacity(0.15),
            height: 1,
          ),
        ),
      ),

      body: LayoutBuilder(
        builder: (_, constraints) {
          final isDesktop = constraints.maxWidth > 900;

          if (isDesktop) {
            // Giao diện Desktop (Có Sidebar)
            return Row(
              children: [
                _buildSidebar(),
                Expanded(
                  child: Container(
                    color: const Color(0xfff5f7fb),
                    child: Obx(
                          () => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: pages[selectedIndex.value],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // Giao diện Mobile/Tablet nhỏ (Không có Sidebar)
          return Container(
            color: const Color(0xfff5f7fb),
            child: Obx(
                  () => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: pages[selectedIndex.value],
              ),
            ),
          );
        },
      ),

      // Thanh điều hướng cho Mobile (Chỉ hiện khi màn hình < 900)
      bottomNavigationBar: LayoutBuilder(
        builder: (_, constraints) {
          if (constraints.maxWidth > 900) {
            return const SizedBox.shrink();
          }

          return Obx(
                () => Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: NavigationBar(
                height: 75,
                elevation: 0,
                backgroundColor: Colors.white,
                indicatorColor: Colors.orange.withOpacity(0.2), // Màu nền icon khi chọn
                selectedIndex: selectedIndex.value,
                onDestinationSelected: (index) {
                  selectedIndex.value = index;
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard_rounded, color: Colors.orange),
                    label: 'Tổng quan',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.people_outline_rounded),
                    selectedIcon: Icon(Icons.people_alt_rounded, color: Colors.orange),
                    label: 'Users',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.storefront_outlined), // Icon khi chưa chọn
                    selectedIcon: Icon(Icons.storefront_rounded, color: Colors.orange), // Icon khi được chọn
                    label: 'Quán Cafe',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ===========================================================================
  // SIDEBAR CHO DESKTOP
  // ===========================================================================
  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0x15000000), width: 1),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),

          /// HEADER SIDEBAR
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xffFF9F43), Color(0xffFF7A00)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 32,
                    color: Color(0xffFF7A00),
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin System',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Cafe Management',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          /// MENU ITEMS
          _sidebarItem(icon: Icons.dashboard_rounded, title: 'Dashboard', index: 0),
          _sidebarItem(icon: Icons.people_alt_rounded, title: 'Quản lý User', index: 1),
          _sidebarItem(icon: Icons.storefront_rounded, title: 'Quản lý quán Cafe', index: 2),

          const Spacer(),

          /// NÚT ĐĂNG XUẤT (Dưới cùng)
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: _showLogoutDialog,
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  'Đăng xuất',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TỪNG ITEM TRONG SIDEBAR
  // ===========================================================================
  Widget _sidebarItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    return Obx(() {
      final isSelected = selectedIndex.value == index;

      return InkWell(
        onTap: () => selectedIndex.value = index,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8, right: 16),
          child: Row(
            children: [
              // Thanh Indicator báo hiệu đang chọn
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 4,
                height: isSelected ? 40 : 0,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
                ),
              ),

              const SizedBox(width: 16),

              // Khung bao quanh Icon và Text
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.orange.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 22,
                        color: isSelected ? Colors.orange : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 14),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? Colors.orange : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ===========================================================================
  // NÚT BẤM TRÊN APPBAR
  // ===========================================================================
  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }

  // ===========================================================================
  // DIALOG ĐĂNG XUẤT
  // ===========================================================================
  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFFFEBEE),
              child: Icon(Icons.logout_rounded, color: Colors.red),
            ),
            SizedBox(width: 14),
            Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Bạn có chắc muốn đăng xuất khỏi hệ thống?',
          style: TextStyle(height: 1.5),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              minimumSize: const Size(90, 45),
            ),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              minimumSize: const Size(100, 45),
              elevation: 0,
            ),
            onPressed: () async {
              Get.back();
              await controller.logout();
            },
            child: const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}