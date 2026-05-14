import 'dart:async';

import 'package:get/get.dart';
import 'package:project/temp/pages/auth_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth_controller.dart';

class AdminController extends GetxController {
  static AdminController get to => Get.find();

  final supabase = Supabase.instance.client;

  // =======================
  // STATES
  // =======================

  final isLoading = false.obs;
  final searchText = ''.obs;

  final users = <Map<String, dynamic>>[].obs;
  final filteredUsers = <Map<String, dynamic>>[].obs;

  // Dashboard stats
  final totalUsers = 0.obs;
  final totalAdmins = 0.obs;
  final totalActiveUsers = 0.obs;
  final totalBlockedUsers = 0.obs;

  StreamSubscription<List<Map<String, dynamic>>>?
  _profileSubscription;

  // =======================
  // INIT
  // =======================

  @override
  void onInit() {
    super.onInit();

    listenRealtimeUsers();

    debounce(
      searchText,
          (_) => filterUsers(),
      time: const Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    _profileSubscription?.cancel();
    super.onClose();
  }

  // =======================
  // REALTIME USERS
  // =======================

  void listenRealtimeUsers() {
    try {
      isLoading.value = true;

      // tránh subscribe nhiều lần
      _profileSubscription?.cancel();

      _profileSubscription = supabase
          .from('profiles')
          .stream(primaryKey: ['id'])
          .order(
        'created_at',
        ascending: false,
      )
          .listen(
            (data) {
          users.value =
          List<Map<String, dynamic>>.from(
            data,
          );

          filterUsers();
          calculateStats();

          isLoading.value = false;
        },
        onError: (error) {
          isLoading.value = false;

          Get.snackbar(
            'Lỗi realtime',
            error.toString(),
            snackPosition:
            SnackPosition.TOP,
          );
        },
      );
    } catch (e) {
      isLoading.value = false;

      Get.snackbar(
        'Lỗi',
        e.toString(),
        snackPosition:
        SnackPosition.TOP,
      );
    }
  }

  // =======================
  // SEARCH
  // =======================

  String removeVietnameseTones(
      String str,
      ) {
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

    vietnamese.forEach(
          (nonAccent, accents) {
        for (final accent
        in accents.split('')) {
          str = str.replaceAll(
            accent,
            nonAccent,
          );
        }
      },
    );

    return str;
  }

  void filterUsers() {
    final keyword =
    removeVietnameseTones(
      searchText.value,
    );

    if (keyword.isEmpty) {
      filteredUsers.assignAll(users);
      return;
    }

    filteredUsers.assignAll(
      users.where((user) {
        final username =
        removeVietnameseTones(
          user['username'] ?? '',
        );

        return username.contains(
          keyword,
        );
      }).toList(),
    );
  }

  // =======================
  // DASHBOARD STATS
  // =======================

  void calculateStats() {
    totalUsers.value = users.length;

    totalAdmins.value = users.where(
          (user) {
        return user['role'] == 'admin';
      },
    ).length;

    totalActiveUsers.value = users.where(
          (user) {
        return user['is_active'] == true;
      },
    ).length;

    totalBlockedUsers.value = users.where(
          (user) {
        return user['is_active'] == false;
      },
    ).length;
  }

  // =======================
  // UPDATE ROLE
  // =======================

  Future<void> updateUserRole({
    required String userId,
    required String role,
  }) async {
    try {
      await supabase
          .from('profiles')
          .update({
        'role': role,
      })
          .eq('id', userId);

      Get.snackbar(
        'Thành công',
        'Đã cập nhật role',
        snackPosition:
        SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
        snackPosition:
        SnackPosition.TOP,
      );
    }
  }

  // =======================
  // BLOCK / UNBLOCK USER
  // =======================

  Future<void> toggleUserStatus({
    required String userId,
    required bool currentStatus,
  }) async {
    try {
      final newStatus = !currentStatus;

      await supabase
          .from('profiles')
          .update({
        'is_active': newStatus,
      })
          .eq('id', userId);

      Get.snackbar(
        'Thành công',
        newStatus
            ? 'Đã mở khóa tài khoản'
            : 'Đã khóa tài khoản',
        snackPosition:
        SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
        snackPosition:
        SnackPosition.TOP,
      );
    }
  }

  // =======================
  // DELETE USER
  // =======================

  Future<void> deleteUser(
      String userId,
      ) async {
    try {
      await supabase
          .from('profiles')
          .delete()
          .eq('id', userId);

      Get.snackbar(
        'Thành công',
        'Đã xóa user',
        snackPosition:
        SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
        snackPosition:
        SnackPosition.TOP,
      );
    }
  }

  // =======================
  // MANUAL REFRESH
  // =======================

  Future<void> refreshUsers() async {
    listenRealtimeUsers();
  }

  // =======================
  // LOGOUT
  // =======================

  Future<void> logout() async {
    try {
      // huỷ realtime stream admin
      await _profileSubscription?.cancel();

      // logout supabase
      await supabase.auth.signOut();

      // chuyển về auth page
      Get.offAll(() => AuthPage());
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể đăng xuất',
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}