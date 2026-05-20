import 'dart:io';

import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/auth.dart';
import '../pages/admin/admin_page.dart';
import '../pages/cafe/cafe_registration_page.dart';
import '../pages/auth/auth_page.dart';
import '../pages/auth/otp_verify_page.dart';
import '../pages/table_page.dart';
import '../pages/auth/user_info_page.dart';
import '../pages/auth/waiting_account_approval_page.dart';
import '../pages/cafe/waiting_cafe_approval_page.dart';

enum AppFlow {
  login,
  fillProfile,
  waitAccountApproval,
  registerCafe,
  waitCafeApproval,
  home,
}

class AuthController extends GetxController {
  static AuthController get to =>
      Get.find<AuthController>();

  final supabase =
      Supabase.instance.client;

  final isLoading =
      false.obs;

  final currentUser =
  Rxn<Auth>();

  @override
  void onInit() {
    super.onInit();

    Future.delayed(
      const Duration(
        milliseconds: 300,
      ),
      checkSession,
    );
  }

  // =======================
  // CHECK FLOW
  // =======================

  Future<AppFlow> checkFlow() async {
    final user =
        supabase.auth.currentUser;

    // chưa login
    if (user == null) {
      return AppFlow.login;
    }

    // lấy profile
    final profileData =
    await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    // chưa có profile
    if (profileData == null) {
      return AppFlow.fillProfile;
    }

    final profile =
    Auth.fromJson(
      profileData,
    );

    currentUser.value =
        profile;

    // account bị khóa
    if (!profile.isActive) {
      await logout();

      Get.snackbar(
        'Tài khoản bị khóa',
        'Vui lòng liên hệ admin',
      );

      return AppFlow.login;
    }

    // admin
    if (profile.role ==
        'admin') {
      return AppFlow.home;
    }

    // account pending
    if (profile
        .accountStatus ==
        'pending') {
      return AppFlow
          .waitAccountApproval;
    }

    // account rejected
    if (profile
        .accountStatus ==
        'rejected') {
      return AppFlow
          .waitAccountApproval;
    }

    // =======================
    // CHECK CAFE
    // =======================

    final cafe =
    await supabase
        .from('cafes')
        .select()
        .eq(
      'owner_id',
      user.id,
    )
        .maybeSingle();

    // chưa đăng ký quán
    if (cafe == null) {
      return AppFlow
          .registerCafe;
    }

    // chờ duyệt quán
    if (cafe[
    'approval_status'] ==
        'pending') {
      return AppFlow
          .waitCafeApproval;
    }

    // bị reject
    if (cafe[
    'approval_status'] ==
        'rejected') {
      return AppFlow
          .registerCafe;
    }

    return AppFlow.home;
  }

  // =======================
  // CHECK SESSION
  // =======================

  Future<void> checkSession() async {
    final flow =
    await checkFlow();

    switch (flow) {
      case AppFlow.login:
        Get.offAll(
              () => AuthPage(),
        );
        break;

      case AppFlow.fillProfile:
        Get.offAll(
              () =>
          const UserInfoPage(),
        );
        break;

      case AppFlow
          .waitAccountApproval:
        Get.offAll(
              () =>
              WaitingAccountApprovalPage(),
        );
        break;

      case AppFlow
          .registerCafe:
        Get.offAll(
              () =>
              CafeRegistrationPage(),
        );
        break;

      case AppFlow
          .waitCafeApproval:
        Get.offAll(
              () =>
              WaitingCafeApprovalPage(),
        );
        break;

      case AppFlow.home:
        if (currentUser
            .value
            ?.role ==
            'admin') {
          Get.offAll(
                () => AdminPage(),
          );
        } else {
          Get.offAll(
                () => TablePage(),
          );
        }
        break;
    }
  }

  // =======================
  // REGISTER
  // =======================

  Future<void> register({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      await supabase.auth.signUp(
        email: email.trim(),
        password: password,
        emailRedirectTo: null,
      );

      await supabase.auth
          .signOut();

      Get.snackbar(
        'OTP đã gửi',
        'Vui lòng kiểm tra email',
      );

      Get.to(
            () => OtpVerifyPage(
          email: email,
          password:
          password,
        ),
      );
    } on AuthException catch (e) {
      Get.snackbar(
        'Đăng ký thất bại',
        e.message,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
      );
    } finally {
      isLoading.value =
      false;
    }
  }

