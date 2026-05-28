import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin_controller.dart';

class DashboardPage
    extends StatelessWidget {
  DashboardPage({
    super.key,
  });

  final controller =
  Get.find<AdminController>();

  @override
  Widget build(
      BuildContext context,
      ) {
    return RefreshIndicator(
      onRefresh:
      controller.refreshUsers,

      child: Obx(
            () => SingleChildScrollView(
          physics:
          const AlwaysScrollableScrollPhysics(),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,

            children: [
              /// HEADER
              _buildHeader(),

              const SizedBox(
                height: 24,
              ),

              /// STATS
              LayoutBuilder(
                builder:
                    (_, constraints) {
                  int count = 4;

                  if (constraints
                      .maxWidth <
                      1100) {
                    count = 2;
                  }

                  if (constraints
                      .maxWidth <
                      650) {
                    count = 1;
                  }

                  return GridView.count(
                    shrinkWrap:
                    true,

                    physics:
                    const NeverScrollableScrollPhysics(),

                    crossAxisCount:
                    count,

                    crossAxisSpacing:
                    18,

                    mainAxisSpacing:
                    18,

                    childAspectRatio:
                    1.7,

                    children: [
                      _buildStatCard(
                        title:
                        'Tổng tài khoản',

                        value: controller
                            .totalUsers
                            .value
                            .toString(),

                        icon:
                        Icons.people,

                        gradient: const [
                          Color(
                            0xffFF9F43,
                          ),
                          Color(
                            0xffFF7A00,
                          ),
                        ],
                      ),

                      _buildStatCard(
                        title:
                        'Admin',

                        value: controller
                            .totalAdmins
                            .value
                            .toString(),

                        icon: Icons
                            .admin_panel_settings,

                        gradient: const [
                          Color(
                            0xff6C63FF,
                          ),
                          Color(
                            0xff5145CD,
                          ),
                        ],
                      ),

                      _buildStatCard(
                        title:
                        'Đang hoạt động',

                        value: controller
                            .totalActiveUsers
                            .value
                            .toString(),

                        icon:
                        Icons
                            .check_circle,

                        gradient: const [
                          Color(
                            0xff2ECC71,
                          ),
                          Color(
                            0xff27AE60,
                          ),
                        ],
                      ),

                      _buildStatCard(
                        title:
                        'Đã khóa',

                        value: controller
                            .totalBlockedUsers
                            .value
                            .toString(),

                        icon:
                        Icons.block,

                        gradient: const [
                          Color(
                            0xffFF6B6B,
                          ),
                          Color(
                            0xffE74C3C,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(
                height: 30,
              ),

              /// RECENT USERS
              _buildRecentUsers(),

              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,

      padding:
      const EdgeInsets.all(28),

      decoration:
      BoxDecoration(
        borderRadius:
        BorderRadius.circular(
          30,
        ),

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
      ),

      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,

            decoration:
            BoxDecoration(
              color: Colors
                  .white
                  .withOpacity(
                .2,
              ),

              borderRadius:
              BorderRadius.circular(
                22,
              ),
            ),

            child:
            const Icon(
              Icons
                  .dashboard_rounded,
              color:
              Colors.white,
              size: 35,
            ),
          ),

          const SizedBox(
            width: 20,
          ),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [
                Text(
                  'Admin Dashboard',

                  style:
                  TextStyle(
                    color: Colors
                        .white,
                    fontSize:
                    28,
                    fontWeight:
                    FontWeight
                        .bold,
                  ),
                ),

                SizedBox(
                  height: 6,
                ),

                Text(
                  'Quản lý hệ thống quán cafe',

                  style:
                  TextStyle(
                    color:
                    Colors.white70,
                    fontSize:
                    15,
                  ),
                ),
              ],
            ),
          ),

          InkWell(
            borderRadius:
            BorderRadius.circular(
              18,
            ),

            onTap: controller
                .refreshUsers,

            child: Container(
              width: 56,
              height: 56,

              decoration:
              BoxDecoration(
                color: Colors
                    .white
                    .withOpacity(
                  .18,
                ),

                borderRadius:
                BorderRadius.circular(
                  18,
                ),
              ),

              child:
              const Icon(
                Icons.refresh,
                color:
                Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color>
    gradient,
  }) {
    return Container(
      padding:
      const EdgeInsets.all(22),

      decoration:
      BoxDecoration(
        borderRadius:
        BorderRadius.circular(
          28,
        ),

        gradient:
        LinearGradient(
          colors: gradient,
        ),

        boxShadow: [
          BoxShadow(
            color: gradient.first
                .withOpacity(
              .25,
            ),
            blurRadius: 18,
            offset:
            const Offset(
              0,
              8,
            ),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,

            decoration:
            BoxDecoration(
              color: Colors
                  .white
                  .withOpacity(
                .2,
              ),

              borderRadius:
              BorderRadius.circular(
                18,
              ),
            ),

            child:
            Icon(
              icon,
              color:
              Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(
            width: 16,
          ),

          Expanded(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment
                  .center,

              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [
                Text(
                  title,

                  style:
                  const TextStyle(
                    color: Colors
                        .white70,
                    fontSize:
                    14,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Text(
                  value,

                  style:
                  const TextStyle(
                    color:
                    Colors.white,
                    fontSize:
                    28,
                    fontWeight:
                    FontWeight
                        .bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentUsers() {
    return Container(
      width: double.infinity,

      padding:
      const EdgeInsets.all(24),

      decoration:
      BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(
          28,
        ),

        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            color: Colors
                .black
                .withOpacity(
              .05,
            ),
          ),
        ],
      ),

      child: Column(
        children: [
          Row(
            children: const [
              Icon(
                Icons.people_alt,
                color:
                Colors.orange,
              ),

              SizedBox(
                width: 10,
              ),

              Text(
                'Người dùng gần đây',

                style:
                TextStyle(
                  fontSize:
                  20,
                  fontWeight:
                  FontWeight
                      .bold,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 20,
          ),

          if (controller
              .users.isEmpty)
            const Padding(
              padding:
              EdgeInsets.all(
                50,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons
                        .folder_open,
                    size: 55,
                    color:
                    Colors.grey,
                  ),

                  SizedBox(
                    height:
                    14,
                  ),

                  Text(
                    'Chưa có dữ liệu',
                  ),
                ],
              ),
            )
          else
            ...controller.users
                .take(5)
                .map(
                  (user) =>
                  Container(
                    margin:
                    const EdgeInsets.only(
                      bottom:
                      14,
                    ),

                    decoration:
                    BoxDecoration(
                      color: const Color(
                        0xfff8f9fc,
                      ),

                      borderRadius:
                      BorderRadius.circular(
                        20,
                      ),
                    ),

                    child:
                    ListTile(
                      contentPadding:
                      const EdgeInsets.symmetric(
                        horizontal:
                        18,
                        vertical:
                        8,
                      ),

                      leading:
                      CircleAvatar(
                        radius:
                        26,

                        backgroundImage:
                        user['avatar_url'] !=
                            null
                            ? NetworkImage(
                          user['avatar_url'],
                        )
                            : null,

                        child: user[
                        'avatar_url'] ==
                            null
                            ? const Icon(
                          Icons.person,
                        )
                            : null,
                      ),

                      title:
                      Text(
                        user['username'] ??
                            'Chưa có tên',

                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      subtitle:
                      Text(
                        user['email'] ??
                            '',
                      ),

                      trailing:
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
                          color: user['role'] ==
                              'admin'
                              ? Colors.orange.withOpacity(
                            .12,
                          )
                              : Colors.blue.withOpacity(
                            .12,
                          ),

                          borderRadius:
                          BorderRadius.circular(
                            30,
                          ),
                        ),

                        child:
                        Text(
                          user['role'] ??
                              'user',

                          style:
                          TextStyle(
                            color: user['role'] ==
                                'admin'
                                ? Colors.orange
                                : Colors.blue,

                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
            ),
        ],
      ),
    );
  }
}