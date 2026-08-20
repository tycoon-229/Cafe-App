import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/order.dart';
import '../models/order_detail.dart';
import 'table_controller.dart';
import 'expense_controller.dart';
import '../dialogs/order_dialogs.dart';

class OrderController extends GetxController {
  final supabase = Supabase.instance.client;

  var orders = <Order>[].obs;
  var details = <OrderDetail>[].obs;
  var currentOrderId = ''.obs;

  /// orderId -> số món
  var orderItemCounts = <String, int>{}.obs;

  final doneOrders = <Order>[].obs;

  // Filter states for OrderHistoryPage
  final historyMonth = DateTime.now().month.obs;
  final historyYear = DateTime.now().year.obs;
  final historyDate = Rxn<DateTime>();

  // Cache cafe_id để không phải query lại nhiều lần
  String? _cafeId;

  @override
  void onInit() {
    super.onInit();
    _resetState();
    _initData();
  }

  @override
  void onClose() {
    _resetState();
    super.onClose();
  }

  void _resetState() {
    orders.clear();
    details.clear();
    orderItemCounts.clear();
    currentOrderId.value = '';
    _cafeId = null;
  }

  Future<void> _initData() async {
    await fetchOrders();
    await fetchOrderItemCounts();
  }

  // =======================
  // UTILS
  // =======================

  Future<String> getCafeId() async {
    if (_cafeId != null) return _cafeId!;
    final uid = supabase.auth.currentUser!.id;
    final cafe = await supabase
        .from('cafes')
        .select('id')
        .eq('owner_id', uid)
        .single();
    _cafeId = cafe['id'].toString();
    return _cafeId!;
  }

  Future<void> updateHistoryMonth(int month) async {
    historyMonth.value = month;
    historyDate.value = null;
    await fetchDoneOrders(month: historyMonth.value, year: historyYear.value);
    if (Get.isRegistered<ExpenseController>()) {
      await Get.find<ExpenseController>().fetchExpensesForStats(
        month: historyMonth.value,
        year: historyYear.value,
      );
    }
  }

  Future<void> updateHistoryYear(int year) async {
    historyYear.value = year;
    historyDate.value = null;
    await fetchDoneOrders(month: historyMonth.value, year: historyYear.value);
    if (Get.isRegistered<ExpenseController>()) {
      await Get.find<ExpenseController>().fetchExpensesForStats(
        month: historyMonth.value,
        year: historyYear.value,
      );
    }
  }

