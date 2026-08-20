import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/table.dart';
import 'order_controller.dart';
import '../pages/product/product_page.dart';
import '../dialogs/table_dialogs.dart';

class TableController extends GetxController {
  final supabase = Supabase.instance.client;

  var tables = <CafeTable>[].obs;
  var selectedTable = Rxn<CafeTable>();
  final filter = 'all'.obs;

  final OrderController orderController = Get.find<OrderController>();

  @override
  void onInit() {
    super.onInit();
    tables.clear();
    fetchTables();

    /// realtime orders
    orderController.fetchOrders();
    orderController.fetchOrderItemCounts();
  }

  // =======================
  // UI NAVIGATION
  // =======================

  void showAddDialog() {
    TableDialogs.showAddTable((count) => createMultipleTables(count));
  }

  void showEditDialog(BuildContext context, CafeTable table) {
    TableDialogs.showEditTableMenu(
      context: context,
      table: table,
      onRename: (newName) => updateTable(table.id, newName, table.status),
      onDelete: () => deleteTable(table.id, table.status),
    );
  }

  void showOccupiedTableMenu(
    BuildContext context,
    CafeTable sourceTable,
    dynamic sourceOrder,
  ) {
    TableDialogs.showOccupiedMenu(
      context: context,
      table: sourceTable,
      onPay: () => orderController.showOrderDetailsAndPay(sourceOrder.id),
      onMerge: () => showMergeOrderDialog(sourceTable, sourceOrder),
    );
  }

