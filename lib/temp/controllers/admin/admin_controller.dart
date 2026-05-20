import 'dart:async';

import 'package:get/get.dart';
import 'package:project/temp/pages/auth_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminController
    extends GetxController {
  static AdminController get to =>
      Get.find();

  final supabase =
      Supabase.instance.client;

  // =======================
  // STATES
  // =======================

  final isLoading =
      false.obs;

  final searchText =
      ''.obs;

  final users =
      <Map<String, dynamic>>[]
          .obs;

  final filteredUsers =
      <Map<String, dynamic>>[]
          .obs;

  // dashboard stats
  final totalUsers = 0.obs;
  final totalAdmins = 0.obs;
  final totalActiveUsers =
      0.obs;
  final totalBlockedUsers =
      0.obs;

  final totalPendingAccounts =
      0.obs;

  final totalCafePending =
      0.obs;

  RealtimeChannel?
  _profileChannel;

  RealtimeChannel?
  _cafeChannel;

  // =======================
  // INIT
  // =======================

  @override
  void onInit() {
    super.onInit();

    loadUsers();

    listenRealtime();

    debounce(
      searchText,
          (_) => filterUsers(),
      time:
      const Duration(
        milliseconds: 300,
      ),
    );
  }

  @override
  void onClose() {
    _profileChannel
        ?.unsubscribe();

    _cafeChannel
        ?.unsubscribe();

    super.onClose();
  }

  // =======================
  // REALTIME
  // =======================

  void listenRealtime() {
    _profileChannel =
    supabase.channel(
      'profiles-changes',
    )
      ..onPostgresChanges(
        event:
        PostgresChangeEvent
            .all,
        schema: 'public',
        table:
        'profiles',
        callback: (_) {
          loadUsers();
        },
      )
      ..subscribe();

    _cafeChannel =
    supabase.channel(
      'cafes-changes',
    )
      ..onPostgresChanges(
        event:
        PostgresChangeEvent
            .all,
        schema: 'public',
        table:
        'cafes',
        callback: (_) {
          loadUsers();
        },
      )
      ..subscribe();
  }

  // =======================
  // LOAD USERS
  // =======================

  Future<void>
  loadUsers() async {
    try {
      isLoading.value =
      true;

      final response =
      await supabase
          .from(
        'profiles',
      )
          .select('''
          *,
          cafes (
            id,
            cafe_name,
            address,
            phone,
            description,
            approval_status
          )
        ''')
          .order(
        'created_at',
        ascending:
        false,
      );

      users.value =
      List<
          Map<String,
              dynamic>>.from(
        response,
      );

      filterUsers();
      calculateStats();
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
        snackPosition:
        SnackPosition.TOP,
      );
    } finally {
      isLoading.value =
      false;
    }
  }

  // =======================
  // SEARCH
  // =======================

  String removeVietnameseTones(
      String str,
      ) {
    str =
        str.toLowerCase().trim();

    const vietnamese = {
      'a':
      'àáạảãâầấậẩẫăằắặẳẵ',
      'e':
      'èéẹẻẽêềếệểễ',
      'i':
      'ìíịỉĩ',
      'o':
      'òóọỏõôồốộổỗơờớợởỡ',
      'u':
      'ùúụủũưừứựửữ',
      'y':
      'ỳýỵỷỹ',
      'd': 'đ',
    };

    vietnamese.forEach(
          (
          nonAccent,
          accents,
          ) {
        for (final accent
        in accents.split(
          '',
        )) {
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
      filteredUsers.assignAll(
        users,
      );
      return;
    }

    filteredUsers.assignAll(
      users.where((user) {
        final username =
        removeVietnameseTones(
          user['username'] ??
              '',
        );

        final email =
        removeVietnameseTones(
          user['email'] ??
              '',
        );

        final cafes =
        user['cafes'] as List?;

        final cafe =
        cafes != null &&
            cafes.isNotEmpty
            ? cafes.first
            : null;

        final cafeName =
        removeVietnameseTones(
          cafe?['cafe_name'] ?? '',
        );

        return username
            .contains(
            keyword) ||
            email.contains(
                keyword) ||
            cafeName.contains(
                keyword);
      }).toList(),
    );
  }

  // =======================
  // DASHBOARD STATS
  // =======================

  void calculateStats() {
    totalUsers.value =
        users.length;

    totalAdmins.value =
        users.where(
              (e) =>
          e['role'] ==
              'admin',
        ).length;

    totalActiveUsers
        .value = users.where(
          (e) =>
      e['is_active'] ==
          true,
    ).length;

    totalBlockedUsers
        .value = users.where(
          (e) =>
      e['is_active'] ==
          false,
    ).length;

    totalPendingAccounts
        .value = users.where(
          (e) =>
      e[
      'account_status'] ==
          'pending',
    ).length;

    totalCafePending
        .value = users.where(
          (e) {
            final cafes =
            e['cafes'] as List?;

            final cafe =
            cafes != null &&
                cafes.isNotEmpty
                ? cafes.first
                : null;

            return cafe != null &&
                cafe[
                'approval_status'] ==
                    'pending';
      },
    ).length;
  }

  // =======================
  // APPROVE ACCOUNT
  // =======================

  Future<void>
  approveAccount(
      String userId,
      ) async {
    await supabase
        .from('profiles')
        .update({
      'account_status':
      'approved',
    }).eq('id', userId);

    Get.snackbar(
      'Thành công',
      'Đã duyệt tài khoản',
    );
  }

  Future<void>
  rejectAccount(
      String userId,
      ) async {
    await supabase
        .from('profiles')
        .update({
      'account_status':
      'rejected',
    }).eq('id', userId);

    Get.snackbar(
      'Đã từ chối',
      'Tài khoản bị từ chối',
    );
  }

  // =======================
  // UPDATE ROLE
  // =======================

  Future<void>
  updateUserRole({
    required String userId,
    required String role,
  }) async {
    try {
      await supabase
          .from('profiles')
          .update({
        'role': role,
      }).eq(
        'id',
        userId,
      );

      Get.snackbar(
        'Thành công',
        'Đã cập nhật role',
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
      );
    }
  }

  // =======================
  // BLOCK USER
  // =======================

  Future<void>
  toggleUserStatus({
    required String userId,
    required bool
    currentStatus,
  }) async {
    try {
      await supabase
          .from('profiles')
          .update({
        'is_active':
        !currentStatus,
      }).eq(
        'id',
        userId,
      );

      Get.snackbar(
        'Thành công',
        !currentStatus
            ? 'Đã mở khóa'
            : 'Đã khóa',
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
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
          .from('cafes')
          .delete()
          .eq(
        'owner_id',
        userId,
      );

      await supabase
          .from('profiles')
          .delete()
          .eq(
        'id',
        userId,
      );

      Get.snackbar(
        'Thành công',
        'Đã xóa user',
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
      );
    }
  }

  // =======================
  // REFRESH
  // =======================

  Future<void>
  refreshUsers() async {
    await loadUsers();
  }

  // =======================
  // LOGOUT
  // =======================

  Future<void>
  logout() async {
    try {
      _profileChannel
          ?.unsubscribe();

      _cafeChannel
          ?.unsubscribe();

      await supabase.auth
          .signOut();

      Get.offAll(
            () => AuthPage(),
      );
    } catch (_) {
      Get.snackbar(
        'Lỗi',
        'Không thể đăng xuất',
      );
    }
  }
}