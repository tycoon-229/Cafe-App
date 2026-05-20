import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin/admin_controller.dart';
import 'cafe_approval_page.dart';
import 'dashboard_page.dart';
import 'user_management_page.dart';

class AdminPage extends StatelessWidget {
  AdminPage({super.key});

  final controller = Get.put(AdminController());

  final selectedIndex = 0.obs;

  final pages = [
    DashboardPage(),
    UserManagementPage(),
    const CafeApprovalPage(),
  ];

  final titles = [
    'Dashboard',
    'Quản lý User',
    'Duyệt quán cafe',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xfff5f7fb),

      appBar: AppBar(
        elevation: 0,
        title: Obx(
              () => Text(
            titles[selectedIndex.value],
          ),
        ),
        actions: [
          IconButton(
            onPressed:
            controller.refreshUsers,
            icon:
            const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _showLogoutDialog,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: LayoutBuilder(
        builder: (_, constraints) {
          final isDesktop =
              constraints.maxWidth > 900;

          if (isDesktop) {
            return Row(
              children: [
                _buildSidebar(),

                Expanded(
                  child: Obx(
                        () => pages[
                    selectedIndex
                        .value],
                  ),
                ),
              ],
            );
          }

          return Obx(
                () => pages[
            selectedIndex.value],
          );
        },
      ),

      bottomNavigationBar:
      LayoutBuilder(
        builder: (_, constraints) {
          if (constraints.maxWidth >
              900) {
            return const SizedBox();
          }

          return Obx(
                () => NavigationBar(
              selectedIndex:
              selectedIndex.value,
              onDestinationSelected:
                  (index) {
                selectedIndex.value =
                    index;
              },
                  destinations: const [
                    NavigationDestination(
                      icon:
                      Icon(Icons.dashboard),
                      label:
                      'Dashboard',
                    ),

                    NavigationDestination(
                      icon:
                      Icon(Icons.people),
                      label:
                      'Users',
                    ),

                    NavigationDestination(
                      icon:
                      Icon(
                        Icons.storefront,
                      ),
                      label:
                      'Cafe',
                    ),
                  ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 40),

          const CircleAvatar(
            radius: 35,
            child: Icon(
              Icons.admin_panel_settings,
              size: 40,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'Admin System',
            style: TextStyle(
              fontWeight:
              FontWeight.bold,
              fontSize: 20,
            ),
          ),

          const SizedBox(height: 30),

          _sidebarItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            index: 0,
          ),

          _sidebarItem(
            icon: Icons.people,
            title: 'Users',
            index: 1,
          ),

          _sidebarItem(
            icon: Icons.storefront,
            title: 'Duyệt quán',
            index: 2,
          ),

          const Spacer(),

          Padding(
            padding:
            const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              onPressed:
              controller.logout,
              icon:
              const Icon(Icons.logout),
              label:
              const Text('Đăng xuất'),
              style:
              ElevatedButton.styleFrom(
                minimumSize:
                const Size(
                  double.infinity,
                  55,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    return Obx(
          () {
        final selected =
            selectedIndex.value ==
                index;

        return ListTile(
          leading: Icon(icon),
          title: Text(title),
          selected: selected,
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
                16),
          ),
          onTap: () {
            selectedIndex.value =
                index;
          },
        );
      },
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(20),
        ),

        title: const Row(
          children: [
            Icon(
              Icons.logout,
              color: Colors.red,
            ),
            SizedBox(width: 10),
            Text('Đăng xuất'),
          ],
        ),

        content: const Text(
          'Bạn có chắc muốn đăng xuất khỏi hệ thống?',
        ),

        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Hủy'),
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

              await controller.logout();
            },

            child: const Text(
              'Đăng xuất',
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}