import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/cafe_profile_controller.dart';

class EditCafePage extends StatelessWidget {
  EditCafePage({super.key});

  final controller = Get.put(CafeProfileController());
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Cập nhật thông tin quán",
          style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: Form(
        key: formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.storefront_outlined,
                      size: 38,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "Chỉnh sửa thông tin",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Cập nhật các thay đổi mới nhất về quán cafe của bạn",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 36),

                // TÊN QUÁN
                _buildInput(
                  controller: controller.cafeNameController,
                  label: "Tên quán",
                  icon: Icons.store_outlined,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return "Vui lòng nhập tên quán";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ĐỊA CHỈ
                _buildInput(
                  controller: controller.addressController,
                  label: "Địa chỉ",
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 16),

                // SỐ ĐIỆN THOẠI
                _buildInput(
                  controller: controller.phoneController,
                  label: "Số điện thoại liên hệ",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // MÔ TẢ
                _buildInput(
                  controller: controller.descriptionController,
                  label: "Mô tả quán",
                  icon: Icons.description_outlined,
                  maxLines: 4,
                ),
                const SizedBox(height: 32),

                // SUBMIT BUTTON
                SizedBox(
                  height: 52,
                  child: Obx(
                        () => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                        if (!formKey.currentState!.validate()) return;
                        controller.updateCafe();
                      },
                      child: controller.isLoading.value
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        "Lưu thay đổi",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xfffafafa),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe5e5e5)),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.black54, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}