  // =======================
  // VERIFY OTP
  // =======================

  Future<void> verifyOtp({
    required String email,
    required String password,
    required String token,
  }) async {
    try {
      isLoading.value = true;

      await supabase.auth
          .verifyOTP(
        type:
        OtpType.signup,
        email: email,
        token: token,
      );

      await login(
        email: email,
        password:
        password,
      );

      Get.snackbar(
        'Thành công',
        'Xác thực OTP thành công',
      );
    } on AuthException catch (e) {
      Get.snackbar(
        'OTP không hợp lệ',
        e.message,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
      );
    } finally {
      isLoading.value =
      false;
    }
  }

  // =======================
  // LOGIN
  // =======================

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      await supabase.auth
          .signInWithPassword(
        email:
        email.trim(),
        password:
        password,
      );

      final user =
          supabase
              .auth
              .currentUser;

      if (user == null) {
        throw 'Không tìm thấy user';
      }

      // email chưa verify
      if (user
          .emailConfirmedAt ==
          null) {
        await supabase.auth
            .signOut();

        Get.snackbar(
          'Email chưa xác thực',
          'Vui lòng nhập OTP',
        );

        Get.to(
              () => OtpVerifyPage(
            email:
            email,
            password:
            password,
          ),
        );

        return;
      }

      await checkSession();
    } on AuthException catch (e) {
      Get.snackbar(
        'Đăng nhập thất bại',
        e.message,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
      );
    } finally {
      isLoading.value =
      false;
    }
  }

  // =======================
  // SAVE PROFILE
  // =======================

  Future<void> saveProfile({
    required String username,
    required String phone,
    File? avatar,
  }) async {
    try {
      isLoading.value = true;

      final user =
          supabase
              .auth
              .currentUser;

      if (user == null) {
        return;
      }

      String? avatarUrl;

      if (avatar != null) {
        avatarUrl =
        await uploadAvatar(
          avatar,
        );
      }

      final existingProfile =
      await supabase
          .from(
        'profiles',
      )
          .select()
          .eq(
        'id',
        user.id,
      )
          .maybeSingle();

      final role = existingProfile?['role'] ?? 'user';

      final body = {
        'id': user.id,
        'username':
        username.trim(),
        'email':
        user.email,
        'phone':
        phone.trim(),

        'role': role,

        'is_active': true,

        'account_status':
        role == 'admin'
            ? 'approved'
            : existingProfile?[
        'account_status'] ??
            'pending',

        'avatar_url':
        avatarUrl ??
            existingProfile?[
            'avatar_url'],
      };

      await supabase
          .from(
        'profiles',
      )
          .upsert(body);

      currentUser.value =
          Auth.fromJson(
            body,
          );

      Get.snackbar(
        'Thành công',
        'Tạo hồ sơ thành công',
      );

      await checkSession();
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
      );
    } finally {
      isLoading.value =
      false;
    }
  }

  // =======================
  // UPLOAD AVATAR
  // =======================

  Future<String?>
  uploadAvatar(
      File image,
      ) async {
    try {
      final user =
          supabase
              .auth
              .currentUser;

      if (user == null) {
        return null;
      }

      final ext =
      path.extension(
        image.path,
      );

      final fileName =
          '${user.id}${DateTime.now().millisecondsSinceEpoch}$ext';

      final filePath =
          'avatars/$fileName';

      await supabase.storage
          .from('images')
          .upload(
        filePath,
        image,
        fileOptions:
        const FileOptions(
          upsert: true,
        ),
      );

      return supabase
          .storage
          .from('images')
          .getPublicUrl(
        filePath,
      );
    } catch (e) {
      Get.snackbar(
        'Upload thất bại',
        e.toString(),
      );

      return null;
    }
  }

  // =======================
  // LOGOUT
  // =======================

  Future<void> logout() async {
    await supabase.auth.signOut();

    currentUser.value = null;

    Get.delete<AuthController>(
      force: true,
    );

    Get.offAll(
          () => AuthPage(),
    );
  }
}