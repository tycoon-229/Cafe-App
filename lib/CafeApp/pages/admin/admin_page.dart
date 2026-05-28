import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin_controller.dart';
import 'account_approval_page.dart';
import 'cafe_approval_page.dart';
import 'dashboard_page.dart';
import 'user_management_page.dart';

class AdminPage extends StatelessWidget {
  AdminPage({super.key});

  final controller =
  Get.put(AdminController());

  final selectedIndex = 0.obs;

  final pages = [
    DashboardPage(),
    UserManagementPage(),
    const AccountApprovalPage(),
    const CafeApprovalPage(),
  ];

  final titles = [
    'Dashboard',
    'Quản lý User',
    'Duyệt tài khoản',
    'Duyệt quán cafe',
  ];

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      const Color(
        0xfff5f7fb,
      ),

      appBar: AppBar(
        backgroundColor:
        Colors.white,
        elevation: 0,
        scrolledUnderElevation:
        0,

        title: Obx(
              () => Text(
            titles[
            selectedIndex
                .value],
            style:
            const TextStyle(
              fontWeight:
              FontWeight
                  .bold,
              color:
              Colors.black,
            ),
          ),
        ),

        actions: [
          Container(
            margin:
            const EdgeInsets
                .only(
              right: 12,
            ),

            child: Row(
              children: [
                _actionButton(
                  icon:
                  Icons.refresh,
                  onTap: controller
                      .refreshUsers,
                ),

                const SizedBox(
                  width: 10,
                ),

                _actionButton(
                  icon:
                  Icons.logout,
                  onTap:
                  _showLogoutDialog,
                ),
              ],
            ),
          ),
        ],
      ),

      body: LayoutBuilder(
        builder:
            (_, constraints) {
          final isDesktop =
              constraints
                  .maxWidth >
                  900;

          if (isDesktop) {
            return Row(
              children: [
                _buildSidebar(),

                Expanded(
                  child:
                  Padding(
                    padding:
                    const EdgeInsets
                        .all(
                      20,
                    ),

                    child: Obx(
                          () =>
                          AnimatedSwitcher(
                            duration:
                            const Duration(
                              milliseconds:
                              250,
                            ),
                            child: pages[
                            selectedIndex.value],
                          ),
                    ),
                  ),
                ),
              ],
            );
          }

          return Padding(
            padding:
            const EdgeInsets
                .all(16),
            child: Obx(
                  () => pages[
              selectedIndex
                  .value],
            ),
          );
        },
      ),

