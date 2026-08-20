import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/product_form_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/product.dart';

class ProductFormPage extends StatelessWidget {
  final Product? product;

  const ProductFormPage({super.key, this.product});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductFormController(initialProduct: product));

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          controller.isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// IMAGE PICKER
            GestureDetector(
              onTap: controller.pickImage,
              child: Container(
                height: 220,
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Obx(() {
                    if (controller.imageFile.value != null) {
                      return Image.file(
                        controller.imageFile.value!,
                        fit: BoxFit.cover,
                      );
                    }
                    if (controller.imageUrl.value != null) {
                      return Image.network(
                        controller.imageUrl.value!,
                        fit: BoxFit.cover,
                      );
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.image_outlined,
                            color: Colors.orange,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Chọn ảnh sản phẩm',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Nhấn để tải ảnh lên',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 22),

            /// NAME
            _buildInput(
              textController: controller.nameController,
              label: 'Tên sản phẩm',
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Nhập tên sản phẩm';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            /// DESCRIPTION
            _buildInput(
              textController: controller.descController,
              label: 'Mô tả sản phẩm',
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            /// CATEGORY
            Obx(() {
              final productController = ProductController.to;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedCategoryId.value.isEmpty
                        ? null
                        : controller.selectedCategoryId.value,
                    hint: const Text('Danh mục'),
                    isExpanded: true,
                    items: productController.categories
                        .where(
                          (cat) =>
                              cat['id'] != null &&
                              cat['id'].toString().isNotEmpty,
                        )
                        .map(
                          (cat) => DropdownMenuItem<String>(
                            value: cat['id'].toString(),
                            child: Text(cat['name']),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      controller.selectedCategoryId.value = value ?? '';
                    },
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            const Text(
              "Giá theo size",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildPriceCard("S", controller.sPriceController),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPriceCard("M", controller.mPriceController),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPriceCard("L", controller.lPriceController),
                ),
              ],
            ),
            const SizedBox(height: 32),

            /// BUTTON
            SizedBox(
              height: 58,
              child: Obx(
                () => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.saveProduct,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          controller.isEdit
                              ? 'Cập nhật sản phẩm'
                              : 'Thêm sản phẩm',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController textController,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: textController,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
    );
  }

  Widget _buildPriceCard(String label, TextEditingController textController) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Size $label',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              hintText: '0đ',
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}
