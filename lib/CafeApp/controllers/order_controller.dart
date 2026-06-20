import 'package:get/get.dart';
import 'package:project/CafeApp/controllers/product_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/order.dart';
import '../models/order_detail.dart';
import 'table_controller.dart';

class OrderController extends GetxController {
  final supabase = Supabase.instance.client;

  var orders = <Order>[].obs;
  var details = <OrderDetail>[].obs;
  var currentOrderId = ''.obs;

  /// orderId -> số món
  var orderItemCounts = <String, int>{}.obs;

  final doneOrders = <Order>[].obs;

  // Cache cafe_id để không phải query lại nhiều lần
  String? _cafeId;

  @override
  void onInit() {
    super.onInit();

    // Reset state trước khi fetch để tránh data cũ
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
  // LẤY CAFE ID (có cache)
  // =======================

  Future<String> getCafeId() async {
    if (_cafeId != null) return _cafeId!;

    final uid = supabase.auth.currentUser!.id;

    final cafe = await supabase
        .from('cafes')
        .select('id')
        .eq('owner_id', uid)
        .single();

    _cafeId = cafe['id'];
    return _cafeId!;
  }

  /// ===================== ORDERS =====================

  Future<void> fetchOrders() async {
    final cafeId = await getCafeId();

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
        .eq('cafe_id', cafeId)
        .order('created_at');

    orders.value = (res as List).map((e) => Order.fromJson(e)).toList();
  }

  /// ===================== ITEM COUNT =====================

  Future<void> fetchOrderItemCounts() async {
    final cafeId = await getCafeId();

    final res = await supabase
        .from('order_details')
        .select('order_id, quantity')
        .eq('cafe_id', cafeId);

    final map = <String, int>{};

    for (final item in res) {
      final orderId = item['order_id'];
      final qty = item['quantity'] as int;
      map[orderId] = (map[orderId] ?? 0) + qty;
    }

    orderItemCounts.value = map;
  }

  /// ===================== GET OR CREATE ORDER =====================

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
      currentOrderId.value = res['id'];
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

      currentOrderId.value = newOrder['id'];
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

    currentOrderId.value = newOrder['id'];

    await supabase
        .from('tables')
        .update({'status': 'occupied'}).eq('id', table.id);

    table.status = 'occupied';
    tableController.tables.refresh();

    await fetchOrders();
  }

  /// ===================== DETAILS =====================