  void showMergeOrderDialog(CafeTable sourceTable, dynamic sourceOrder) {
    final occupiedTables = tables
        .where((t) => t.status == 'occupied' && t.id != sourceTable.id)
        .toList();

    if (occupiedTables.isEmpty) {
      Get.snackbar("Thông báo", "Không có bàn nào khác đang có khách để gộp.");
      return;
    }

    TableDialogs.showSelectionDialog(
      title: "Chọn bàn để gộp hóa đơn",
      items: occupiedTables,
      onSelected: (targetTable) async {
        final targetOrder = orderController.orders.firstWhereOrNull(
          (o) => o.tableId == targetTable.id && o.status == 'open',
        );

        if (targetOrder != null) {
          Get.showOverlay(
            asyncFunction: () => orderController.mergeTables(
              targetOrderId: targetOrder.id,
              sourceOrderId: sourceOrder.id,
              sourceTableId: sourceTable.id,
            ),
            loadingWidget: const Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  void showEmptyTableMenu(BuildContext context, CafeTable table) {
    TableDialogs.showEmptyMenu(
      context: context,
      table: table,
      onLink: () => showLinkTableDialog(table),
      onEdit: () => showEditDialog(context, table),
    );
  }

  void showLinkTableDialog(CafeTable sourceTable) {
    final availableTables = tables
        .where(
          (t) =>
              (t.status == 'empty' || t.status == 'occupied') &&
              t.id != sourceTable.id,
        )
        .toList();

    if (availableTables.isEmpty) {
      Get.snackbar("Thông báo", "Không có bàn nào phù hợp để ghép.");
      return;
    }

    TableDialogs.showSelectionDialog(
      title: "Chọn bàn để ghép vào",
      items: availableTables,
      onSelected: (targetTable) async {
        Get.showOverlay(
          asyncFunction: () => linkEmptyTables(sourceTable.id, targetTable.id),
          loadingWidget: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  void showMergedTableMenu(BuildContext context, CafeTable table) {
    TableDialogs.showMergedMenu(
      context: context,
      onUnlink: () async {
        Get.showOverlay(
          asyncFunction: () => unlinkTable(table.id),
          loadingWidget: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Future<void> handleTableTap(CafeTable table) async {
    await selectTable(table);
    Get.to(() => const ProductPage());
  }

  void handleTableLongPress(BuildContext context, CafeTable table) {
    if (table.status == 'occupied') {
      final order = orderController.orders.firstWhereOrNull(
        (o) => o.tableId == table.id && o.status == 'open',
      );
      if (order != null) {
        showOccupiedTableMenu(context, table, order);
      }
      return;
    }
    if (table.status == 'merged') {
      showMergedTableMenu(context, table);
      return;
    }
    showEmptyTableMenu(context, table);
  }

  // =======================
  // LOGIC
  // =======================

  Future<String> getCafeId() async {
    final uid = supabase.auth.currentUser!.id;
    final cafe = await supabase
        .from('cafes')
        .select('id')
        .eq('owner_id', uid)
        .single();
    return cafe['id'].toString();
  }

  Future<void> fetchTables() async {
    try {
      final cafeId = await getCafeId();
      final res = await supabase
          .from('tables')
          .select()
          .eq('cafe_id', cafeId)
          .eq('is_active', true);
      final list = (res as List).map((e) => CafeTable.fromJson(e)).toList();
      list.sort((a, b) => _compareVietnamese(a.name, b.name));
      tables.value = list;
    } catch (e) {
      Get.snackbar("Lỗi", "Không tải được danh sách bàn");
    }
  }

  int _compareVietnamese(String a, String b) {
    final reg = RegExp(r'\d+');
    final aNum = reg.firstMatch(a);
    final bNum = reg.firstMatch(b);
    if (aNum != null && bNum != null) {
      final numA = int.tryParse(aNum.group(0)!);
      final numB = int.tryParse(bNum.group(0)!);
      if (numA != null && numB != null) return numA.compareTo(numB);
    }
    return a.compareTo(b);
  }

  bool hasOpenOrder(String tableId) {
    final normalizedId = tableId.toString();
    return orderController.orders.any(
      (o) => o.tableId == normalizedId && o.status == 'open',
    );
  }

  bool hasMergedChildren(String tableId) {
    final normalizedId = tableId.toString();
    return tables.any((t) => t.mergedTo == normalizedId);
  }

  Future<void> linkEmptyTables(
    String sourceTableId,
    String targetTableId,
  ) async {
    try {
      await supabase
          .from('tables')
          .update({'status': 'merged', 'merged_to': targetTableId})
          .eq('id', sourceTableId);
      await fetchTables();
      Get.snackbar("Thành công", "Đã ghép bàn");
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể ghép bàn: $e");
    }
  }

  Future<void> unlinkTable(String sourceTableId) async {
    try {
      await supabase
          .from('tables')
          .update({'status': 'empty', 'merged_to': null})
          .eq('id', sourceTableId);
      await fetchTables();
      Get.snackbar("Thành công", "Đã tách bàn");
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể tách bàn: $e");
    }
  }

  Future<void> selectTable(CafeTable table) async {
    try {
      CafeTable targetTable = table;
      if (table.status == 'merged' && table.mergedTo != null) {
        final parent = tables.firstWhereOrNull((t) => t.id == table.mergedTo);
        if (parent != null) targetTable = parent;
      }
      selectedTable.value = targetTable;
      orderController.currentOrderId.value = '';
      if (hasOpenOrder(targetTable.id)) {
        await orderController.getOrCreateOrder(targetTable.id);
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể chọn bàn");
    }
  }

  Future<void> createMultipleTables(int count) async {
    try {
      final existing = tables.length;
      final cafeId = await getCafeId();
      for (int i = 1; i <= count; i++) {
        await supabase.from('tables').insert({
          'name': 'Bàn ${existing + i}',
          'status': 'empty',
          'cafe_id': cafeId,
        });
      }
      await fetchTables();
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể thêm bàn");
    }
  }

  Future<void> updateTable(String id, String newName, String status) async {
    if (hasOpenOrder(id)) {
      Get.snackbar("Không thể sửa", "Bàn đang có đơn");
      return;
    }
    try {
      await supabase.from('tables').update({'name': newName}).eq('id', id);
      await fetchTables();
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể cập nhật bàn");
    }
  }

  Future<void> deleteTable(String id, String status) async {
    if (hasOpenOrder(id)) {
      Get.snackbar("Lỗi", "Bàn đang có khách hoặc đơn chưa thanh toán");
      return;
    }
    if (hasMergedChildren(id)) {
      Get.snackbar(
        "Lỗi",
        "Bàn này đang được ghép với bàn khác. Vui lòng tách bàn trước khi xóa.",
      );
      return;
    }
    try {
      // Soft delete: update is_active to false
      await supabase.from('tables').update({'is_active': false}).eq('id', id);
      await fetchTables();
      Get.snackbar("Thành công", "Đã xóa bàn");
    } catch (e) {
      Get.snackbar(
        "Lỗi",
        "Không thể xóa bàn. Vui lòng thử lại sau.",
      );
    }
  }
}
