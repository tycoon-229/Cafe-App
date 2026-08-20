import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expense.dart';
import '../dialogs/expense_dialogs.dart';
import '../dialogs/confirm_dialog.dart';

class ExpenseController extends GetxController {
  final supabase = Supabase.instance.client;

  final expenses = <Expense>[].obs;
  final isLoading = false.obs;

  // Stats
  final expensesForStats = <Expense>[].obs;
  final isStatsLoading = false.obs;

  // Filter states
  final selectedMonth = DateTime.now().month.obs;
  final selectedYear = DateTime.now().year.obs;
  final selectedDate = Rxn<DateTime>();

  String? _cafeId;

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  Future<void> _initData() async {
    await fetchExpenses();
  }

  Future<String> getCafeId() async {
    if (_cafeId != null) return _cafeId!;
    final uid = supabase.auth.currentUser!.id;
    final cafe = await supabase.from('cafes').select('id').eq('owner_id', uid).single();
    _cafeId = cafe['id'].toString();
    return _cafeId!;
  }

  // =======================
  // UI ACTIONS
  // =======================

  void showAddExpenseDialog() {
    ExpenseDialogs.showExpenseForm(onSubmit: (title, amount, desc) => addExpense(title: title, amount: amount, description: desc));
  }

  void showDeleteConfirm(String id) {
    ConfirmDialog.show(
      title: "Xóa chi phí?",
      message: "Hành động này không thể hoàn tác",
      confirmText: "Xóa",
      confirmColor: Colors.red,
      onConfirm: () => deleteExpense(id),
    );
  }

  Future<void> updateMonth(int month) async {
    selectedMonth.value = month;
    selectedDate.value = null;
    await fetchExpenses();
  }

  Future<void> updateYear(int year) async {
    selectedYear.value = year;
    selectedDate.value = null;
    await fetchExpenses();
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      selectedDate.value = picked;
      await fetchExpenses();
    }
  }

  void clearDateFilter() {
    selectedDate.value = null;
    fetchExpenses();
  }

  Future<void> refreshExpenses() async => await fetchExpenses();

  // =======================
  // LOGIC
  // =======================

  Future<void> fetchExpenses() async {
    try {
      isLoading.value = true;
      final cafeId = await getCafeId();

      DateTime start, end;
      if (selectedDate.value != null) {
        start = DateTime(selectedDate.value!.year, selectedDate.value!.month, selectedDate.value!.day);
        end = start.add(const Duration(days: 1));
      } else {
        start = DateTime(selectedYear.value, selectedMonth.value, 1);
        end = selectedMonth.value == 12 ? DateTime(selectedYear.value + 1, 1, 1) : DateTime(selectedYear.value, selectedMonth.value + 1, 1);
      }

      final res = await supabase.from('expenses').select().eq('cafe_id', cafeId).gte('created_at', start.toIso8601String()).lt('created_at', end.toIso8601String()).order('created_at', ascending: false);

      expenses.value = (res as List).map((e) => Expense.fromJson(e)).toList();
    } catch (e) {
      Get.snackbar("Lỗi", "Không tải được danh sách chi phí");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchExpensesForStats({int? month, int? year, DateTime? date}) async {
    try {
      isStatsLoading.value = true;
      final cafeId = await getCafeId();
      DateTime start, end;

      if (date != null) {
        start = DateTime(date.year, date.month, date.day);
        end = start.add(const Duration(days: 1));
      } else {
        final m = month ?? selectedMonth.value;
        final y = year ?? selectedYear.value;
        start = DateTime(y, m, 1);
        end = m == 12 ? DateTime(y + 1, 1, 1) : DateTime(y, m + 1, 1);
      }

      final res = await supabase.from('expenses').select().eq('cafe_id', cafeId).gte('created_at', start.toIso8601String()).lt('created_at', end.toIso8601String());

      expensesForStats.value = (res as List).map((e) => Expense.fromJson(e)).toList();
    } catch (e) {
      print("Error fetchExpensesForStats: $e");
    } finally {
      isStatsLoading.value = false;
    }
  }

  Future<void> addExpense({required String title, required double amount, String? description}) async {
    try {
      final cafeId = await getCafeId();
      await supabase.from('expenses').insert({
        'title': title,
        'amount': amount,
        'description': description,
        'cafe_id': cafeId,
      });
      await fetchExpenses();
      Get.snackbar("Thành công", "Đã lưu chi phí");
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể lưu chi phí");
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await supabase.from('expenses').delete().eq('id', id);
      await fetchExpenses();
      Get.snackbar("Thành công", "Đã xóa chi phí");
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể xóa chi phí");
    }
  }

  double get totalExpense => expensesForStats.fold(0, (sum, e) => sum + e.amount);
}
