import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CafeProfileController extends GetxController {
  static CafeProfileController get to => Get.find();

  final supabase = Supabase.instance.client;

  final isLoading = false.obs;

  //////////////////////////////////////////////////

  final cafeNameController = TextEditingController();

  final addressController = TextEditingController();

  final phoneController = TextEditingController();

  final descriptionController = TextEditingController();

  String? cafeId;

  //////////////////////////////////////////////////

  @override
  void onInit() {
    super.onInit();

    loadCafe();
  }

  //////////////////////////////////////////////////

  Future<void> loadCafe() async {
    try {
      final uid = supabase.auth.currentUser?.id;

      if (uid == null) return;

      final cafe = await supabase
          .from('cafes')
          .select()
          .eq('owner_id', uid)
          .single();

      cafeId = cafe['id'];

      cafeNameController.text = cafe['cafe_name'] ?? '';

      addressController.text = cafe['address'] ?? '';

      phoneController.text = cafe['phone'] ?? '';

      descriptionController.text = cafe['description'] ?? '';
    } catch (e) {
      print("LOAD CAFE ERROR: $e");
    }
  }

  //////////////////////////////////////////////////

  Future<void> updateCafe() async {
    try {
      isLoading.value = true;

      if (cafeId == null) {
        Get.snackbar('Lỗi', 'Không tìm thấy quán');
        return;
      }

      await supabase
          .from('cafes')
          .update({
            'cafe_name': cafeNameController.text.trim(),

            'address': addressController.text.trim(),

            'phone': phoneController.text.trim(),

            'description': descriptionController.text.trim().isEmpty
                ? null
                : descriptionController.text.trim(),
          })
          .eq('id', cafeId!);

      Get.back();

      Future.delayed(const Duration(milliseconds: 200), () {
        Get.snackbar('Thành công', 'Đã cập nhật thông tin quán');
      });
    } catch (e) {
      print("UPDATE CAFE ERROR: $e");

      Get.snackbar(
        'Lỗi',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  //////////////////////////////////////////////////

  @override
  void onClose() {
    cafeNameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    descriptionController.dispose();

    super.onClose();
  }
}
