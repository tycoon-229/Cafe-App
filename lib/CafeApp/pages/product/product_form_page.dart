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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(
          controller.isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        shape: const Border(
          bottom: BorderSide(color: Color(0xffe5e5e5), width: 1),
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          children: [
            /// IMAGE PICKER
            GestureDetector(
              onTap: controller.pickImage,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xfffafafa),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xffe5e5e5)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
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
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black12, width: 1.5),
                            color: Colors.white,
                          ),
                          child: const Icon(
                            Icons.add_a_photo_outlined,
                            color: Colors.black54,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Chọn ảnh sản phẩm',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Chạm để tải ảnh từ thư viện',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 20),

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
            const SizedBox(height: 14),

            /// DESCRIPTION
            _buildInput(
              textController: controller.descController,
              label: 'Mô tả sản phẩm',
              maxLines: 3,
            ),
            const SizedBox(height: 14),

            /// CATEGORY DROPDOWN
            Obx(() {
              final productController = ProductController.to;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xfffafafa),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffe5e5e5)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedCategoryId.value.isEmpty
                        ? null
                        : controller.selectedCategoryId.value,
                    hint: Text(
                      'Chọn danh mục',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    ),
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54),
                    items: productController.categories
                        .where(
                          (cat) =>
                      cat['id'] != null &&
                          cat['id'].toString().isNotEmpty,
                    )
                        .map(
                          (cat) => DropdownMenuItem<String>(
                        value: cat['id'].toString(),
                        child: Text(
                          cat['name'],
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
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
            const SizedBox(height: 28),

            const Text(
              "Giá theo kích cỡ (VNĐ)",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildPriceCard("S", controller.sPriceController),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildPriceCard("M", controller.mPriceController),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildPriceCard("L", controller.lPriceController),
                ),
              ],
            ),
            const SizedBox(height: 32),

            /// BUTTON
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
                      : controller.saveProduct,
                  child: controller.isLoading.value
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    controller.isEdit
                        ? 'Cập nhật sản phẩm'
                        : 'Thêm sản phẩm',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
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
        color: const Color(0xfffafafa),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe5e5e5)),
      ),
      child: TextFormField(
        controller: textController,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPriceCard(String label, TextEditingController textController) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xfffafafa),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe5e5e5)),
      ),
      child: Column(
        children: [
          Text(
            'Size $label',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: '0đ',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}