import 'dart:async';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_controller.dart';

class AdminController extends GetxController {
  static AdminController get to => Get.find();

  final supabase = Supabase.instance.client;

  // =======================
  // STATES CHO USER
  // =======================
  final isLoading = false.obs;
  final searchText = ''.obs;
  final users = <Map<String, dynamic>>[].obs;
  final filteredUsers = <Map<String, dynamic>>[].obs;

  // =======================
  // STATES CHO CAFE (MỚI THÊM)
  // =======================
  final isCafeLoading = false.obs;
  final searchCafeText = ''.obs;
  final cafes = <Map<String, dynamic>>[].obs;

  List<Map<String, dynamic>> get filteredCafes {
    if (searchCafeText.value.isEmpty) return cafes;
    return cafes.where((c) {
      final name = (c['cafe_name'] ?? '').toString().toLowerCase();
      final phone = (c['phone'] ?? '').toString().toLowerCase();
      return name.contains(searchCafeText.value.toLowerCase()) ||
          phone.contains(searchCafeText.value.toLowerCase());
    }).toList();
  }

  // dashboard stats
  final totalUsers = 0.obs;
  final totalAdmins = 0.obs;
  final totalActiveUsers = 0.obs;
  final totalBlockedUsers = 0.obs;
  final totalPendingAccounts = 0.obs;
  final totalCafePending = 0.obs;

  RealtimeChannel? _profileChannel;
  RealtimeChannel? _cafeChannel;

  // =======================
  // INIT
  // =======================

