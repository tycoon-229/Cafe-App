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
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      const Color(
        0xfff5f5f5,
      ),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor:
        Colors.white,
        foregroundColor:
        Colors.black,

        title: const Text(
          "Thông tin quán cafe",
          style: TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),

      body: Form(
        key: formKey,

        child: Obx(
              () => ListView(
            padding:
            const EdgeInsets
                .all(16),

            children: [
              /// HEADER CARD
              Container(
                padding:
                const EdgeInsets
                    .all(24),

                decoration:
                BoxDecoration(
                  color:
                  Colors.white,

                  borderRadius:
                  BorderRadius
                      .circular(
                    26,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors
                          .black
                          .withOpacity(
                        0.05,
                      ),
                      blurRadius:
                      12,
                      offset:
                      const Offset(
                        0,
                        5,
                      ),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    Container(
                      width: 110,
                      height: 110,

                      decoration:
                      BoxDecoration(
                        color: Colors
                            .orange
                            .withOpacity(
                          0.12,
                        ),

                        shape:
                        BoxShape
                            .circle,

                        border:
                        Border.all(
                          color:
                          Colors
                              .orange,
                          width:
                          2,
                        ),
                      ),

                      child:
                      const Icon(
                        Icons
                            .storefront_rounded,
                        size:
                        54,
                        color: Colors
                            .orange,
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    const Text(
                      "Thông tin quán cafe",
                      style:
                      TextStyle(
                        fontSize:
                        20,
                        fontWeight:
                        FontWeight
                            .bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      "Cập nhật thông tin quán của bạn",
                      style:
                      TextStyle(
                        color: Colors
                            .grey
                            .shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              /// FORM CARD
              Container(
                padding:
                const EdgeInsets
                    .all(18),

                decoration:
                BoxDecoration(
                  color:
                  Colors.white,

                  borderRadius:
                  BorderRadius
                      .circular(
                    26,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors
                          .black
                          .withOpacity(
                        0.05,
                      ),
                      blurRadius:
                      12,
                      offset:
                      const Offset(
                        0,
                        5,
                      ),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    /// TÊN QUÁN
                    _buildInput(
                      controller:
                      controller
                          .cafeNameController,

                      label:
                      "Tên quán",

                      icon:
                      Icons.store,

                      validator:
                          (v) {
                        if (v ==
                            null ||
                            v.trim()
                                .isEmpty) {
                          return "Nhập tên quán";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height:
                      16,
                    ),

                    /// ĐỊA CHỈ
                    _buildInput(
                      controller:
                      controller
                          .addressController,

                      label:
                      "Địa chỉ",

                      icon: Icons
                          .location_on_outlined,
                    ),

                    const SizedBox(
                      height:
                      16,
                    ),

                    /// PHONE
                    _buildInput(
                      controller:
                      controller
                          .phoneController,

                      label:
                      "Số điện thoại",

                      icon: Icons
                          .phone_outlined,

                      keyboardType:
                      TextInputType
                          .phone,
                    ),

                    const SizedBox(
                      height:
                      16,
                    ),

                    /// DESCRIPTION
                    _buildInput(
                      controller:
                      controller
                          .descriptionController,

                      label:
                      "Mô tả quán",

                      icon:
                      Icons
                          .description_outlined,

                      maxLines:
                      4,
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              /// BUTTON
              SizedBox(
                height: 58,

                child:
                ElevatedButton(
                  style:
                  ElevatedButton
                      .styleFrom(
                    backgroundColor:
                    Colors.orange,

                    elevation:
                    0,

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        20,
                      ),
                    ),
                  ),

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
                      ? const SizedBox(
                    width:
                    24,
                    height:
                    24,
                    child:
                    CircularProgressIndicator(
                      strokeWidth:
                      2.5,
                      color:
                      Colors
                          .white,
                    ),
                  )
                      : const Text(
                    "Lưu thay đổi",
                    style:
                    TextStyle(
                      fontSize:
                      16,
                      fontWeight:
                      FontWeight
                          .bold,
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
    required TextEditingController
    controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType?
    keyboardType,
    String? Function(String?)?
    validator,
  }) {
    return Container(
      decoration:
      BoxDecoration(
        color:
        const Color(
          0xfff9f9f9,
        ),

        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),

      child: TextFormField(
        controller:
        controller,

        validator:
        validator,

        keyboardType:
        keyboardType,

        maxLines:
        maxLines,

        decoration:
        InputDecoration(
          hintText:
          label,

          prefixIcon:
          Icon(
            icon,
            color:
            Colors.orange,
          ),

          border:
          InputBorder.none,

          contentPadding:
          const EdgeInsets.symmetric(
            horizontal:
            18,
            vertical:
            18,
          ),
        ),
      ),
    );
  }
}