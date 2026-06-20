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

class TablePage extends StatelessWidget {
  TablePage({super.key});

  final controller = Get.find<TableController>();

  final filter = 'all'.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),

      appBar: AppBar(
        title: const Text("POS - Quản lý bàn"),
        centerTitle: true,
      ),

      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange,
                      Colors.deepOrange,
                    ],
                  ),
                ),
                child: Obx(() {
                  final cafe =
                      AuthController
                          .to
                          .currentCafe
                          .value;

                  return Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor:
                        Colors.white,
                        child: Icon(
                          Icons.storefront,
                          color:
                          Colors.orange,
                          size: 30,
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      Text(
                        cafe?['cafe_name'] ??
                            'Tên quán',
                        style:
                        const TextStyle(
                          color:
                          Colors.white,
                          fontSize: 20,
                          fontWeight:
                          FontWeight
                              .bold,
                        ),
                      ),

                      Text(
                        cafe?['address'] ??
                            'Quản lý Quán Cafe',
                        style:
                        const TextStyle(
                          color:
                          Colors.white70,
                        ),
                        maxLines: 1,
                        overflow:
                        TextOverflow
                            .ellipsis,
                      ),
                    ],
                  );
                }),
              ),

              /// THÔNG TIN TÀI KHOẢN
              ListTile(
                leading: const Icon(
                  Icons.person,
                ),

                title: const Text(
                  "Thông tin tài khoản",
                ),

                onTap: () async {
                  Get.back();

                  final result = await Get.to(
                        () => EditProfilePage(),
                  );

                  if (result == true) {
                    Get.snackbar(
                      'Thành công',
                      'Đã cập nhật thông tin',
                      snackPosition:
                      SnackPosition.TOP,
                    );
                  }
                },
              ),

              ListTile(
                leading:
                const Icon(Icons.store),

                title:
                const Text(
                  "Thông tin quán",
                ),

                onTap: () async {
                  Get.back();

                  final result =
                  await Get.to(
                        () => EditCafePage(),
                  );

                  if (result == true) {
                    Get.snackbar(
                      'Thành công',
                      'Đã cập nhật thông tin quán',
                      snackPosition:
                      SnackPosition.TOP,
                    );
                  }
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.lock_reset,
                ),
                title: const Text(
                  'Đổi mật khẩu',
                ),
                onTap: () {
                  Get.to(
                        () => const ChangePasswordPage(),
                  );
                },
              ),

              /// QUẢN LÝ ĐƠN HÀNG
              ListTile(
                leading:
                const Icon(Icons.receipt_long),

                title:
                const Text("Quản lý đơn hàng"),

                onTap: () {
                  Get.back();

                  Get.to(
                        () => OrderListPage(),
                  );
                },
              ),

              /// QUẢN LÝ SẢN PHẨM
              ListTile(
                leading:
                const Icon(Icons.fastfood),

                title:
                const Text("Quản lý sản phẩm"),

                onTap: () {
                  Get.back();

                  Get.to(
                        () => ProductManagePage(),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: const Text("Quản lý thu chi"),
                onTap: () {
                  Get.back(); // Đóng Drawer
                  Get.to(() => const ExpenseManagePage()); // Chuyển sang trang thu chi
                },
              ),

              const Divider(),

              /// ĐĂNG XUẤT
              ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),

                title: const Text(
                  "Đăng xuất",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),

                onTap: () {
                  Get.back();
                  _showLogoutDialog();
                },
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,

        onPressed: _showAddDialog,

        icon: const Icon(Icons.add),

        label: const Text("Thêm bàn"),
      ),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            /// FILTER
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _chip("Tất cả", "all"),
                _chip("Trống", "empty"),
                _chip("Đang dùng", "occupied"),
                _chip("Đã ghép", "merged"), // Thêm filter "Đã ghép"
              ],
            ),

            const SizedBox(height: 12),

            /// GRID
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
                  if (filter.value == 'all') {
                    return true;
                  }
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
                  itemBuilder: (_, i) {
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

                        // Đã xử lý logic chọn bàn cha nếu là bàn ghép trong controller
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
                            // Mở menu: Xong đơn hoặc Gộp order
                            _showOccupiedTableMenu(context, table, order);
                          }
                          return;
                        }

                        if (table.status == 'merged') {
                          // Bàn đã ghép -> Cho phép tách
                          _showMergedTableMenu(context, table);
                          return;
                        }

                        // Bàn trống (empty) -> Mở menu: Sửa/Xóa hoặc Ghép bàn
                        _showEmptyTableMenu(context, table);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////

  Widget _chip(String text, String value) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 6),

      child: Obx(() {
        final selected = filter.value == value;

        return ChoiceChip(
          label: Text(text),

          selected: selected,

          selectedColor:
          Colors.orange.withOpacity(0.2),

          labelStyle: TextStyle(
            color: selected
                ? Colors.orange
                : Colors.black,
            fontWeight: FontWeight.w600,
          ),

          onSelected: (_) {
            filter.value = value;
          },
        );
      }),
    );
  }

  ////////////////////////////////////////////////////////////

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
            borderRadius:
            BorderRadius.circular(14),

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
          controller.createMultipleTables(
            count,
          );
        }

        Get.back();
      },
    );
  }

  ////////////////////////////////////////////////////////////

  void _showEdit(
      BuildContext context,
      dynamic table,
      ) {
    final txt =
    TextEditingController(text: table.name);

    showModalBottomSheet(
      context: context,

      backgroundColor: Colors.white,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),

      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
            ),

            child: Wrap(
              children: [

                /// EDIT
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),

                    decoration: BoxDecoration(
                      color:
                      Colors.orange.withOpacity(0.1),

                      borderRadius:
                      BorderRadius.circular(10),
                    ),

                    child: const Icon(
                      Icons.edit,
                      color: Colors.orange,
                    ),
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

                          fillColor:
                          Colors.grey[100],

                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                                14),

                            borderSide:
                            BorderSide.none,
                          ),
                        ),
                      ),

                      textConfirm: "Lưu",
                      textCancel: "Hủy",

                      confirmTextColor:
                      Colors.white,

                      buttonColor: Colors.orange,

                      onConfirm: () {
                        controller.updateTable(
                          table.id,
                          txt.text,
                          table.status,
                        );

                        Get.back();
                      },
                    );
                  },
                ),

                /// DELETE
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),

                    decoration: BoxDecoration(
                      color:
                      Colors.red.withOpacity(0.1),

                      borderRadius:
                      BorderRadius.circular(10),
                    ),

                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                  ),

                  title: const Text("Xóa"),

                  onTap: () {
                    Get.back();

                    controller.deleteTable(
                      table.id,
                      table.status,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ////////////////////////////////////////////////////////////

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
          Get.snackbar(
            "Lỗi",
            "Không thể đăng xuất",
          );
        }
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

  // 2. Dialog chọn bàn đích để gộp Hóa đơn (Order)
  void _showMergeOrderDialog(dynamic sourceTable, dynamic sourceOrder) {
    final occupiedTables = controller.tables.where(
            (t) => t.status == 'occupied' && t.id != sourceTable.id
    ).toList();

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

                  // Gọi hàm mergeTables trong OrderController (bạn nhớ thêm hàm này ở OrderController nhé)
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

  // 3. Menu cho Bàn Trống (Empty)
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
                  _showEdit(context, table); // Mở lại dialog sửa/xóa cũ của bạn (mình tách ra chút)
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 4. Dialog chọn bàn đích để ghép vật lý
  void _showLinkTableDialog(dynamic sourceTable) {
    // Chỉ cho phép ghép vào bàn trống hoặc bàn đang có khách (để làm bàn cha)
    final availableTables = controller.tables.where(
            (t) => (t.status == 'empty' || t.status == 'occupied') && t.id != sourceTable.id
    ).toList();

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
              leading: Icon(
                  targetTable.status == 'occupied' ? Icons.restaurant : Icons.event_seat,
                  color: targetTable.status == 'occupied' ? Colors.orange : Colors.green
              ),
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

  // 5. Menu cho Bàn Đã Ghép (Merged)
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

  ////////////////////////////////////////////////////////////

  Future<void> _showOrderItems(
      String orderId,
      ) async {
    final orderController = controller.orderController;

    /// load details của order này
    orderController.currentOrderId.value = orderId;

    await orderController.fetchDetails();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            final items = orderController.details;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Món trong đơn",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Chưa có món"),
                  )
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
                            child: Text(
                              "${item.quantity}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                          title: Text(item.productName),
                          subtitle: Text(item.sizeName),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${item.price.toInt()}đ",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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

                      // Sử dụng subtotal từ Model OrderDetail để tính tổng
                      final totalAmount = items.fold<double>(
                        0,
                            (sum, item) => sum + item.subtotal,
                      );

                      final paymentMethod = await Get.dialog<String>(
                        AlertDialog(
                          title: const Text('Phương thức thanh toán'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.money, color: Colors.green),
                                title: const Text('Tiền mặt'),
                                onTap: () => Get.back(result: 'cash'),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.account_balance, color: Colors.blue),
                                title: const Text('Chuyển khoản'),
                                onTap: () => Get.back(result: 'transfer'),
                              ),
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
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: const Text('Hủy'),
                              ),
                              ElevatedButton(
                                onPressed: () => Get.back(result: true),
                                child: const Text('Xác nhận'),
                              ),
                            ],
                          ),
                        );
                        isConfirmed = confirm == true;
                      } else if (paymentMethod == 'cash') {
                        final TextEditingController cashController = TextEditingController();
                        num khachDua = 0;

                        final confirm = await Get.dialog<bool>(
                          StatefulBuilder(
                            builder: (context, setState) {
                              final tienThua = khachDua - totalAmount;

                              return AlertDialog(
                                title: const Text('Thanh toán tiền mặt'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tổng tiền: ${totalAmount.toInt()}đ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: cashController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Tiền khách đưa',
                                        border: OutlineInputBorder(),
                                        suffixText: 'đ',
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          khachDua = num.tryParse(value) ?? 0;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Tiền thừa: ${tienThua > 0 ? tienThua.toInt() : 0}đ',
                                      style: TextStyle(
                                        color: tienThua >= 0 ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (tienThua < 0 && khachDua > 0)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          'Khách đưa chưa đủ tiền!',
                                          style: TextStyle(color: Colors.red, fontSize: 12),
                                        ),
                                      ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(result: false),
                                    child: const Text('Hủy'),
                                  ),
                                  ElevatedButton(
                                    onPressed: tienThua >= 0
                                        ? () => Get.back(result: true)
                                        : null,
                                    child: const Text('Xác nhận'),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                        isConfirmed = confirm == true;
                      }

                      if (!isConfirmed) return;

                      // TRUYỀN PHƯƠNG THỨC THANH TOÁN VÀO ĐÂY
                      await orderController.pay(paymentMethod: paymentMethod);
                      Get.back();

                      Get.snackbar(
                        'Thành công',
                        'Đơn hàng đã hoàn tất',
                      );
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Xong đơn'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
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

////////////////////////////////////////////////////////////

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
        /// ORDER REALTIME (Chỉ tính nếu bàn là occupied)
        final order = controller.orderController.orders.firstWhereOrNull(
              (o) => o.tableId == table.id && o.status == 'open',
        );

        final status = table.status; // 'empty', 'occupied', hoặc 'merged'

        /// TÌM TÊN BÀN CHA (Nếu bàn đang bị ghép)
        String parentName = "Bàn khác";
        if (status == 'merged' && table.mergedTo != null) {
          final parentTable = controller.tables.firstWhereOrNull(
                  (t) => t.id == table.mergedTo
          );
          if (parentTable != null) {
            parentName = parentTable.name;
          }
        }

        /// ITEM COUNT
        final itemCount = order != null
            ? controller.orderController.orderItemCounts[order.id] ?? 0
            : 0;

        /// TOTAL
        final total = order?.total ?? 0;

        // Cài đặt màu sắc dựa trên status
        List<Color> gradientColors;
        if (status == 'empty') {
          gradientColors = [Colors.green, Colors.greenAccent];
        } else if (status == 'merged') {
          gradientColors = [Colors.blue, Colors.lightBlueAccent]; // Màu cho bàn ghép
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
              /// ICON
              Icon(
                status == 'empty'
                    ? Icons.event_seat
                    : (status == 'merged' ? Icons.link : Icons.restaurant),
                color: Colors.white,
                size: 34,
              ),

              const SizedBox(height: 10),

              /// TABLE NAME
              Text(
                table.name ?? "",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 10),

              // Hiển thị trạng thái/thông tin
              if (status == 'empty')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    "Ghép: $parentName", // Đã thay đổi ở đây
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12, // Hạ size chữ một chút để không bị tràn
                    ),
                  ),
                )
              else ...[
                  /// TIME
                  if (order?.createdAt != null)
                    Text(
                      "🕒 ${_formatTime(order!.createdAt.toString())}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),

                  const SizedBox(height: 8),

                  /// ITEM COUNT
                  Text(
                    "🍽️ $itemCount món",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// TOTAL
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

  ////////////////////////////////////////////////////////////

  String _formatTime(String time) {
    final createdTime =
    DateTime.parse(time).toLocal();

    final diff =
    DateTime.now().difference(createdTime);

    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} phút";
    }

    if (diff.inHours < 24) {
      return "${diff.inHours} giờ";
    }

    return "${diff.inDays} ngày";
  }
}