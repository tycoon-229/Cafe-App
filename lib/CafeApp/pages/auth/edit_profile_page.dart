import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/profile_controller.dart';

class EditProfilePage extends StatelessWidget {
  EditProfilePage({super.key});

  final controller = Get.put(ProfileController());

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,

        title: const Text(
          "Thông tin tài khoản",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Form(
        key: formKey,

        child: Obx(
          () => ListView(
            padding: const EdgeInsets.all(16),

            children: [
              /// PROFILE HEADER
              Container(
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(26),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    /// AVATAR
                    GestureDetector(
                      onTap: controller.pickAvatar,

                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              border: Border.all(
                                color: Colors.orange,
                                width: 3,
                              ),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),

                            child: ClipOval(
                              child: controller.avatarFile.value != null
                                  ? Image.file(
                                      File(controller.avatarFile.value!.path),
                                      fit: BoxFit.cover,
                                    )
                                  : controller.avatarUrl.value != null
                                  ? Image.network(
                                      controller.avatarUrl.value!,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: Colors.orange.withOpacity(0.12),
                                      child: const Icon(
                                        Icons.person_rounded,
                                        size: 55,
                                        color: Colors.orange,
                                      ),
                                    ),
                            ),
                          ),

                          Positioned(
                            right: 4,
                            bottom: 4,
                            child: Container(
                              padding: const EdgeInsets.all(10),

                              decoration: BoxDecoration(
                                color: Colors.orange,

                                shape: BoxShape.circle,
                              ),

                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      "Ảnh đại diện",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Nhấn vào ảnh để thay đổi",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// FORM CARD
              Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(26),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    /// USERNAME
                    _buildInput(
                      controller: controller.usernameController,

                      label: "Tên người dùng",

                      icon: Icons.person_outline,

                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Nhập username";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    /// PHONE
                    _buildInput(
                      controller: controller.phoneController,

                      label: "Số điện thoại",

                      icon: Icons.phone_outlined,

                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// BUTTON
              SizedBox(
                height: 58,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,

                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          controller.updateProfile();
                        },

                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Lưu thay đổi",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xfff9f9f9),

        borderRadius: BorderRadius.circular(20),
      ),

      child: TextFormField(
        controller: controller,

        validator: validator,

        keyboardType: keyboardType,

        decoration: InputDecoration(
          hintText: label,

          prefixIcon: Icon(icon, color: Colors.orange),

          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
