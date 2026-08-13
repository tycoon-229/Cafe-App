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
import 'product/product_page.dart';

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> with SingleTickerProviderStateMixin {
  final controller = Get.find<TableController>();
  final filter = 'all'.obs;

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
  bool _isDrawerOpening() => _drawerSlideController.status == AnimationStatus.forward;
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
                  _isDrawerOpen() || _isDrawerOpening() ? Icons.clear : Icons.menu,
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
          onPressed: _showAddDialog,
          icon: const Icon(Icons.add),
          label: const Text("Thêm bàn"),
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
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }
              final list = tables.where((t) {
                if (filter.value == 'all') return true;
                return t.status == filter.value;
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
                    onTap: () async {
                      Get.dialog(
                        const PopScope(
                          canPop: false,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        barrierDismissible: false,
                      );
                      await controller.selectTable(table);
                      Get.back();
                      Get.to(() => ProductPage());
                    },
                    onLongPress: () async {
                      if (table.status == 'occupied') {
                        final order = controller.orderController.orders.firstWhereOrNull(
                          (o) => o.tableId == table.id && o.status == 'open',
                        );
                        if (order != null) {
                          _showOccupiedTableMenu(context, table, order);
                        }
                        return;
                      }
                      if (table.status == 'merged') {
                        _showMergedTableMenu(context, table);
                        return;
                      }
                      _showEmptyTableMenu(context, table);
                    },
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
          child: _isDrawerClosed() ? const SizedBox() : CustomAnimatedMenu(onClose: _toggleDrawer),
        );
      },
    );
  }

  Widget _chip(String text, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Obx(() {
        final selected = filter.value == value;
        return ChoiceChip(
          label: Text(text),
          selected: selected,
          selectedColor: Colors.orange.withOpacity(0.2),
          labelStyle: TextStyle(
            color: selected ? Colors.orange : Colors.black,
            fontWeight: FontWeight.w600,
          ),
          onSelected: (_) {
            filter.value = value;
          },
        );
      }),
    );
  }

  void _showAddDialog() {
    final txt = TextEditingController();
    Get.defaultDialog(
      title: "Thêm bàn",
      content: TextField(
        controller: txt,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: "Nhập số lượng",
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      textConfirm: "Thêm",
      textCancel: "Hủy",
      confirmTextColor: Colors.white,
      buttonColor: Colors.orange,
      onConfirm: () {
        final count = int.tryParse(txt.text) ?? 0;
        if (count > 0) {
          controller.createMultipleTables(count);
        }
        Get.back();
      },
    );
  }

  void _showEdit(BuildContext context, dynamic table) {
    final txt = TextEditingController(text: table.name);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Wrap(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit, color: Colors.orange),
                  ),
                  title: const Text("Sửa tên"),
                  onTap: () {
                    Get.back();
                    Get.defaultDialog(
                      title: "Sửa bàn",
                      content: TextField(
                        controller: txt,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      textConfirm: "Lưu",
                      textCancel: "Hủy",
                      confirmTextColor: Colors.white,
                      buttonColor: Colors.orange,
                      onConfirm: () {
                        controller.updateTable(table.id, txt.text, table.status);
                        Get.back();
                      },
                    );
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                  title: const Text("Xóa"),
                  onTap: () {
                    Get.back();
                    controller.deleteTable(table.id, table.status);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOccupiedTableMenu(BuildContext context, dynamic sourceTable, dynamic sourceOrder) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.payment, color: Colors.green),
                  title: const Text("Xong đơn / Tính tiền"),
                  onTap: () {
                    Get.back();
                    _showOrderItems(sourceOrder.id);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.merge_type, color: Colors.blue),
                  title: const Text("Gộp hóa đơn vào bàn khác"),
                  onTap: () {
                    Get.back();
                    _showMergeOrderDialog(sourceTable, sourceOrder);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMergeOrderDialog(dynamic sourceTable, dynamic sourceOrder) {
    final occupiedTables = controller.tables.where((t) => t.status == 'occupied' && t.id != sourceTable.id).toList();
    if (occupiedTables.isEmpty) {
      Get.snackbar("Thông báo", "Không có bàn nào khác đang có khách để gộp.");
      return;
    }
    Get.defaultDialog(
      title: "Chọn bàn để gộp hóa đơn",
      content: SizedBox(
        height: 250,
        width: double.maxFinite,
        child: ListView.builder(
          itemCount: occupiedTables.length,
          itemBuilder: (context, index) {
            final targetTable = occupiedTables[index];
            return ListTile(
              leading: const Icon(Icons.restaurant, color: Colors.orange),
              title: Text(targetTable.name),
              onTap: () async {
                Get.back();
                final targetOrder = controller.orderController.orders.firstWhereOrNull(
                  (o) => o.tableId == targetTable.id && o.status == 'open',
                );
                if (targetOrder != null) {
                  Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
                  await controller.orderController.mergeTables(
                    targetOrderId: targetOrder.id,
                    sourceOrderId: sourceOrder.id,
                    sourceTableId: sourceTable.id,
                  );
                  Get.back();
                  Get.snackbar("Thành công", "Đã gộp hóa đơn thành công!");
                }
              },
            );
          },
        ),
      ),
      textCancel: "Hủy",
    );
  }

  void _showEmptyTableMenu(BuildContext context, dynamic table) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.link, color: Colors.blue),
                title: const Text("Ghép sát vào bàn trống khác"),
                onTap: () {
                  Get.back();
                  _showLinkTableDialog(table);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.orange),
                title: const Text("Sửa tên bàn"),
                onTap: () {
                  Get.back();
                  _showEdit(context, table);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLinkTableDialog(dynamic sourceTable) {
    final availableTables =
        controller.tables.where((t) => (t.status == 'empty' || t.status == 'occupied') && t.id != sourceTable.id).toList();
    if (availableTables.isEmpty) {
      Get.snackbar("Thông báo", "Không có bàn nào phù hợp để ghép.");
      return;
    }
    Get.defaultDialog(
      title: "Chọn bàn để ghép vào",
      content: SizedBox(
        height: 250,
        width: double.maxFinite,
        child: ListView.builder(
          itemCount: availableTables.length,
          itemBuilder: (context, index) {
            final targetTable = availableTables[index];
            return ListTile(
              leading: Icon(targetTable.status == 'occupied' ? Icons.restaurant : Icons.event_seat,
                  color: targetTable.status == 'occupied' ? Colors.orange : Colors.green),
              title: Text(targetTable.name),
              onTap: () async {
                Get.back();
                Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
                await controller.linkEmptyTables(sourceTable.id, targetTable.id);
                Get.back();
                Get.snackbar("Thành công", "Đã ghép bàn thành công");
              },
            );
          },
        ),
      ),
      textCancel: "Hủy",
    );
  }

  void _showMergedTableMenu(BuildContext context, dynamic table) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.link_off, color: Colors.red),
                title: const Text("Tách bàn (Hủy ghép)"),
                onTap: () async {
                  Get.back();
                  Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
                  await controller.unlinkTable(table.id);
                  Get.back();
                  Get.snackbar("Thành công", "Đã tách bàn");
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showOrderItems(String orderId) async {
    final orderController = controller.orderController;
    orderController.currentOrderId.value = orderId;
    await orderController.fetchDetails();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Obx(() {
            final items = orderController.details;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Món trong đơn", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  const Padding(padding: EdgeInsets.all(20), child: Text("Chưa có món"))
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (_, index) {
                        final item = items[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.withOpacity(0.15),
                            child: Text("${item.quantity}",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                          ),
                          title: Text(item.productName),
                          subtitle: Text(item.sizeName),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("${item.price.toInt()}đ", style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text("x${item.quantity}"),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (items.isEmpty) return;
                      final totalAmount = items.fold<double>(0, (sum, item) => sum + item.subtotal);
                      final paymentMethod = await Get.dialog<String>(
                        AlertDialog(
                          title: const Text('Phương thức thanh toán'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                  leading: const Icon(Icons.money, color: Colors.green),
                                  title: const Text('Tiền mặt'),
                                  onTap: () => Get.back(result: 'cash')),
                              const Divider(height: 1),
                              ListTile(
                                  leading: const Icon(Icons.account_balance, color: Colors.blue),
                                  title: const Text('Chuyển khoản'),
                                  onTap: () => Get.back(result: 'transfer')),
                            ],
                          ),
                        ),
                      );
                      if (paymentMethod == null) return;
                      bool isConfirmed = false;
                      if (paymentMethod == 'transfer') {
                        final confirm = await Get.dialog<bool>(
                          AlertDialog(
                            title: const Text('Xác nhận'),
                            content: const Text('Bạn có chắc muốn hoàn tất đơn này không?'),
                            actions: [
                              TextButton(onPressed: () => Get.back(result: false), child: const Text('Hủy')),
                              ElevatedButton(onPressed: () => Get.back(result: true), child: const Text('Xác nhận')),
                            ],
                          ),
                        );
                        isConfirmed = confirm == true;
                      } else if (paymentMethod == 'cash') {
                        final TextEditingController cashController = TextEditingController();
                        num khachDua = 0;
                        final confirm = await Get.dialog<bool>(
                          StatefulBuilder(builder: (context, setState) {
                            final tienThua = khachDua - totalAmount;
                            return AlertDialog(
                              title: const Text('Thanh toán tiền mặt'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tổng tiền: ${totalAmount.toInt()}đ',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: cashController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                        labelText: 'Tiền khách đưa', border: OutlineInputBorder(), suffixText: 'đ'),
                                    onChanged: (value) => setState(() => khachDua = num.tryParse(value) ?? 0),
                                  ),
                                  const SizedBox(height: 16),
                                  Text('Tiền thừa: ${tienThua > 0 ? tienThua.toInt() : 0}đ',
                                      style: TextStyle(
                                          color: tienThua >= 0 ? Colors.green : Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  if (tienThua < 0 && khachDua > 0)
                                    const Padding(
                                        padding: EdgeInsets.only(top: 8.0),
                                        child: Text('Khách đưa chưa đủ tiền!',
                                            style: TextStyle(color: Colors.red, fontSize: 12))),
                                ],
                              ),
                              actions: [
                                TextButton(onPressed: () => Get.back(result: false), child: const Text('Hủy')),
                                ElevatedButton(onPressed: tienThua >= 0 ? () => Get.back(result: true) : null, child: const Text('Xác nhận')),
                              ],
                            );
                          }),
                        );
                        isConfirmed = confirm == true;
                      }
                      if (!isConfirmed) return;
                      await orderController.pay(paymentMethod: paymentMethod);
                      Get.back();
                      Get.snackbar('Thành công', 'Đơn hàng đã hoàn tất');
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Xong đơn'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class CustomAnimatedMenu extends StatefulWidget {
  final VoidCallback onClose;
  const CustomAnimatedMenu({super.key, required this.onClose});

  @override
  State<CustomAnimatedMenu> createState() => _CustomAnimatedMenuState();
}

class _CustomAnimatedMenuState extends State<CustomAnimatedMenu> with SingleTickerProviderStateMixin {
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
    {'title': 'Quản lý đơn hàng', 'icon': Icons.receipt_long, 'action': 'orders'},
    {'title': 'Quản lý sản phẩm', 'icon': Icons.fastfood, 'action': 'products'},
    {'title': 'Quản lý thu chi', 'icon': Icons.account_balance_wallet_outlined, 'action': 'expense'},
  ];

  late Duration _animationDuration;

  @override
  void initState() {
    super.initState();
    _animationDuration = _initialDelayTime + (_staggerTime * _menuItems.length) + _buttonDelayTime + _buttonTime;
    _createAnimationIntervals();
    _staggeredController = AnimationController(vsync: this, duration: _animationDuration)..forward();
  }

  void _createAnimationIntervals() {
    for (var i = 0; i < _menuItems.length; ++i) {
      final startTime = _initialDelayTime + (_staggerTime * i);
      final endTime = startTime + _itemSlideTime;
      _itemSlideIntervals.add(Interval(
        startTime.inMilliseconds / _animationDuration.inMilliseconds,
        endTime.inMilliseconds / _animationDuration.inMilliseconds,
      ));
    }
    final buttonStartTime = Duration(milliseconds: _menuItems.length * 50) + _buttonDelayTime;
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
        children: [
          _buildBackground(),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.25,
        child: Image.asset(
          'assets/images/auth_bg.jpg',
          fit: BoxFit.cover,
        ),
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
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            leading: Icon(_menuItems[i]['icon'], color: Colors.orange, size: 28),
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
  final dynamic table;
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
          final parentTable = controller.tables.firstWhereOrNull((t) => t.id == table.mergedTo);
          if (parentTable != null) parentName = parentTable.name;
        }
        final itemCount = order != null ? controller.orderController.orderItemCounts[order.id] ?? 0 : 0;
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
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                status == 'empty' ? Icons.event_seat : (status == 'merged' ? Icons.link : Icons.restaurant),
                color: Colors.white,
                size: 34,
              ),
              const SizedBox(height: 10),
              Text(
                table.name ?? "",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              if (status == 'empty')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text("Trống", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                )
              else if (status == 'merged')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text("Ghép: $parentName",
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                )
              else ...[
                if (order?.createdAt != null)
                  Text("🕒 ${_formatTime(order!.createdAt.toString())}",
                      style: const TextStyle(color: Colors.white, fontSize: 13)),
                const SizedBox(height: 8),
                Text("🍽️ $itemCount món", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text("💰 ${total.toInt()}đ",
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
