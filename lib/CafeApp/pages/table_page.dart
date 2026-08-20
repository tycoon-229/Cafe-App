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
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: const Text(
          "POS - Quản lý bàn",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.deepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          AnimatedBuilder(
            animation: _drawerSlideController,
            builder: (context, child) {
              return IconButton(
                onPressed: _toggleDrawer,
                icon: Icon(
                  _isDrawerOpen() || _isDrawerOpening()
                      ? Icons.clear
                      : Icons.menu,
                  color: Colors.white,
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
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          onPressed: controller.showAddDialog,
          icon: const Icon(Icons.add),
          label: const Text("Thêm bàn"),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/auth_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _chip("Tất cả", "all"),
              _chip("Trống", "empty"),
              _chip("Đang dùng", "occupied"),
              _chip("Đã ghép", "merged"),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              final tables = controller.tables;
              if (tables.isEmpty) {
                return const Center(
                  child: Text(
                    "Chưa có bàn",
                    style: TextStyle(fontSize: 16, color: Colors.white),
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
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
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
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Obx(() {
        final selected = controller.filter.value == value;
        return ChoiceChip(
          label: Text(text),
          selected: selected,
          selectedColor: Colors.orange.withValues(alpha: 0.2),
          labelStyle: TextStyle(
            color: selected ? Colors.orange : Colors.black,
            fontWeight: FontWeight.w600,
          ),
          onSelected: (_) {
            controller.filter.value = value;
          },
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
  static const _staggerTime = Duration(milliseconds: 50);
  static const _buttonDelayTime = Duration(milliseconds: 150);
  static const _buttonTime = Duration(milliseconds: 500);

  late AnimationController _staggeredController;
  final List<Interval> _itemSlideIntervals = [];
  late Interval _buttonInterval;

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Thông tin tài khoản', 'icon': Icons.person, 'action': 'profile'},
    {'title': 'Thông tin quán', 'icon': Icons.store, 'action': 'cafe'},
    {'title': 'Đổi mật khẩu', 'icon': Icons.lock_reset, 'action': 'password'},
    {
      'title': 'Quản lý đơn hàng',
      'icon': Icons.receipt_long,
      'action': 'orders',
    },
    {'title': 'Quản lý sản phẩm', 'icon': Icons.fastfood, 'action': 'products'},
    {
      'title': 'Quản lý thu chi',
      'icon': Icons.account_balance_wallet_outlined,
      'action': 'expense',
    },
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
        Duration(milliseconds: _menuItems.length * 50) + _buttonDelayTime;
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
        if (result == true)
          Get.snackbar('Thành công', 'Đã cập nhật thông tin quán');
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
      middleText: "Bạn có chắc muốn đăng xuất?",
      textConfirm: "Đăng xuất",
      textCancel: "Hủy",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
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
      color: Colors.white,
      child: Stack(
        fit: StackFit.expand,
        children: [_buildBackground(), _buildContent()],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.25,
        child: Image.asset('assets/images/auth_bg.jpg', fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          ..._buildListItems(),
          const Spacer(),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Colors.orange, Colors.deepOrange]),
      ),
      child: Obx(() {
        final cafe = AuthController.to.currentCafe.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Icon(Icons.storefront, color: Colors.orange, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              cafe?['cafe_name'] ?? 'Tên quán',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              cafe?['address'] ?? 'Quản lý Quán Cafe',
              style: const TextStyle(color: Colors.white70),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
            final opacity = animationPercent;
            final slideDistance = (1.0 - animationPercent) * 150;
            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(slideDistance, 0),
                child: child,
              ),
            );
          },
          child: ListTile(
            onTap: () => _handleMenuAction(_menuItems[i]['action']),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 4,
            ),
            leading: Icon(
              _menuItems[i]['icon'],
              color: Colors.orange,
              size: 28,
            ),
            title: Text(
              _menuItems[i]['title'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      );
    }
    return listItems;
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AnimatedBuilder(
          animation: _staggeredController,
          builder: (context, child) {
            final animationPercent = Curves.elasticOut.transform(
              _buttonInterval.transform(_staggeredController.value),
            );
            final opacity = animationPercent.clamp(0.0, 1.0);
            final scale = (animationPercent * 0.5) + 0.5;
            return Opacity(
              opacity: opacity,
              child: Transform.scale(scale: scale, child: child),
            );
          },
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
            ),
            onPressed: () => _handleMenuAction('logout'),
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất', style: TextStyle(fontSize: 18)),
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

        List<Color> gradientColors;
        if (status == 'empty') {
          gradientColors = [Colors.green, Colors.greenAccent];
        } else if (status == 'merged') {
          gradientColors = [Colors.blue, Colors.lightBlueAccent];
        } else {
          gradientColors = [Colors.orange, Colors.deepOrange];
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                status == 'empty'
                    ? Icons.event_seat
                    : (status == 'merged' ? Icons.link : Icons.restaurant),
                color: Colors.white,
                size: 34,
              ),
              const SizedBox(height: 10),
              Text(
                table.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              if (status == 'empty')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    "Trống",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else if (status == 'merged')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    "Ghép: $parentName",
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                )
              else ...[
                if (order?.createdAt != null)
                  Text(
                    "🕒 ${_formatTime(order!.createdAt.toString())}",
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                const SizedBox(height: 8),
                Text(
                  "🍽️ $itemCount món",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "💰 ${total.toInt()}đ",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  String _formatTime(String time) {
    final createdTime = DateTime.parse(time).toLocal();
    final diff = DateTime.now().difference(createdTime);
    if (diff.inMinutes < 60) return "${diff.inMinutes} phút";
    if (diff.inHours < 24) return "${diff.inHours} giờ";
    return "${diff.inDays} ngày";
  }
}
