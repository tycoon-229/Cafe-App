import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/temp/pages/auth_page.dart';

import '../controllers/auth_controller.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() =>
      _UserInfoPageState();
}

class _UserInfoPageState
    extends State<UserInfoPage> {
  final controller = AuthController.to;

  final usernameController =
  TextEditingController();

  final phoneController =
  TextEditingController();

  final cafeNameController =
  TextEditingController();

  final addressController =
  TextEditingController();

  final descriptionController =
  TextEditingController();

  File? selectedImage;

  @override
  void dispose() {
    usernameController.dispose();
    phoneController.dispose();
    cafeNameController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();

      final picked =
      await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (picked == null) return;

      setState(() {
        selectedImage =
            File(picked.path);
      });
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
      );
    }
  }

  Future<void> saveProfile() async {
    final username =
    usernameController.text.trim();

    final phone =
    phoneController.text.trim();

    final cafeName =
    cafeNameController.text.trim();

    final address =
    addressController.text.trim();

    final description =
    descriptionController.text.trim();

    if (username.isEmpty ||
        phone.isEmpty ||
        cafeName.isEmpty ||
        address.isEmpty) {
      Get.snackbar(
        'Thiếu thông tin',
        'Vui lòng nhập đầy đủ thông tin',
      );
      return;
    }

    await controller.saveProfile(
      username: username,
      phone: phone,
      avatar: selectedImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xfff5f7fb),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Thông tin người dùng',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Center(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.all(24),

          child: Container(
            constraints:
            const BoxConstraints(
              maxWidth: 520,
            ),

            padding:
            const EdgeInsets.all(28),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(
                24,
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.black
                      .withOpacity(.06),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Hoàn tất hồ sơ trước khi bắt đầu',
                    style: TextStyle(
                      color:
                      Colors.grey[600],
                    ),
                  ),
                ),

                const SizedBox(
                    height: 30),

                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: pickImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor:
                          Colors.grey[300],

                          backgroundImage:
                          selectedImage !=
                              null
                              ? FileImage(
                            selectedImage!,
                          )
                              : null,

                          child:
                          selectedImage ==
                              null
                              ? const Icon(
                            Icons
                                .camera_alt,
                            size: 40,
                          )
                              : null,
                        ),
                      ),

                      TextButton(
                        onPressed:
                        pickImage,
                        child:
                        const Text(
                          'Chọn ảnh đại diện',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                    height: 20),

                _buildTextField(
                  controller:
                  usernameController,
                  label:
                  'Tên người dùng',
                  icon:
                  Icons.person,
                ),

                const SizedBox(
                    height: 16),

                _buildTextField(
                  controller:
                  phoneController,
                  label:
                  'Số điện thoại',
                  icon:
                  Icons.phone,
                ),

                const SizedBox(
                    height: 28),

                SizedBox(
                  width:
                  double.infinity,
                  height: 55,
                  child: Obx(
                        () =>
                        ElevatedButton(
                          onPressed:
                          controller
                              .isLoading
                              .value
                              ? null
                              : saveProfile,
                          child: controller
                              .isLoading
                              .value
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                            CircularProgressIndicator(
                              strokeWidth:
                              2.5,
                            ),
                          )
                              : const Text(
                            'Hoàn tất',
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController
    controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            16,
          ),
        ),
      ),
    );
  }
}