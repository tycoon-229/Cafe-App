import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/profile_controller.dart';

class EditProfilePage
    extends StatelessWidget {
  EditProfilePage({super.key});

  final controller =
  Get.put(ProfileController());

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      Colors.grey[100],

      appBar: AppBar(
        title: const Text(
          "Thông tin tài khoản",
        ),
      ),

      body: Form(
        key: formKey,

        child: Obx(
              () => ListView(
            padding:
            const EdgeInsets.all(
              20,
            ),

            children: [
              /////////////////////////////////////
              /// AVATAR
              Center(
                child: GestureDetector(
                  onTap:
                  controller.pickAvatar,

                  child: CircleAvatar(
                    radius: 55,

                    backgroundColor:
                    Colors.grey[300],

                    backgroundImage:
                    controller
                        .avatarFile
                        .value !=
                        null
                        ? FileImage(
                      controller
                          .avatarFile
                          .value!,
                    )
                        : controller
                        .avatarUrl
                        .value !=
                        null
                        ? NetworkImage(
                      controller
                          .avatarUrl
                          .value!,
                    )
                        : null,

                    child: controller
                        .avatarFile
                        .value ==
                        null &&
                        controller
                            .avatarUrl
                            .value ==
                            null
                        ? const Icon(
                      Icons.person,
                      size: 40,
                    )
                        : null,
                  ),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              const Center(
                child: Text(
                  "Nhấn để đổi ảnh",
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              /////////////////////////////////////
              /// USERNAME
              TextFormField(
                controller: controller
                    .usernameController,

                validator: (v) {
                  if (v == null ||
                      v.trim().isEmpty) {
                    return "Nhập username";
                  }

                  return null;
                },

                decoration:
                const InputDecoration(
                  labelText:
                  "Tên người dùng",

                  filled: true,
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              /////////////////////////////////////
              /// PHONE
              TextFormField(
                controller: controller
                    .phoneController,

                keyboardType:
                TextInputType.phone,

                decoration:
                const InputDecoration(
                  labelText:
                  "Số điện thoại",

                  filled: true,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              /////////////////////////////////////
              /// BUTTON
              SizedBox(
                height: 55,

                child:
                ElevatedButton(
                  onPressed: controller
                      .isLoading
                      .value
                      ? null
                      : () {
                    if (!formKey
                        .currentState!
                        .validate()) {
                      return;
                    }

                    controller
                        .updateProfile();
                  },

                  child: controller
                      .isLoading
                      .value
                      ? const CircularProgressIndicator()
                      : const Text(
                    "Lưu thay đổi",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}