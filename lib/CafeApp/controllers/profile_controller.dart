import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_controller.dart';
import '../models/auth.dart';

class ProfileController extends GetxController {
  static ProfileController get to => Get.find();

  final supabase = Supabase.instance.client;
  final authController = AuthController.to;

  final isLoading = false.obs;

  ////////////////////////////////////////////////////////

  final usernameController =
  TextEditingController();

  final phoneController =
  TextEditingController();

  final avatarFile =
  Rx<File?>(null);

  final avatarUrl =
  RxnString();

  ////////////////////////////////////////////////////////

  Auth? get currentUser =>
      authController.currentUser.value;

  ////////////////////////////////////////////////////////

  @override
  void onInit() {
    super.onInit();

    loadUser();
  }

  ////////////////////////////////////////////////////////

  void loadUser() {
    final user = currentUser;

    if (user == null) return;

    usernameController.text =
        user.username ?? '';

    phoneController.text =
        user.phone ?? '';

    avatarUrl.value =
        user.avatarUrl;
  }

  ////////////////////////////////////////////////////////

  Future<void> pickAvatar() async {
    final picker = ImagePicker();

    final picked =
    await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked == null) return;

    avatarFile.value =
        File(picked.path);
  }

  ////////////////////////////////////////////////////////

  Future<void> updateProfile() async {
    try {
      isLoading.value = true;

      final user =
          supabase.auth.currentUser;

      if (user == null) {
        Get.snackbar(
          'Lỗi',
          'Không tìm thấy user',
        );
        return;
      }

      String? newAvatar =
          avatarUrl.value;

      /////////////////////////////////////
      /// upload avatar mới
      if (avatarFile.value != null) {
        newAvatar =
        await authController
            .uploadAvatar(
          avatarFile.value!,
        );
      }

      print("USER ID: ${user.id}");

      /////////////////////////////////////
      /// update profile
      final res = await supabase
          .from('profiles')
          .update({
        'username':
        usernameController.text
            .trim(),

        'phone':
        phoneController.text
            .trim(),

        'avatar_url':
        newAvatar,
      })
          .eq('id', user.id)
          .select()
          .single();

      print("UPDATE SUCCESS: $res");

      /////////////////////////////////////
      /// update current user local
      authController
          .currentUser
          .value = Auth.fromJson(res);

      Get.back(result: true);

    } catch (e) {
      print("UPDATE ERROR: $e");

      Get.snackbar(
        'Lỗi',
        e.toString(),
        snackPosition:
        SnackPosition.BOTTOM,
        backgroundColor:
        Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  ////////////////////////////////////////////////////////

  @override
  void onClose() {
    usernameController.dispose();
    phoneController.dispose();

    super.onClose();
  }
}