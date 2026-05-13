import 'package:get/get.dart';
import 'package:project/temp/controllers/table_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../models/order_detail.dart';

class OrderController extends GetxController {
  final supabase = Supabase.instance.client;

  var orders = <Order>[].obs;
  var details = <OrderDetail>[].obs;

  var currentOrderId = ''.obs;

  /// orderId -> số món
  var orderItemCounts = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();

    fetchOrders();
    fetchOrderItemCounts();
  }

  /// ===================== ORDERS =====================

  Future<void> fetchOrders() async {
    final res = await supabase
        .from('orders')
        .select('''
          *,
          tables (
            id,
            name
          )
        ''')
        .eq('status', 'open')
        .order('created_at');

    orders.value = (res as List)
        .map((e) => Order.fromJson(e))
        .toList();
  }

  /// ===================== ITEM COUNT =====================

  Future<void> fetchOrderItemCounts() async {
    final res = await supabase
        .from('order_details')
        .select('order_id, quantity');

    final map = <String, int>{};

    for (final item in res) {
      final orderId = item['order_id'];
      final qty = item['quantity'] as int;

      map[orderId] = (map[orderId] ?? 0) + qty;
    }

    orderItemCounts.value = map;
  }

  /// ===================== GET OR CREATE =====================

  Future<void> getOrCreateOrder(String table) async {
    final res = await supabase
        .from('orders')
        .select()
        .eq('table_id', table)
        .eq('status', 'open')
        .maybeSingle();

    if (res != null) {
      currentOrderId.value = res['id'];
    } else {
      final newOrder = await supabase
          .from('orders')
          .insert({
        'table_id': table,
        'status': 'open',
        'total': 0,
      })
          .select()
          .single();

      currentOrderId.value = newOrder['id'];
    }

    await fetchOrders();
    await fetchDetails();
    await fetchOrderItemCounts();
  }

  Future<void> createOrderIfNeeded() async {
    /// đã có order
    if (currentOrderId.value.isNotEmpty) return;

    final tableController = Get.find<TableController>();

    final table = tableController.selectedTable.value;

    if (table == null) return;

    /// tạo order mới
    final newOrder = await supabase
        .from('orders')
        .insert({
      'table_id': table.id,
      'status': 'open',
      'total': 0,
    })
        .select()
        .single();

    currentOrderId.value = newOrder['id'];

    /// update trạng thái bàn
    await supabase
        .from('tables')
        .update({'status': 'occupied'})
        .eq('id', table.id);

    table.status = 'occupied';

    tableController.tables.refresh();

    await fetchOrders();
  }

  /// ===================== DETAILS =====================

  Future<void> fetchDetails() async {
    final res = await supabase
        .from('order_details')
        .select()
        .eq('order_id', currentOrderId.value);

    details.value = (res as List)
        .map((e) => OrderDetail.fromJson(e))
        .toList();

    await calculateTotal();
  }

  /// ===================== ADD PRODUCT =====================

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

      await supabase.from('order_details').update({
        'quantity': qty,
        'subtotal': qty * price,
      }).eq('id', existing['id']);
    } else {
      await supabase.from('order_details').insert({
        'order_id': currentOrderId.value,
        'product_id': productId,
        'product_name': productName,
        'size_id': sizeId,
        'size_name': sizeName,
        'price': price,
        'quantity': quantity,
        'subtotal': price * quantity,
      });
    }

    await fetchDetails();
    await fetchOrders();
    await fetchOrderItemCounts();
  }

  /// ===================== UPDATE QTY =====================

  Future<void> updateQty(OrderDetail item, int qty) async {
    if (qty <= 0) {
      await supabase
          .from('order_details')
          .delete()
          .eq('id', item.id);
    } else {
      await supabase.from('order_details').update({
        'quantity': qty,
        'subtotal': qty * item.price,
      }).eq('id', item.id);
    }

    await fetchDetails();
    await fetchOrders();
    await fetchOrderItemCounts();
  }

  /// ===================== TOTAL =====================

  Future<void> calculateTotal() async {
    double total = details.fold(
      0,
          (sum, e) => sum + e.subtotal,
    );

    await supabase.from('orders').update({
      'total': total,
    }).eq('id', currentOrderId.value);

    final index = orders.indexWhere(
          (o) => o.id == currentOrderId.value,
    );

    if (index != -1) {
      orders[index] = Order(
        id: orders[index].id,
        tableId: orders[index].tableId,
        tableName: orders[index].tableName,
        total: total,
        status: orders[index].status,
        createdAt: orders[index].createdAt,
      );
    }

    /// QUAN TRỌNG
    orders.refresh();
  }

  /// ===================== PAY =====================

  Future<void> pay() async {
    final order = orders.firstWhere(
          (o) => o.id == currentOrderId.value,
    );

    /// update order -> done
    await supabase
        .from('orders')
        .update({
      'status': 'done',
    })
        .eq('id', currentOrderId.value);

    /// update table -> empty
    await supabase
        .from('tables')
        .update({
      'status': 'empty',
    })
        .eq('id', order.tableId);

    final tableController = Get.find<TableController>();

    /// update realtime local table
    final index = tableController.tables.indexWhere(
          (t) => t.id == order.tableId,
    );

    if (index != -1) {
      tableController.tables[index].status = 'empty';

      tableController.tables.refresh();
    }

    /// remove order local
    orders.removeWhere(
          (o) => o.id == currentOrderId.value,
    );

    /// reset current order
    currentOrderId.value = '';

    /// refresh counts
    await fetchOrderItemCounts();
  }

  /// ===================== DELETE =====================

  Future<void> deleteOrder(String orderId) async {
    await supabase
        .from('order_details')
        .delete()
        .eq('order_id', orderId);

    await supabase
        .from('orders')
        .delete()
        .eq('id', orderId);

    orders.removeWhere((o) => o.id == orderId);

    await fetchOrderItemCounts();
  }
}