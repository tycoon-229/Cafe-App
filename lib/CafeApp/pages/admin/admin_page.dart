import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin_controller.dart';
import 'cafe_management_page.dart';
import 'dashboard_page.dart';
import 'user_management_page.dart';

class AdminPage extends GetView<AdminController> {
  AdminPage({super.key});

  final pages = <Widget>[
    DashboardPage(),
    UserManagementPage(),
    CafeManagementPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Obx(
              () => Text(
            controller.titles[controller.selectedIndex.value],
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: Color(0xff0f172a),
              letterSpacing: -0.4,
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
                  color: const Color(0xff3b82f6),
                  onTap: controller.refreshUsers,
                ),
                const SizedBox(width: 10),
                _actionButton(
                  icon: Icons.logout_rounded,
                  color: const Color(0xffef4444),
                  onTap: _showLogoutDialog,
                ),
              ],
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: Color(0xffe2e8f0), height: 1),
        ),
      ),
      body: LayoutBuilder(
        builder: (_, constraints) {
          final isDesktop = constraints.maxWidth > 900;

          if (isDesktop) {
            return Row(
              children: [
                _buildSidebar(),
                Expanded(
                  child: Obx(
                        () => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: pages[controller.selectedIndex.value],
                    ),
                  ),
                ),
              ],
            );
          }

          return Obx(
                () => AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: pages[controller.selectedIndex.value],
            ),
          );
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (_, constraints) {
          if (constraints.maxWidth > 900) {
            return const SizedBox.shrink();
          }

          return Obx(
                () => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xffe2e8f0))),
              ),
              child: NavigationBar(
                height: 70,
                elevation: 0,
                backgroundColor: Colors.white,
                indicatorColor: const Color(0xff6366f1).withOpacity(0.12),
                selectedIndex: controller.selectedIndex.value,
                onDestinationSelected: (index) {
                  controller.selectedIndex.value = index;
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.grid_view_rounded, color: Color(0xff64748b)),
                    selectedIcon: Icon(Icons.grid_view_rounded, color: Color(0xff6366f1)),
                    label: 'Tổng quan',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.people_alt_outlined, color: Color(0xff64748b)),
                    selectedIcon: Icon(Icons.people_alt_rounded, color: Color(0xff6366f1)),
                    label: 'Tài khoản',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.storefront_outlined, color: Color(0xff64748b)),
                    selectedIcon: Icon(Icons.storefront_rounded, color: Color(0xff6366f1)),
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

  Widget _buildSidebar() {
    return Container(
      width: 270,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xffe2e8f0), width: 1)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff4f46e5), Color(0xff6366f1)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.admin_panel_settings_rounded, color: Color(0xff4f46e5), size: 26),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Hub',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Hệ thống quản trị',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sidebarItem(icon: Icons.grid_view_rounded, title: 'Tổng quan', index: 0),
          _sidebarItem(icon: Icons.people_alt_rounded, title: 'Quản lý Tài khoản', index: 1),
          _sidebarItem(icon: Icons.storefront_rounded, title: 'Quản lý Quán Cafe', index: 2),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: Color(0xfffee2e2)),
                backgroundColor: const Color(0xfffef2f2),
                foregroundColor: const Color(0xffef4444),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _showLogoutDialog,
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem({required IconData icon, required String title, required int index}) {
    return Obx(() {
      final isSelected = controller.selectedIndex.value == index;

      return InkWell(
        onTap: () => controller.selectedIndex.value = index,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xffeef2ff) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isSelected ? const Color(0xff4f46e5) : const Color(0xff64748b)),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xff4f46e5) : const Color(0xff334155),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _actionButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.18)),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: const Text('Bạn có muốn đăng xuất khỏi trang quản trị hệ thống?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffef4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Get.back();
              await controller.logout();
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}