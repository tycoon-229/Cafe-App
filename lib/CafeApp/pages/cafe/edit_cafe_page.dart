import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/cafe_profile_controller.dart';

class EditCafePage
    extends StatelessWidget {
  EditCafePage({super.key});

  final controller =
  Get.put(
    CafeProfileController(),
  );

  final formKey =
  GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      Colors.grey[100],

      appBar: AppBar(
        title: const Text(
          "Thông tin quán cafe",
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
              /// ICON QUÁN CAFE
              Center(
                child: Container(
                  width: 110,
                  height: 110,

                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.orange,
                      width: 2,
                    ),
                  ),

                  child: const Icon(
                    Icons.storefront,
                    size: 55,
                    color: Colors.deepOrange,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Center(
                child: Text(
                  "Thông tin quán cafe",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /////////////////////////////////////
              /// TÊN QUÁN
              TextFormField(
                controller: controller
                    .cafeNameController,

                validator: (v) {
                  if (v == null ||
                      v.trim().isEmpty) {
                    return "Nhập tên quán";
                  }

                  return null;
                },

                decoration:
                const InputDecoration(
                  labelText:
                  "Tên quán",
                  filled: true,
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              /////////////////////////////////////
              /// ĐỊA CHỈ
              TextFormField(
                controller: controller
                    .addressController,

                decoration:
                const InputDecoration(
                  labelText:
                  "Địa chỉ",
                  filled: true,
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              /////////////////////////////////////
              /// SỐ ĐIỆN THOẠI
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
                height: 16,
              ),

              /////////////////////////////////////
              /// MÔ TẢ
              TextFormField(
                controller: controller
                    .descriptionController,

                maxLines: 4,

                decoration:
                const InputDecoration(
                  labelText:
                  "Mô tả quán",
                  hintText:
                  "Nhập mô tả (không bắt buộc)",
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
                  onPressed:
                  controller
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
                        .updateCafe();
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