import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/table.dart';
import 'order_controller.dart';

class TableController extends GetxController {
  final supabase = Supabase.instance.client;

  var tables = <CafeTable>[].obs;
  var selectedTable = Rxn<CafeTable>();

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

  /// Lấy id quán
  Future<String> getCafeId() async {
    final uid = supabase.auth.currentUser!.id;

    final cafe = await supabase
        .from('cafes')
        .select('id')
        .eq('owner_id', uid)
        .single();

    return cafe['id'];
  }

  /// ===================== TABLE =====================

  Future<void> fetchTables() async {
    try {
      final cafeId = await getCafeId();

      final res = await supabase
          .from('tables')
          .select()
          .eq('cafe_id', cafeId);

      final list = (res as List)
          .map((e) => CafeTable.fromJson(e))
          .toList();

      list.sort(
            (a, b) => _compareVietnamese(a.name, b.name),
      );

      tables.value = list;
    } catch (e) {
      print("ERROR TABLE: $e");
      Get.snackbar(
        "Lỗi",
        "Không tải được danh sách bàn",
      );
    }
  }

  int _compareVietnamese(String a, String b) {
    final reg = RegExp(r'\d+');

    final aNum = reg.firstMatch(a);
    final bNum = reg.firstMatch(b);

    if (aNum != null && bNum != null) {
      final numA = int.tryParse(aNum.group(0)!);
      final numB = int.tryParse(bNum.group(0)!);

      if (numA != null && numB != null) {
        return numA.compareTo(numB);
      }
    }

    return a.compareTo(b);
  }

  /// ===================== CHECK STATE =====================

  bool hasOpenOrder(String tableId) {
    return orderController.orders.any(
          (o) => o.tableId == tableId && o.status == 'open',
    );
  }

  // Kiểm tra xem bàn này có đang làm "Bàn cha" (có bàn khác ghép vào) không
  bool hasMergedChildren(String tableId) {
    return tables.any((t) => t.mergedTo == tableId);
  }

  /// ===================== GHÉP / TÁCH BÀN VẬT LÝ =====================

  /// Nối bàn B (source) vào bàn A (target)
  Future<void> linkEmptyTables(String sourceTableId, String targetTableId) async {
    try {
      // Chuyển trạng thái bàn phụ sang 'merged' và trỏ ID về bàn chính
      await supabase.from('tables').update({
        'status': 'merged',
        'merged_to': targetTableId,
      }).eq('id', sourceTableId);

      await fetchTables();
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể ghép bàn: $e");
    }
  }

  /// Tách bàn ra (hủy ghép)
  Future<void> unlinkTable(String sourceTableId) async {
    try {
      // Trả bàn về trạng thái trống và xóa liên kết
      await supabase.from('tables').update({
        'status': 'empty',
        'merged_to': null,
      }).eq('id', sourceTableId);

      await fetchTables();
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể tách bàn: $e");
    }
  }

  /// ===================== ACTION =====================

  Future<void> selectTable(CafeTable table) async {
    try {
      CafeTable targetTable = table;

      // LOGIC THÔNG MINH: Nếu thu ngân bấm nhầm vào "Bàn con" đang bị ghép,
      // hệ thống tự động chuyển hướng sang "Bàn cha" để đặt món chung 1 bill.
      if (table.status == 'merged' && table.mergedTo != null) {
        final parent = tables.firstWhereOrNull((t) => t.id == table.mergedTo);
        if (parent != null) {
          targetTable = parent;
        }
      }

      selectedTable.value = targetTable;

      /// reset current order
      orderController.currentOrderId.value = '';

      /// nếu có order open thì load lại
      if (hasOpenOrder(targetTable.id)) {
        await orderController.getOrCreateOrder(targetTable.id);
      }
    } catch (e) {
      Get.snackbar(
        "Lỗi",
        "Không thể chọn bàn",
      );
    }
  }

  /// ===================== CREATE =====================

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
      print(e);
      Get.snackbar(
        "Lỗi",
        "Không thể thêm bàn",
      );
    }
  }

  /// ===================== UPDATE =====================

  Future<void> updateTable(
      String id,
      String newName,
      String status,
      ) async {
    if (hasOpenOrder(id)) {
      Get.snackbar(
        "Không thể sửa",
        "Bàn đang có đơn",
      );
      return;
    }

    try {
      await supabase
          .from('tables')
          .update({
        'name': newName,
      })
          .eq('id', id);

      await fetchTables();
    } catch (e) {
      Get.snackbar(
        "Lỗi",
        "Không thể cập nhật bàn",
      );
    }
  }

  /// ===================== DELETE =====================

  Future<void> deleteTable(
      String id,
      String status,
      ) async {
    if (hasOpenOrder(id)) {
      Get.snackbar(
        "Lỗi",
        "Bàn đang có khách",
      );
      return;
    }

    // Chặn xóa nếu đang có bàn khác ghép vào nó
    if (hasMergedChildren(id)) {
      Get.snackbar(
        "Lỗi",
        "Bàn này đang được ghép với bàn khác. Vui lòng tách bàn trước khi xóa.",
      );
      return;
    }

    try {
      await supabase
          .from('tables')
          .delete()
          .eq('id', id);

      await fetchTables();
    } catch (e) {
      Get.snackbar(
        "Lỗi",
        "Không thể xoá bàn",
      );
    }
  }
}