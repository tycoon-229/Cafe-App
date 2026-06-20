import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expense.dart';

class ExpenseController extends GetxController {
  final supabase = Supabase.instance.client;

  var expenses = <Expense>[].obs;
  var isLoading = false.obs;

  // Dùng cho trang thống kê
  var statExpenses = <Expense>[].obs;
  double get totalExpense => statExpenses.fold(0, (sum, e) => sum + e.amount);

  // Biến cache lưu trữ ID quán để tránh gọi Database nhiều lần
  String? _cafeId;

  @override
  void onInit() {
    super.onInit();
    fetchExpenses();
  }

  /// ===================== LẤY CAFE ID (CÓ CACHE) =====================
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

  /// ===================== HÀM XỬ LÝ LẤY DỮ LIỆU DÙNG CHUNG =====================
  Future<List<Expense>> _getExpensesData({
    int? month,
    int? year,
    DateTime? date,
  }) async {
    final cafeId = await getCafeId();
    DateTime start;
    DateTime end;

    // Xử lý logic thời gian
    if (date != null) {
      start = DateTime(date.year, date.month, date.day);
      end = start.add(const Duration(days: 1));
    } else {
      final now = DateTime.now();
      final selectedMonth = month ?? now.month;
      final selectedYear = year ?? now.year;

      start = DateTime(selectedYear, selectedMonth, 1);
      end = selectedMonth == 12
          ? DateTime(selectedYear + 1, 1, 1)
          : DateTime(selectedYear, selectedMonth + 1, 1);
    }

    final res = await supabase
        .from('expenses')
        .select()
        .eq('cafe_id', cafeId)
        .gte('created_at', start.toIso8601String())
        .lt('created_at', end.toIso8601String())
        .order('created_at', ascending: false);

    return (res as List).map((e) => Expense.fromJson(e)).toList();
  }

  /// ===================== LẤY DANH SÁCH CHO QUẢN LÝ THU CHI =====================
  Future<void> fetchExpenses({
    int? month,
    int? year,
    DateTime? date,
  }) async {
    try {
      isLoading.value = true;

      expenses.value = await _getExpensesData(
        month: month,
        year: year,
        date: date,
      );

    } catch (e) {
      print("Lỗi tải thu chi: $e");
      Get.snackbar("Lỗi", "Không tải được danh sách thu chi");
    } finally {
      isLoading.value = false;
    }
  }

  /// ===================== LẤY DANH SÁCH CHO TRANG THỐNG KÊ =====================
  Future<void> fetchExpensesForStats({
    int? month,
    int? year,
    DateTime? date,
  }) async {
    try {

      statExpenses.value = await _getExpensesData(
        month: month,
        year: year,
        date: date,
      );

    } catch (e) {
      print("Lỗi tải thu chi thống kê: $e");
    }
  }

  /// ===================== THÊM KHOẢN CHI =====================
  Future<void> addExpense(String title, double amount, String description) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final cafeId = await getCafeId();

      await supabase.from('expenses').insert({
        'title': title,
        'amount': amount,
        'description': description.isEmpty ? null : description,
        'cafe_id': cafeId,
      });

      Get.back();
      Get.back();

      Get.snackbar(
        "Thành công",
        "Đã ghi nhận khoản chi thực tế",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.back();
      Get.snackbar("Lỗi", "Không thể thêm khoản chi: $e");
    }
  }

  /// ===================== XÓA KHOẢN CHI =====================
  Future<void> deleteExpense(String id) async {
    try {
      await supabase.from('expenses').delete().eq('id', id);

      Get.snackbar("Thành công", "Đã xóa khoản chi", snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể xóa khoản chi: $e");
    }
  }
}