  @override
  void onInit() {
    super.onInit();

    loadUsers();
    refreshCafes(); // Tải danh sách quán cafe khi khởi tạo
    listenRealtime();

    debounce(
      searchText,
          (_) => filterUsers(),
      time: const Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    _profileChannel?.unsubscribe();
    _cafeChannel?.unsubscribe();
    super.onClose();
  }

  // =======================
  // REALTIME
  // =======================

  void listenRealtime() {
    _profileChannel = supabase.channel('admin-profiles-changes')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'profiles',
        callback: (_) {
          loadUsers();
          refreshCafes(); // Profile đổi có thể ảnh hưởng tới tên chủ quán
        },
      )
      ..subscribe();

    _cafeChannel = supabase.channel('admin-cafes-changes')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'cafes',
        callback: (_) {
          loadUsers(); // Cập nhật lại list users vì có join với cafes
          refreshCafes(); // Cập nhật lại list cafes
        },
      )
      ..subscribe();
  }

  // =======================
  // LOAD USERS
  // =======================

  Future<void> loadUsers() async {
    try {
      isLoading.value = true;

      final response = await supabase.from('profiles').select('''
          *,
          cafes (
            id,
            cafe_name,
            address,
            phone,
            description,
            approval_status
          )
        ''').order('created_at', ascending: false);

      users.value = List<Map<String, dynamic>>.from(response);

      filterUsers();
      calculateStats();
    } catch (e) {
      Get.snackbar('Lỗi', e.toString(), snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }

  // =======================
  // LOAD CAFES (MỚI THÊM)
  // =======================

  Future<void> refreshCafes() async {
    try {
      isCafeLoading.value = true;
      final response = await supabase
          .from('cafes')
          .select('*, profiles (username, email, phone)')
          .order('created_at', ascending: false);

      cafes.value = List<Map<String, dynamic>>.from(response);
      calculateStats(); // Cập nhật lại đếm badge
    } catch (e) {
      Get.snackbar('Lỗi', 'Không tải được danh sách quán');
    } finally {
      isCafeLoading.value = false;
    }
  }

  // =======================
  // SEARCH USERS
  // =======================

  String removeVietnameseTones(String str) {
    str = str.toLowerCase().trim();

    const vietnamese = {
      'a': 'àáạảãâầấậẩẫăằắặẳẵ',
      'e': 'èéẹẻẽêềếệểễ',
      'i': 'ìíịỉĩ',
      'o': 'òóọỏõôồốộổỗơờớợởỡ',
      'u': 'ùúụủũưừứựửữ',
      'y': 'ỳýỵỷỹ',
      'd': 'đ',
    };

    vietnamese.forEach((nonAccent, accents) {
      for (final accent in accents.split('')) {
        str = str.replaceAll(accent, nonAccent);
      }
    });

    return str;
  }

  void filterUsers() {
    final keyword = removeVietnameseTones(searchText.value);

    if (keyword.isEmpty) {
      filteredUsers.assignAll(users);
      return;
    }

    filteredUsers.assignAll(
      users.where((user) {
        final username = removeVietnameseTones(user['username'] ?? '');
        final email = removeVietnameseTones(user['email'] ?? '');
        final userCafes = user['cafes'] as List?;
        final cafe = userCafes != null && userCafes.isNotEmpty ? userCafes.first : null;
        final cafeName = removeVietnameseTones(cafe?['cafe_name'] ?? '');

        return username.contains(keyword) ||
            email.contains(keyword) ||
            cafeName.contains(keyword);
      }).toList(),
    );
  }

  // =======================
  // DASHBOARD STATS
  // =======================

  void calculateStats() {
    totalUsers.value = users.length;
    totalAdmins.value = users.where((e) => e['role'] == 'admin').length;
    totalActiveUsers.value = users.where((e) => e['is_active'] == true).length;
    totalBlockedUsers.value = users.where((e) => e['is_active'] == false).length;
    totalPendingAccounts.value = users.where((e) => e['account_status'] == 'pending').length;

    // Cập nhật cách tính tổng số quán chờ duyệt dựa trực tiếp vào mảng cafes
    totalCafePending.value = cafes.where((e) => e['approval_status'] == 'pending').length;
  }

  // =======================
  // APPROVE / REJECT ACCOUNT
  // =======================

  Future<void> approveAccount(String userId) async {
    try {
      await supabase.from('profiles').update({'account_status': 'approved'}).eq('id', userId);
      await loadUsers();
      Get.snackbar('Thành công', 'Đã duyệt tài khoản');
    } catch (e) {
      Get.snackbar('Lỗi', e.toString());
    }
  }

  Future<void> rejectAccount(String userId) async {
    try {
      await supabase.from('profiles').update({'account_status': 'rejected'}).eq('id', userId);
      await loadUsers();
      Get.snackbar('Đã từ chối', 'Tài khoản bị từ chối');
    } catch (e) {
      Get.snackbar('Lỗi', e.toString());
    }
  }

  // =======================
  // APPROVE / REJECT CAFE
  // =======================

  Future<void> approveCafe(String cafeId) async {
    try {
      await supabase.from('cafes').update({'approval_status': 'approved'}).eq('id', cafeId);
      await refreshCafes();
      Get.snackbar('Thành công', 'Đã duyệt quán');
    } catch (e) {
      Get.snackbar('Lỗi', e.toString());
    }
  }

  Future<void> rejectCafe(String cafeId) async {
    try {
      await supabase.from('cafes').update({'approval_status': 'rejected'}).eq('id', cafeId);
      await refreshCafes();
      Get.snackbar('Đã từ chối', 'Quán đã bị từ chối');
    } catch (e) {
      Get.snackbar('Lỗi', e.toString());
    }
  }

  // =======================
  // UPDATE ROLE
  // =======================

  Future<void> updateUserRole({required String userId, required String role}) async {
    try {
      await supabase.from('profiles').update({'role': role}).eq('id', userId);
      Get.snackbar('Thành công', 'Đã cập nhật role');
    } catch (e) {
      Get.snackbar('Lỗi', e.toString());
    }
  }

  // =======================
  // BLOCK / UNBLOCK USER
  // =======================

  Future<void> toggleUserStatus({required String userId, required bool currentStatus}) async {
    try {
      await supabase.from('profiles').update({'is_active': !currentStatus}).eq('id', userId);
      Get.snackbar('Thành công', !currentStatus ? 'Đã mở khóa' : 'Đã khóa');
    } catch (e) {
      Get.snackbar('Lỗi', e.toString());
    }
  }

  // =======================
  // DELETE USER & CAFE
  // =======================

  Future<void> deleteUser(String userId) async {
    try {
      await supabase.from('cafes').delete().eq('owner_id', userId);
      await supabase.from('profiles').delete().eq('id', userId);
      Get.snackbar('Thành công', 'Đã xóa user');
    } catch (e) {
      Get.snackbar('Lỗi', e.toString());
    }
  }

  Future<void> deleteCafe(String cafeId) async {
    try {
      await supabase.from('cafes').delete().eq('id', cafeId);
      await refreshCafes();
      Get.snackbar('Thành công', 'Đã xóa quán cafe');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa quán vì còn dữ liệu liên quan');
    }
  }

  // =======================
  // REFRESH USERS
  // =======================

  Future<void> refreshUsers() async {
    await loadUsers();
    await refreshCafes();
  }

  // =======================
  // LOGOUT
  // =======================

  Future<void> logout() async => await AuthController.to.logout();
}