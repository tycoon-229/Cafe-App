import 'dart:io';

import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:project/temp/pages/table_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/auth.dart';
import '../pages/admin/admin_page.dart';
import '../pages/auth_page.dart';
import '../pages/otp_verify_page.dart';
import '../pages/user_info_page.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find<AuthController>();

  final supabase = Supabase.instance.client;

  final isLoading = false.obs;
  final currentUser = Rxn<AuthModel>();

  String? registerEmail;
  String? registerPassword;

  @override
  void onInit() {
    super.onInit();

    Future.delayed(
      const Duration(milliseconds: 300),
      checkSession,
    );
  }

  // =======================
  // CHECK SESSION
  // =======================

  Future<void> checkSession() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      Get.offAll(() => AuthPage());
      return;
    }

    await loadUserProfile();
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

      final response =
      await supabase.auth.signUp(
        email: email.trim(),
        password: password,
        emailRedirectTo: null,
      );

      // logout ngay nếu supabase tạo session
      await supabase.auth.signOut();

      Get.snackbar(
        'OTP đã gửi',
        'Vui lòng kiểm tra email',
      );

      Get.to(
            () => OtpVerifyPage(
          email: email,
          password: password,
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
      isLoading.value = false;
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

      await supabase.auth.verifyOTP(
        type: OtpType.signup,
        email: email,
        token: token,
      );

      // login sau verify
      await login(
        email: email,
        password: password,
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
      isLoading.value = false;
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

      await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user =
          supabase.auth.currentUser;

      if (user == null) {
        throw 'Không tìm thấy user';
      }

      // chưa verify email
      if (user.emailConfirmedAt ==
          null) {
        await supabase.auth.signOut();

        Get.snackbar(
          'Email chưa xác thực',
          'Vui lòng nhập OTP xác thực email',
        );

        Get.to(
              () => OtpVerifyPage(
            email: email,
            password: password,
          ),
        );

        return;
      }

      await loadUserProfile();

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
      isLoading.value = false;
    }
  }

  // =======================
  // LOAD PROFILE
  // =======================

  Future<void> loadUserProfile() async {
    try {
      final user =
          supabase.auth.currentUser;

      if (user == null) {
        Get.offAll(
              () => const AuthPage(),
        );
        return;
      }

      Map<String, dynamic>? data;

      // retry 3 lần
      for (int i = 0; i < 3; i++) {
        data = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (data != null) break;

        await Future.delayed(
          const Duration(
            milliseconds: 500,
          ),
        );
      }

      // chưa có profile thật
      if (data == null) {
        Get.offAll(
              () => const UserInfoPage(),
        );
        return;
      }

      final profile =
      AuthModel.fromJson(data);

      currentUser.value =
          profile;

      // account blocked
      if (!profile.isActive) {
        await logout();

        Get.snackbar(
          'Tài khoản bị khóa',
          'Vui lòng liên hệ admin',
        );

        return;
      }

      // redirect theo role
      if (profile.role ==
          'admin') {
        Get.offAll(
              () => AdminPage(),
        );
      } else {
        Get.offAll(
              () => TablePage(),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi profile',
        e.toString(),
      );
    }
  }

  // =======================
  // SAVE PROFILE
  // =======================

  Future<void> saveProfile({
    required String username,
    required String phone,
    required String cafeName,
    required String address,
    required String description,
    File? avatar,
  }) async {
    try {
      isLoading.value = true;

      final user = supabase.auth.currentUser;

      if (user == null) return;

      String? avatarUrl;

      // upload avatar
      if (avatar != null) {
        avatarUrl = await uploadAvatar(
          avatar,
        );
      }

      // check existing profile
      final existingProfile =
      await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      final role =
          currentUser.value?.role ??
              existingProfile?['role'] ??
              'user';

      final body = {
        'id': user.id,
        'username': username.trim(),
        'email': user.email,
        'phone': phone.trim(),
        'cafe_name': cafeName.trim(),
        'address': address.trim(),
        'description':
        description.trim(),
        'role': role,
        'is_active': true,

        // nếu không upload ảnh mới
        // giữ ảnh cũ
        'avatar_url':
        avatarUrl ??
            existingProfile?[
            'avatar_url'],
      };

      await supabase
          .from('profiles')
          .upsert(body);

      currentUser.value =
          AuthModel.fromJson(body);

      Get.snackbar(
        'Thành công',
        'Tạo hồ sơ thành công',
      );

      // điều hướng theo role
      if (role == 'admin') {
        Get.offAll(
              () => AdminPage(),
        );
      } else {
        Get.offAll(
              () => TablePage(),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =======================
  // UPLOAD AVATAR
  // =======================

  Future<String?> uploadAvatar(
      File image,
      ) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) return null;

      final fileExt =
      path.extension(image.path);

      final fileName =
          '${user.id}${DateTime.now().millisecondsSinceEpoch}$fileExt';

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

      final imageUrl = supabase
          .storage
          .from('images')
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      Get.snackbar(
        'Upload thất bại',
        e.toString(),
      );

      return null;
    }
  }

  Future<void> checkUserProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) return;

    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) {
      Get.offAll(() => UserInfoPage());
      return;
    }

    final role = data['role'];

    if (role == 'admin') {
      Get.offAll(() => AdminPage());
    } else {
      Get.offAll(() => TablePage());
    }
  }

  // =======================
  // LOGOUT
  // =======================

  Future<void> logout() async {
    await supabase.auth.signOut();

    currentUser.value = null;

    Get.offAll(() => AuthPage());
  }
}