import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/temp/pages/auth_page.dart';
import 'package:project/temp/pages/management_page.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import '../controllers/table_controller.dart';
import 'product_page.dart';

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

        actions: [
          /// MANAGEMENT
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () {
              Get.to(() => const ManagementPage());
            },
          ),

          /// LOGOUT
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(),
          ),
        ],
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

                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
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

                        await controller.selectTable(
                          table,
                        );

                        Get.back();

                        Get.to(() => ProductPage());
                      },

                      onLongPress: () async {
                        if (table.status == 'occupied') {
                          final order = controller
                              .orderController.orders
                              .firstWhereOrNull(
                                (o) =>
                            o.tableId == table.id &&
                                o.status == 'open',
                          );

                          if (order != null) {
                            await _showOrderItems(order.id);
                          }

                          return;
                        }

                        _showEdit(context, table);
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
          await Supabase.instance.client.auth.signOut();

          Get.offAll(
                () => AuthPage(), // thay bằng trang login của bạn
          );
        } catch (e) {
          Get.snackbar(
            "Lỗi",
            "Không thể đăng xuất",
          );
        }
      },
    );
  }

  ////////////////////////////////////////////////////////////

  Future<void> _showOrderItems(
      String orderId,
      ) async {
    final orderController =
        controller.orderController;

    /// load details của order này
    orderController.currentOrderId.value =
        orderId;

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
            final items =
                orderController.details;

            return Column(
              mainAxisSize:
              MainAxisSize.min,

              children: [
                const Text(
                  "Món trong đơn",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                if (items.isEmpty)
                  const Padding(
                    padding:
                    EdgeInsets.all(20),
                    child: Text(
                      "Chưa có món",
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,

                      itemCount:
                      items.length,

                      separatorBuilder:
                          (_, __) =>
                      const Divider(),

                      itemBuilder:
                          (_, index) {
                        final item =
                        items[index];

                        return ListTile(
                          leading:
                          CircleAvatar(
                            backgroundColor:
                            Colors.orange
                                .withOpacity(
                                0.15),

                            child: Text(
                              "${item.quantity}",
                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight
                                    .bold,
                                color:
                                Colors.orange,
                              ),
                            ),
                          ),

                          title: Text(
                            item.productName,
                          ),

                          subtitle: Text(
                            item.sizeName,
                          ),

                          trailing:
                          Column(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                            crossAxisAlignment:
                            CrossAxisAlignment
                                .end,

                            children: [
                              Text(
                                "${item.price.toInt()}đ",
                                style:
                                const TextStyle(
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                ),
                              ),

                              Text(
                                "x${item.quantity}",
                              ),
                            ],
                          ),
                        );
                      },
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

        /// ORDER REALTIME
        final order =
        controller.orderController.orders
            .firstWhereOrNull(
              (o) =>
          o.tableId == table.id &&
              o.status == 'open',
        );

        final isEmpty = order == null;

        /// ITEM COUNT
        final itemCount = order != null
            ? controller.orderController
            .orderItemCounts[order.id] ??
            0
            : 0;

        /// TOTAL
        final total = order?.total ?? 0;

        return AnimatedContainer(
          duration: const Duration(
            milliseconds: 250,
          ),

          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isEmpty
                  ? [
                Colors.green,
                Colors.greenAccent,
              ]
                  : [
                Colors.orange,
                Colors.deepOrange,
              ],

              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),

            borderRadius:
            BorderRadius.circular(22),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),

          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [

              /// ICON
              Icon(
                isEmpty
                    ? Icons.event_seat
                    : Icons.restaurant,

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

              if (isEmpty)
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    color:
                    Colors.white.withOpacity(0.2),

                    borderRadius:
                    BorderRadius.circular(30),
                  ),

                  child: const Text(
                    "Trống",

                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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
    final t = DateTime.parse(time);

    final diff = DateTime.now().difference(t);

    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} phút";
    }

    if (diff.inHours < 24) {
      return "${diff.inHours} giờ";
    }

    return "${diff.inDays} ngày";
  }
}