  Future<void> pickHistoryDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: historyDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    historyDate.value = pickedDate;
    await fetchDoneOrders(date: pickedDate);
    if (Get.isRegistered<ExpenseController>()) {
      await Get.find<ExpenseController>().fetchExpensesForStats(
        date: pickedDate,
      );
    }
  }

  void clearHistoryDateFilter() async {
    historyDate.value = null;
    await fetchDoneOrders(month: historyMonth.value, year: historyYear.value);
    if (Get.isRegistered<ExpenseController>()) {
      await Get.find<ExpenseController>().fetchExpensesForStats(
        month: historyMonth.value,
        year: historyYear.value,
      );
    }
  }

  // =======================
  // ORDERS CRUD
  // =======================

  Future<void> fetchOrders() async {
    final cafeId = await getCafeId();
    final res = await supabase
        .from('orders')
        .select('*, tables (id, name)')
        .eq('status', 'open')
        .eq('cafe_id', cafeId)
        .order('created_at');
    orders.value = (res as List).map((e) => Order.fromJson(e)).toList();
  }

  Future<void> fetchOrderItemCounts() async {
    final cafeId = await getCafeId();
    final res = await supabase
        .from('order_details')
        .select('order_id, quantity')
        .eq('cafe_id', cafeId);
    final map = <String, int>{};
    for (final item in res) {
      final orderId = item['order_id'].toString();
      final qty = item['quantity'] as int;
      map[orderId] = (map[orderId] ?? 0) + qty;
    }
    orderItemCounts.value = map;
  }

  Future<void> getOrCreateOrder(String tableId) async {
    final cafeId = await getCafeId();
    final res = await supabase
        .from('orders')
        .select()
        .eq('table_id', tableId)
        .eq('status', 'open')
        .eq('cafe_id', cafeId)
        .maybeSingle();

    if (res != null) {
      currentOrderId.value = res['id'].toString();
    } else {
      final newOrder = await supabase
          .from('orders')
          .insert({
            'table_id': tableId,
            'status': 'open',
            'total': 0,
            'cafe_id': cafeId,
          })
          .select()
          .single();
      currentOrderId.value = newOrder['id'].toString();
    }

    await fetchOrders();
    await fetchDetails();
    await fetchOrderItemCounts();
  }

  Future<void> createOrderIfNeeded() async {
    if (currentOrderId.value.isNotEmpty) return;
    final tableController = Get.find<TableController>();
    final table = tableController.selectedTable.value;
    if (table == null) return;

    final cafeId = await getCafeId();
    final newOrder = await supabase
        .from('orders')
        .insert({
          'table_id': table.id,
          'status': 'open',
          'total': 0,
          'cafe_id': cafeId,
        })
        .select()
        .single();

    currentOrderId.value = newOrder['id'].toString();
    await supabase
        .from('tables')
        .update({'status': 'occupied'})
        .eq('id', table.id);
    if (Get.isRegistered<TableController>()) {
      await Get.find<TableController>().fetchTables();
    }
    await fetchOrders();
  }

  // =======================
  // ORDER DETAILS
  // =======================

  Future<List<OrderDetail>> fetchDetails({
    String? orderId,
    bool updateState = true,
  }) async {
    final targetOrderId = orderId ?? currentOrderId.value;
    if (targetOrderId.isEmpty) {
      if (updateState) details.clear();
      return [];
    }

    final res = await supabase
        .from('order_details')
        .select()
        .eq('order_id', targetOrderId);
    final list = (res as List).map((e) => OrderDetail.fromJson(e)).toList();

    if (updateState && targetOrderId == currentOrderId.value) {
      details.value = list;
      await calculateTotal();
    }
    return list;
  }

  Future<void> addProduct({
    required String productId,
    required String productName,
    required String sizeId,
    required String sizeName,
    required double price,
    int quantity = 1,
  }) async {
    await createOrderIfNeeded();
    final existing = await supabase
        .from('order_details')
        .select()
        .eq('order_id', currentOrderId.value)
        .eq('product_id', productId)
        .eq('size_id', sizeId)
        .maybeSingle();

    if (existing != null) {
      final qty = (existing['quantity'] as int) + quantity;
      await supabase
          .from('order_details')
          .update({'quantity': qty, 'subtotal': qty * price})
          .eq('id', existing['id']);
    } else {
      final cafeId = await getCafeId();
      await supabase.from('order_details').insert({
        'order_id': currentOrderId.value,
        'product_id': productId,
        'product_name': productName,
        'size_id': sizeId,
        'size_name': sizeName,
        'price': price,
        'quantity': quantity,
        'subtotal': price * quantity,
        'cafe_id': cafeId,
      });
    }

    await fetchDetails();
    await fetchOrders();
    await fetchOrderItemCounts();
  }

  Future<void> updateQty(OrderDetail item, int qty) async {
    if (qty <= 0) {
      await supabase.from('order_details').delete().eq('id', item.id);
    } else {
      await supabase
          .from('order_details')
          .update({'quantity': qty, 'subtotal': qty * item.price})
          .eq('id', item.id);
    }
    await fetchDetails();
    await fetchOrders();
    await fetchOrderItemCounts();
  }

  Future<void> calculateTotal() async {
    if (currentOrderId.value.isEmpty) return;
    double total = details.fold(0, (sum, e) => sum + e.subtotal);
    await supabase
        .from('orders')
        .update({'total': total})
        .eq('id', currentOrderId.value);
    final index = orders.indexWhere((o) => o.id == currentOrderId.value);
    if (index != -1) {
      orders[index] = Order(
        id: orders[index].id,
        tableId: orders[index].tableId,
        tableName: orders[index].tableName,
        total: total,
        status: orders[index].status,
        createdAt: orders[index].createdAt,
        paymentMethod: orders[index].paymentMethod,
      );
    }
    orders.refresh();
  }

  // =======================
  // ACTIONS
  // =======================

  Future<void> mergeTables({
    required String targetOrderId,
    required String sourceOrderId,
    required String sourceTableId,
  }) async {
    try {
      await supabase
          .from('order_details')
          .update({'order_id': targetOrderId})
          .eq('order_id', sourceOrderId);
      await supabase.from('orders').delete().eq('id', sourceOrderId);
      await supabase
          .from('tables')
          .update({'status': 'empty'})
          .eq('id', sourceTableId);

      final res = await supabase
          .from('order_details')
          .select('subtotal')
          .eq('order_id', targetOrderId);
      double newTotal = (res as List).fold(
        0.0,
        (sum, item) => sum + (item['subtotal'] as num),
      );
      await supabase
          .from('orders')
          .update({'total': newTotal})
          .eq('id', targetOrderId);

      await fetchOrders();
      await fetchOrderItemCounts();
      final tableController = Get.find<TableController>();
      await tableController.fetchTables();
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể gộp bàn");
    }
  }

  // =======================
  // PAYMENT UI
  // =======================

  Future<void> startPaymentProcess(double totalAmount) async {
    final method = await OrderDialogs.showPaymentMethodSelector();
    if (method == null) return;

    bool isConfirmed = false;
    if (method == 'transfer') {
      isConfirmed =
          await Get.dialog<bool>(
            AlertDialog(
              title: const Text('Xác nhận'),
              content: const Text('Đã nhận được tiền chuyển khoản?'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  child: const Text('Đã nhận'),
                ),
              ],
            ),
          ) ??
          false;
    } else {
      isConfirmed =
          await OrderDialogs.showCashPaymentDialog(totalAmount: totalAmount) ??
          false;
    }

    if (!isConfirmed) return;

    await pay(paymentMethod: method);
    Get.back(); // Back from detail page
    Get.snackbar(
      "Thành công",
      "Đã thanh toán đơn",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> showOrderDetailsAndPay(String orderId) async {
    currentOrderId.value = orderId;
    final items = await fetchDetails(orderId: orderId);
    OrderDialogs.showOrderDetailsSheet(
      items: items,
      onComplete: () =>
          startPaymentProcess(items.fold(0, (sum, e) => sum + e.subtotal)),
    );
  }

  Future<void> pay({String paymentMethod = 'cash'}) async {
    final order = orders.firstWhere((o) => o.id == currentOrderId.value);
    await supabase
        .from('orders')
        .update({'status': 'done', 'payment_method': paymentMethod})
        .eq('id', currentOrderId.value);
    await supabase
        .from('tables')
        .update({'status': 'empty'})
        .eq('id', order.tableId);
    if (Get.isRegistered<TableController>()) {
      await Get.find<TableController>().fetchTables();
    }
    orders.removeWhere((o) => o.id == currentOrderId.value);
    currentOrderId.value = '';
    details.clear();
    await fetchOrderItemCounts();
  }

  Future<void> deleteOrder(String orderId) async {
    final order = orders.firstWhereOrNull((o) => o.id == orderId);
    await supabase.from('order_details').delete().eq('order_id', orderId);
    await supabase.from('orders').delete().eq('id', orderId);

    if (order != null) {
      final tableId = order.tableId;
      final otherOrders = orders.where(
        (o) => o.tableId == tableId && o.id != orderId && o.status == 'open',
      );
      if (otherOrders.isEmpty) {
        await supabase
            .from('tables')
            .update({'status': 'empty'})
            .eq('id', tableId);
        if (Get.isRegistered<TableController>())
          await Get.find<TableController>().fetchTables();
      }
    }
    orders.removeWhere((o) => o.id == orderId);
    await fetchOrderItemCounts();
  }

  Future<void> fetchDoneOrders({int? month, int? year, DateTime? date}) async {
    try {
      final cafeId = await getCafeId();
      DateTime start, end;
      if (date != null) {
        start = DateTime(date.year, date.month, date.day);
        end = start.add(const Duration(days: 1));
      } else {
        final now = DateTime.now();
        final m = month ?? now.month;
        final y = year ?? now.year;
        start = DateTime(y, m, 1);
        end = m == 12 ? DateTime(y + 1, 1, 1) : DateTime(y, m + 1, 1);
      }

      final data = await supabase
          .from('orders')
          .select('*, tables(name)')
          .eq('cafe_id', cafeId)
          .eq('status', 'done')
          .gte('created_at', start.toIso8601String())
          .lt('created_at', end.toIso8601String())
          .order('created_at', ascending: false);

      doneOrders.value = (data as List).map((e) => Order.fromJson(e)).toList();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không tải lịch sử đơn');
    }
  }

  double get totalRevenue =>
      doneOrders.fold(0, (sum, order) => sum + order.total);
}