  Future<List<OrderDetail>> fetchDetails({
    String? orderId,
    bool updateState = true,
  }) async {
    final targetOrderId =
        orderId ?? currentOrderId.value;

    if (targetOrderId.isEmpty) {
      if (updateState) {
        details.clear();
      }
      return [];
    }

    final res = await supabase
        .from('order_details')
        .select()
        .eq('order_id', targetOrderId);

    final list =
    (res as List)
        .map((e) => OrderDetail.fromJson(e))
        .toList();

    // chỉ update state khi là order hiện tại
    if (updateState &&
        targetOrderId == currentOrderId.value) {
      details.value = list;
      await calculateTotal();
    }

    return list;
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

  /// ===================== UPDATE QTY =====================

  Future<void> updateQty(OrderDetail item, int qty) async {
    if (qty <= 0) {
      await supabase.from('order_details').delete().eq('id', item.id);
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
    if (currentOrderId.value.isEmpty) return;

    double total = details.fold(0, (sum, e) => sum + e.subtotal);

    await supabase.from('orders').update({'total': total}).eq(
        'id', currentOrderId.value);

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

  /// ===================== MERGE TABLE =====================

  Future<void> mergeTables({
    required String targetOrderId, // ID của đơn hàng bàn chính (Bàn A)
    required String sourceOrderId, // ID của đơn hàng bàn phụ (Bàn B)
    required String sourceTableId, // ID của Bàn B để reset trạng thái
  }) async {
    try {
      // 1. Chuyển toàn bộ order_details từ Bàn B sang Bàn A
      await supabase
          .from('order_details')
          .update({'order_id': targetOrderId})
          .eq('order_id', sourceOrderId);

      // 2. Xóa order cũ của Bàn B (vì đã rỗng món)
      await supabase.from('orders').delete().eq('id', sourceOrderId);

      // 3. Đổi trạng thái Bàn B thành 'empty' (Trống)
      await supabase
          .from('tables')
          .update({'status': 'empty'})
          .eq('id', sourceTableId);

      // 4. Tính lại tổng tiền cho Bàn A
      // (Bằng cách lấy tất cả subtotal của Bàn A bây giờ và update lên table 'orders')
      final res = await supabase
          .from('order_details')
          .select('subtotal')
          .eq('order_id', targetOrderId);

      double newTotal = (res as List).fold(0.0, (sum, item) => sum + (item['subtotal'] as num));

      await supabase
          .from('orders')
          .update({'total': newTotal})
          .eq('id', targetOrderId);

      // 5. Cập nhật lại UI thông qua GetX
      await fetchOrders();
      await fetchOrderItemCounts();

      // Cập nhật lại TableController để refresh UI bàn
      final tableController = Get.find<TableController>();
      final indexB = tableController.tables.indexWhere((t) => t.id == sourceTableId);
      if (indexB != -1) {
        tableController.tables[indexB].status = 'empty';
      }
      tableController.tables.refresh();

    } catch (e) {
      print("Lỗi khi gộp bàn: $e");
      Get.snackbar("Lỗi", "Không thể gộp bàn, vui lòng thử lại.");
    }
  }

  /// ===================== PAY =====================

  Future<void> pay({String paymentMethod = 'cash'}) async {
    final order = orders.firstWhere((o) => o.id == currentOrderId.value);

    // Cập nhật thêm payment_method lên DB
    await supabase
        .from('orders')
        .update({
      'status': 'done',
      'payment_method': paymentMethod, // Lưu phương thức thanh toán
    })
        .eq('id', currentOrderId.value);

    await supabase
        .from('tables')
        .update({'status': 'empty'}).eq('id', order.tableId);

    final tableController = Get.find<TableController>();

    final index =
    tableController.tables.indexWhere((t) => t.id == order.tableId);

    if (index != -1) {
      tableController.tables[index].status = 'empty';
      tableController.tables.refresh();
    }

    orders.removeWhere((o) => o.id == currentOrderId.value);

    currentOrderId.value = '';
    details.clear();

    await fetchOrderItemCounts();
  }

  /// ===================== DELETE =====================

  Future<void> deleteOrder(String orderId) async {
    await supabase
        .from('order_details')
        .delete()
        .eq('order_id', orderId);

    await supabase.from('orders').delete().eq('id', orderId);

    orders.removeWhere((o) => o.id == orderId);

    await fetchOrderItemCounts();
  }

  /// ================ Fetch Done Order =====================

  Future<void> fetchDoneOrders({
    int? month,
    int? year,
    DateTime? date,
  }) async {
    try {
      final cafeId =
      await ProductController.to.getCafeId();

      DateTime start;
      DateTime end;

      if (date != null) {
        start = DateTime(
          date.year,
          date.month,
          date.day,
        );

        end = start.add(
          const Duration(days: 1),
        );
      } else {
        final now = DateTime.now();

        final selectedMonth =
            month ?? now.month;

        final selectedYear =
            year ?? now.year;

        start = DateTime(
          selectedYear,
          selectedMonth,
          1,
        );

        end = selectedMonth == 12
            ? DateTime(
          selectedYear + 1,
          1,
          1,
        )
            : DateTime(
          selectedYear,
          selectedMonth + 1,
          1,
        );
      }

      final data = await supabase
          .from('orders')
          .select('*, tables(name)')
          .eq('cafe_id', cafeId)
          .eq('status', 'done')
          .gte(
        'created_at',
        start.toIso8601String(),
      )
          .lt(
        'created_at',
        end.toIso8601String(),
      )
          .order(
        'created_at',
        ascending: false,
      );

      doneOrders.value = (data as List)
          .map(
            (e) => Order.fromJson(e),
      )
          .toList();
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không tải lịch sử đơn: $e',
      );
    }
  }

  double get totalRevenue =>
      doneOrders.fold(
        0,
            (sum, order) =>
        sum + order.total,
      );
}