import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/CafeApp/pages/product/product_manage_page.dart';

import '../controllers/auth_controller.dart';
import '../controllers/table_controller.dart';
import 'auth/change_password_page.dart';
import 'auth/edit_profile_page.dart';
import 'cafe/edit_cafe_page.dart';
import 'order/expense_manage_page.dart';
import 'order/order_list_page.dart';
import '../models/table.dart';

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage>
    with SingleTickerProviderStateMixin {
  final controller = Get.find<TableController>();
  late AnimationController _drawerSlideController;

  @override
  void initState() {
    super.initState();
    _drawerSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _drawerSlideController.dispose();
    super.dispose();
  }

  bool _isDrawerOpen() => _drawerSlideController.value == 1.0;
  bool _isDrawerOpening() =>
      _drawerSlideController.status == AnimationStatus.forward;
  bool _isDrawerClosed() => _drawerSlideController.value == 0.0;

  void _toggleDrawer() {
    if (_isDrawerOpen() || _isDrawerOpening()) {
      _drawerSlideController.reverse();
    } else {
      _drawerSlideController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Quản lý bàn",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(color: Color(0xffe5e5e5), width: 1),
        ),
        actions: [
          AnimatedBuilder(
            animation: _drawerSlideController,
            builder: (context, child) {
              return IconButton(
                onPressed: _toggleDrawer,
                icon: Icon(
                  _isDrawerOpen() || _isDrawerOpening()
                      ? Icons.close_rounded
                      : Icons.menu_rounded,
                  color: Colors.black,
                  size: 24,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _drawerSlideController,
        builder: (context, child) {
          return ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 0.0).animate(
              CurvedAnimation(
                parent: _drawerSlideController,
                curve: Curves.easeIn,
              ),
            ),
            child: child,
          );
        },
        child: FloatingActionButton.extended(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          onPressed: controller.showAddDialog,
          icon: const Icon(Icons.add, size: 20),
          label: const Text(
            "Thêm bàn",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ),
      body: Stack(
        children: [
          _buildMainContent(),
          _buildDrawer(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _chip("Tất cả", "all"),
                _chip("Trống", "empty"),
                _chip("Đang dùng", "occupied"),
                _chip("Đã ghép", "merged"),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Obx(() {
              final tables = controller.tables;
              if (tables.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.table_restaurant_outlined,
                          size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        "Chưa có bàn nào được tạo",
                        style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                );
              }
              final list = tables.where((t) {
                if (controller.filter.value == 'all') return true;
                return t.status == controller.filter.value;
              }).toList();

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, i) {
                  final table = list[i];
                  return _TableItem(
                    table: table,
                    controller: controller,
                    onTap: () => controller.handleTableTap(table),
                    onLongPress: () =>
                        controller.handleTableLongPress(context, table),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return AnimatedBuilder(
      animation: _drawerSlideController,
      builder: (context, child) {
        return FractionalTranslation(
          translation: Offset(1.0 - _drawerSlideController.value, 0.0),
          child: _isDrawerClosed()
              ? const SizedBox()
              : CustomAnimatedMenu(onClose: _toggleDrawer),
        );
      },
    );
  }

  Widget _chip(String text, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Obx(() {
        final selected = controller.filter.value == value;
        return GestureDetector(
          onTap: () => controller.filter.value = value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? Colors.black : const Color(0xfffafafa),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? Colors.black : const Color(0xffe5e5e5),
                width: 1,
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class CustomAnimatedMenu extends StatelessWidget {
  final VoidCallback onClose;
  const CustomAnimatedMenu({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return _CustomAnimatedMenuContent(onClose: onClose);
  }
}

class _CustomAnimatedMenuContent extends StatefulWidget {
  final VoidCallback onClose;
  const _CustomAnimatedMenuContent({required this.onClose});

  @override
  State<_CustomAnimatedMenuContent> createState() =>
      _CustomAnimatedMenuContentState();
}

class _CustomAnimatedMenuContentState extends State<_CustomAnimatedMenuContent>
    with SingleTickerProviderStateMixin {
  static const _initialDelayTime = Duration(milliseconds: 50);
  static const _itemSlideTime = Duration(milliseconds: 250);
  static const _staggerTime = Duration(milliseconds: 40);
  static const _buttonDelayTime = Duration(milliseconds: 100);
  static const _buttonTime = Duration(milliseconds: 400);

  late AnimationController _staggeredController;
  final List<Interval> _itemSlideIntervals = [];
  late Interval _buttonInterval;

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Thông tin tài khoản', 'icon': Icons.person_outline_rounded, 'action': 'profile'},
    {'title': 'Thông tin quán', 'icon': Icons.storefront_outlined, 'action': 'cafe'},
    {'title': 'Đổi mật khẩu', 'icon': Icons.lock_outline_rounded, 'action': 'password'},
    {'title': 'Quản lý đơn hàng', 'icon': Icons.receipt_outlined, 'action': 'orders'},
    {'title': 'Quản lý thực đơn', 'icon': Icons.restaurant_menu_rounded, 'action': 'products'},
    {'title': 'Quản lý thu chi', 'icon': Icons.account_balance_wallet_outlined, 'action': 'expense'},
  ];

  late Duration _animationDuration;

  @override
  void initState() {
    super.initState();
    _animationDuration =
        _initialDelayTime +
            (_staggerTime * _menuItems.length) +
            _buttonDelayTime +
            _buttonTime;
    _createAnimationIntervals();
    _staggeredController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    )..forward();
  }

  void _createAnimationIntervals() {
    for (var i = 0; i < _menuItems.length; ++i) {
      final startTime = _initialDelayTime + (_staggerTime * i);
      final endTime = startTime + _itemSlideTime;
      _itemSlideIntervals.add(
        Interval(
          startTime.inMilliseconds / _animationDuration.inMilliseconds,
          endTime.inMilliseconds / _animationDuration.inMilliseconds,
        ),
      );
    }
    final buttonStartTime =
        Duration(milliseconds: _menuItems.length * 40) + _buttonDelayTime;
    final buttonEndTime = buttonStartTime + _buttonTime;
    _buttonInterval = Interval(
      buttonStartTime.inMilliseconds / _animationDuration.inMilliseconds,
      buttonEndTime.inMilliseconds / _animationDuration.inMilliseconds,
    );
  }

  @override
  void dispose() {
    _staggeredController.dispose();
    super.dispose();
  }

  void _handleMenuAction(String action) async {
    widget.onClose();
    switch (action) {
      case 'profile':
        final result = await Get.to(() => EditProfilePage());
        if (result == true) Get.snackbar('Thành công', 'Đã cập nhật thông tin');
        break;
      case 'cafe':
        final result = await Get.to(() => EditCafePage());
        if (result == true) Get.snackbar('Thành công', 'Đã cập nhật thông tin quán');
        break;
      case 'password':
        Get.to(() => const ChangePasswordPage());
        break;
      case 'orders':
        Get.to(() => OrderListPage());
        break;
      case 'products':
        Get.to(() => ProductManagePage());
        break;
      case 'expense':
        Get.to(() => const ExpenseManagePage());
        break;
      case 'logout':
        _showLogoutDialog();
        break;
    }
  }

  void _showLogoutDialog() {
    Get.defaultDialog(
      title: "Đăng xuất",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      middleText: "Bạn có chắc chắn muốn đăng xuất?",
      middleTextStyle: TextStyle(color: Colors.grey.shade600),
      textConfirm: "Đăng xuất",
      textCancel: "Hủy",
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.black,
      buttonColor: Colors.black,
      radius: 14,
      onConfirm: () async {
        try {
          await AuthController.to.logout();
        } catch (e) {
          Get.snackbar("Lỗi", "Không thể đăng xuất");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Divider(color: Color(0xfff0f0f0), height: 1),
            const SizedBox(height: 12),
            ..._buildListItems(),
            const Spacer(),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Obx(() {
        final cafe = AuthController.to.currentCafe.value;
        return Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black12, width: 1.5),
                color: const Color(0xfffafafa),
              ),
              child: const Icon(Icons.coffee_rounded, color: Colors.black87, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cafe?['cafe_name'] ?? 'Tên quán',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cafe?['address'] ?? 'Quản lý cửa hàng',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  List<Widget> _buildListItems() {
    final listItems = <Widget>[];
    for (var i = 0; i < _menuItems.length; ++i) {
      listItems.add(
        AnimatedBuilder(
          animation: _staggeredController,
          builder: (context, child) {
            final animationPercent = Curves.easeOut.transform(
              _itemSlideIntervals[i].transform(_staggeredController.value),
            );
            return Opacity(
              opacity: animationPercent,
              child: Transform.translate(
                offset: Offset((1.0 - animationPercent) * 80, 0),
                child: child,
              ),
            );
          },
          child: ListTile(
            onTap: () => _handleMenuAction(_menuItems[i]['action']),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
            leading: Icon(
              _menuItems[i]['icon'],
              color: Colors.black87,
              size: 22,
            ),
            title: Text(
              _menuItems[i]['title'],
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      );
    }
    return listItems;
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: AnimatedBuilder(
        animation: _staggeredController,
        builder: (context, child) {
          final animationPercent = Curves.easeOut.transform(
            _buttonInterval.transform(_staggeredController.value),
          );
          return Opacity(
            opacity: animationPercent.clamp(0.0, 1.0),
            child: child,
          );
        },
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xffe5e5e5), width: 1.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            foregroundColor: Colors.black87,
          ),
          onPressed: () => _handleMenuAction('logout'),
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: const Text(
            'Đăng xuất',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _TableItem extends StatelessWidget {
  final CafeTable table;
  final TableController controller;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _TableItem({
    required this.table,
    required this.controller,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Obx(() {
        final order = controller.orderController.orders.firstWhereOrNull(
              (o) => o.tableId == table.id && o.status == 'open',
        );
        final status = table.status;
        String parentName = "Bàn khác";
        if (status == 'merged' && table.mergedTo != null) {
          final parentTable = controller.tables.firstWhereOrNull(
                (t) => t.id == table.mergedTo,
          );
          if (parentTable != null) parentName = parentTable.name;
        }
        final itemCount = order != null
            ? controller.orderController.orderItemCounts[order.id] ?? 0
            : 0;
        final total = order?.total ?? 0;

        final bool isOccupied = status == 'occupied';

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isOccupied ? Colors.black : const Color(0xfffafafa),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOccupied ? Colors.black : const Color(0xffe5e5e5),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Table Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    table.name,
                    style: TextStyle(
                      color: isOccupied ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Icon(
                    status == 'empty'
                        ? Icons.check_circle_outline_rounded
                        : (status == 'merged' ? Icons.link_rounded : Icons.radio_button_checked_rounded),
                    color: isOccupied ? Colors.white70 : Colors.black38,
                    size: 16,
                  ),
                ],
              ),

              // Middle Information Block
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (status == 'empty')
                    Text(
                      "Trống",
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    )
                  else if (status == 'merged')
                    Text(
                      "Ghép: $parentName",
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isOccupied ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    )
                  else ...[
                      Text(
                        "$itemCount món",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${total.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                ],
              ),

              // Bottom Meta Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (status == 'occupied' && order?.createdAt != null)
                    Text(
                      _formatTime(order!.createdAt.toString()),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  else
                    const SizedBox(height: 14),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  String _formatTime(String time) {
    final createdTime = DateTime.parse(time).toLocal();
    final diff = DateTime.now().difference(createdTime);
    if (diff.inMinutes < 60) return "${diff.inMinutes} phút trước";
    if (diff.inHours < 24) return "${diff.inHours} giờ trước";
    return "${diff.inDays} ngày trước";
  }
}