      bottomNavigationBar:
      LayoutBuilder(
        builder:
            (_, constraints) {
          if (constraints
              .maxWidth >
              900) {
            return const SizedBox();
          }

          return Obx(
                () =>
                NavigationBar(
                  height: 72,
                  selectedIndex:
                  selectedIndex
                      .value,

                  onDestinationSelected:
                      (index) {
                    selectedIndex
                        .value = index;
                  },

                  destinations:
                  const [
                    NavigationDestination(
                      icon: Icon(
                        Icons
                            .dashboard_outlined,
                      ),
                      selectedIcon:
                      Icon(
                        Icons
                            .dashboard,
                      ),
                      label:
                      'Dashboard',
                    ),

                    NavigationDestination(
                      icon: Icon(
                        Icons
                            .people_outline,
                      ),
                      selectedIcon:
                      Icon(
                        Icons.people,
                      ),
                      label:
                      'Users',
                    ),

                    NavigationDestination(
                      icon: Icon(
                        Icons
                            .verified_user_outlined,
                      ),
                      selectedIcon:
                      Icon(Icons
                          .verified_user),
                      label:
                      'Tài khoản',
                    ),

                    NavigationDestination(
                      icon: Icon(
                        Icons
                            .storefront_outlined,
                      ),
                      selectedIcon:
                      Icon(
                        Icons
                            .storefront,
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
      width: 280,

      decoration:
      const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            color: Color(
              0x11000000,
            ),
          ),
        ],
      ),

      child: Column(
        children: [
          const SizedBox(
            height: 40,
          ),

          /// HEADER
          Container(
            margin:
            const EdgeInsets
                .symmetric(
              horizontal: 20,
            ),
            padding:
            const EdgeInsets
                .all(20),

            decoration:
            BoxDecoration(
              gradient:
              const LinearGradient(
                colors: [
                  Color(
                    0xffFF9F43,
                  ),
                  Color(
                    0xffFF7A00,
                  ),
                ],
              ),

              borderRadius:
              BorderRadius.circular(
                28,
              ),
            ),

            child: const Column(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor:
                  Colors.white,

                  child: Icon(
                    Icons
                        .admin_panel_settings,
                    size: 40,
                    color: Color(
                      0xffFF7A00,
                    ),
                  ),
                ),

                SizedBox(
                  height: 14,
                ),

                Text(
                  'Admin System',

                  style:
                  TextStyle(
                    color: Colors
                        .white,
                    fontSize:
                    20,
                    fontWeight:
                    FontWeight
                        .bold,
                  ),
                ),

                SizedBox(
                  height: 4,
                ),

                Text(
                  'Cafe Management',

                  style:
                  TextStyle(
                    color: Colors
                        .white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 28,
          ),

          _sidebarItem(
            icon:
            Icons.dashboard,
            title:
            'Dashboard',
            index: 0,
          ),

          _sidebarItem(
            icon: Icons.people,
            title:
            'Quản lý User',
            index: 1,
          ),

          _sidebarItem(
            icon: Icons
                .verified_user,
            title:
            'Duyệt tài khoản',
            index: 2,
          ),

          _sidebarItem(
            icon:
            Icons.storefront,
            title:
            'Duyệt quán',
            index: 3,
          ),

          const Spacer(),

          Padding(
            padding:
            const EdgeInsets
                .all(20),

            child:
            SizedBox(
              width:
              double.infinity,
              height: 56,

              child:
              ElevatedButton.icon(
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  Colors.red,
                  foregroundColor:
                  Colors.white,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      18,
                    ),
                  ),
                ),

                onPressed:
                controller
                    .logout,

                icon:
                const Icon(
                  Icons.logout,
                ),

                label:
                const Text(
                  'Đăng xuất',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem({
    required IconData
    icon,
    required String
    title,
    required int index,
  }) {
    return Obx(
          () {
        final selected =
            selectedIndex
                .value ==
                index;

        return AnimatedContainer(
          duration:
          const Duration(
            milliseconds:
            220,
          ),

          margin:
          const EdgeInsets
              .symmetric(
            horizontal: 16,
            vertical: 5,
          ),

          decoration:
          BoxDecoration(
            color: selected
                ? Colors.orange
                .withOpacity(
                .12)
                : Colors
                .transparent,

            borderRadius:
            BorderRadius.circular(
              18,
            ),
          ),

          child: ListTile(
            contentPadding:
            const EdgeInsets
                .symmetric(
              horizontal: 18,
            ),

            leading: Icon(
              icon,
              color: selected
                  ? Colors
                  .orange
                  : Colors
                  .grey,
            ),

            title: Text(
              title,
              style:
              TextStyle(
                fontWeight:
                FontWeight
                    .w600,

                color: selected
                    ? Colors
                    .orange
                    : Colors
                    .black87,
              ),
            ),

            onTap: () {
              selectedIndex
                  .value = index;
            },
          ),
        );
      },
    );
  }

  Widget _actionButton({
    required IconData
    icon,
    required VoidCallback
    onTap,
  }) {
    return InkWell(
      borderRadius:
      BorderRadius.circular(
        14,
      ),

      onTap: onTap,

      child: Container(
        width: 46,
        height: 46,

        decoration:
        BoxDecoration(
          color:
          Colors.grey[100],

          borderRadius:
          BorderRadius.circular(
            14,
          ),
        ),

        child: Icon(icon),
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(
            24,
          ),
        ),

        title:
        const Text(
          'Đăng xuất',
        ),

        content:
        const Text(
          'Bạn có chắc muốn đăng xuất khỏi hệ thống?',
        ),

        actions: [
          TextButton(
            onPressed:
            Get.back,
            child:
            const Text(
              'Hủy',
            ),
          ),

          ElevatedButton(
            style:
            ElevatedButton.styleFrom(
              backgroundColor:
              Colors.red,
            ),

            onPressed:
                () async {
              Get.back();
              await controller
                  .logout();
            },

            child:
            const Text(
              'Đăng xuất',
            ),
          ),
        ],
      ),
      barrierDismissible:
      false,
    );
  }
}