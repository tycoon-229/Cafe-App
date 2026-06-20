import 'dart:io';

import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../models/auth.dart';

import '../pages/admin/admin_page.dart';
import '../pages/auth/auth_page.dart';
import '../pages/auth/otp_verify_page.dart';
import '../pages/auth/user_info_page.dart';
import '../pages/auth/waiting_account_approval_page.dart';
import '../pages/cafe/cafe_registration_page.dart';
import '../pages/cafe/waiting_cafe_approval_page.dart';
import '../pages/table_page.dart';

import 'admin_controller.dart';
import 'expense_controller.dart';
import 'order_controller.dart';
import 'product_controller.dart';
import 'table_controller.dart';

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

  final isLoading = false.obs;

  final currentUser =
  Rxn<Auth>();

  final currentCafe =
  Rxn<Map<String, dynamic>>();

  final selectedAvatar =
  Rxn<File>();

  @override
  void onInit() {
    super.onInit();

    Future.delayed(
      const Duration(milliseconds: 300),
      checkSession,
    );
  }

  // ===================================================
  // FEATURE CONTROLLERS
  // ===================================================

  void _initFeatureControllers(
      String role) {
    if (role == 'admin') {
      if (!Get.isRegistered<
          AdminController>()) {
        Get.put(
          AdminController(),
          permanent: true,
        );
      }

      return;
    }

    if (!Get.isRegistered<
        OrderController>()) {
      Get.put(
        OrderController(),
        permanent: true,
      );
    }

    if (!Get.isRegistered<
        ProductController>()) {
      Get.put(
        ProductController(),
        permanent: true,
      );
    }

    if (!Get.isRegistered<
        TableController>()) {
      Get.put(
        TableController(),
        permanent: true,
      );
    }

    if (!Get.isRegistered<ExpenseController>()) {
      Get.put(
        ExpenseController(),
        permanent: true,
      );
    }
  }

  void _disposeFeatureControllers() {
    if (Get.isRegistered<
        TableController>()) {
      Get.delete<TableController>(
        force: true,
      );
    }

    if (Get.isRegistered<
        OrderController>()) {
      Get.delete<OrderController>(
        force: true,
      );
    }

    if (Get.isRegistered<
        ProductController>()) {
      Get.delete<ProductController>(
        force: true,
      );
    }

    if (Get.isRegistered<
        AdminController>()) {
      Get.delete<AdminController>(
        force: true,
      );
    }

    if (Get.isRegistered<ExpenseController>()) {
      Get.delete<ExpenseController>(
        force: true,
      );
    }
  }

  // ===================================================
  // CHECK FLOW
  // ===================================================

  Future<AppFlow> checkFlow() async {
    try {
      final user =
          supabase.auth.currentUser;

      if (user == null) {
        return AppFlow.login;
      }

      final profileData =
      await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profileData == null) {
        return AppFlow.fillProfile;
      }

      final profile =
      Auth.fromJson(profileData);

      currentUser.value =
          profile;

      if (!profile.isActive) {
        await logout(
          showSnackbar: false,
        );

        Get.snackbar(
          'Tài khoản bị khóa',
          'Vui lòng liên hệ admin',
        );

        return AppFlow.login;
      }

      if (profile.role ==
          'admin') {
        return AppFlow.home;
      }

      if (profile
          .accountStatus ==
          'pending') {
        return AppFlow
            .waitAccountApproval;
      }

      if (profile
          .accountStatus ==
          'rejected') {
        return AppFlow
            .waitAccountApproval;
      }

      final cafe = await supabase
          .from('cafes')
          .select()
          .eq(
        'owner_id',
        user.id,
      )
          .maybeSingle();

      currentCafe.value =
          cafe;

      if (cafe == null) {
        return AppFlow
            .registerCafe;
      }

      if (cafe[
      'approval_status'] ==
          'pending') {
        return AppFlow
            .waitCafeApproval;
      }

      if (cafe[
      'approval_status'] ==
          'rejected') {
        return AppFlow
            .registerCafe;
      }

      return AppFlow.home;
    } catch (_) {
      return AppFlow.login;
    }
  }

  // ===================================================
  // CHECK SESSION
  // ===================================================

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

      case AppFlow.registerCafe:
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
        final role =
            currentUser
                .value
                ?.role ??
                'user';

        _initFeatureControllers(
          role,
        );

        if (role ==
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

  // LOGIN
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      await supabase.auth
          .signInWithPassword(
        email: email.trim(),
        password:
        password.trim(),
      );

      await checkSession();
    } on AuthException catch (e) {
      Get.snackbar(
        'Đăng nhập thất bại',
        e.message,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // REGISTER
  Future<void> register({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      await supabase.auth.signUp(
        email: email.trim(),
        password:
        password.trim(),
      );

      Get.to(
            () => OtpVerifyPage(
          email: email.trim(),
          password:
          password.trim(),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // VERIFY OTP Cho đăng kí
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
        email: email.trim(),
        token: token.trim(),
      );

      await Future.delayed(
        const Duration(
          milliseconds: 500,
        ),
      );

      await checkSession();
    } finally {
      isLoading.value = false;
    }
  }

  // Thay đổi mật khẩu
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      isLoading.value = true;

      final user = supabase.auth.currentUser;

      if (user == null) {
        Get.snackbar(
          'Lỗi',
          'Người dùng chưa đăng nhập',
        );
        return;
      }

      /// Xác thực lại mật khẩu cũ
      await supabase.auth.signInWithPassword(
        email: user.email!,
        password: currentPassword,
      );

      /// Cập nhật mật khẩu mới
      await supabase.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );

      Get.snackbar(
        'Thành công',
        'Đổi mật khẩu thành công',
      );

    } on AuthException catch (e) {
      Get.snackbar(
        'Lỗi',
        e.message,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Cho quên mật khẩu
  Future<void> sendResetPasswordOtp(
      String email,
      ) async {
    try {
      isLoading.value = true;

      await supabase.auth.signInWithOtp(
        email: email.trim(),
        shouldCreateUser: false,
      );

      Get.snackbar(
        'Thành công',
        'Mã OTP đã được gửi tới email',
      );
    } on AuthException catch (e) {
      Get.snackbar(
        'Lỗi',
        e.message,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyResetPasswordOtp({
    required String email,
    required String otp,
  }) async {
    try {
      isLoading.value = true;

      await supabase.auth.verifyOTP(
        email: email.trim(),
        token: otp.trim(),
        type: OtpType.email,
      );

      return true;
    } on AuthException catch (e) {
      Get.snackbar(
        'Lỗi',
        e.message,
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(
      String newPassword,
      ) async {
    try {
      isLoading.value = true;

      await supabase.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );

      Get.snackbar(
        'Thành công',
        'Đặt lại mật khẩu thành công',
      );

    } on AuthException catch (e) {
      Get.snackbar(
        'Lỗi',
        e.message,
      );
    } finally {
      isLoading.value = false;
    }
  }

  ////////////////////////////////////////////////////////////////

  Future<String?> uploadAvatar(
      File image) async {
    try {
      final user =
          supabase.auth.currentUser;

      if (user == null) {
        return null;
      }

      final ext =
      path.extension(
          image.path);

      final fileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}$ext';

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

      return supabase.storage
          .from('images')
          .getPublicUrl(
          filePath);
    } catch (_) {
      return null;
    }
  }

  Future<void>
  pickAvatar() async {
    try {
      final picker =
      ImagePicker();

      final picked =
      await picker.pickImage(
        source:
        ImageSource.gallery,
        imageQuality: 70,
      );

      if (picked == null) {
        return;
      }

      selectedAvatar.value =
          File(picked.path);
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
      );
    }
  }

  // ===================================================
  // SAVE PROFILE
  // ===================================================
  Future<void> saveProfile(
    { required String username, required String phone, File? avatar, }
  )
  async {
    try {
      isLoading.value = true;

      final user = supabase.auth.currentUser;

      if (user == null) return;

      String? avatarUrl;

      final image =
          avatar ??
              selectedAvatar.value;

      if (image != null) {
        avatarUrl =
        await uploadAvatar(
          image,
        );
      } final existingProfile = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      final role = existingProfile?['role'] ?? 'user';
      final body = {
        'id': user.id,
        'username': username.trim(),
        'email': user.email,
        'phone': phone.trim(),
        'role': role,
        'is_active': true,
        'account_status': role == 'admin' ? 'approved' : existingProfile?[ 'account_status'] ?? 'pending',
        'avatar_url': avatarUrl ?? existingProfile?[ 'avatar_url'], };
      await supabase
          .from('profiles')
          .upsert(body); currentUser.value = Auth.fromJson(body);

          Get.snackbar( 'Thành công', 'Tạo hồ sơ thành công', );

          selectedAvatar.value = null;

          await checkSession();
    } catch (e) {
      Get.snackbar( 'Lỗi', e.toString(), );
    } finally { isLoading.value = false; }
  }

  Future<void> logout({
    bool showSnackbar =
    false,
  }) async {
    await supabase
        .removeAllChannels();

    await supabase.auth
        .signOut();

    currentUser.value = null;

    currentCafe.value = null;

    _disposeFeatureControllers();

    Get.offAll(
          () => AuthPage(),
    );
  }
}