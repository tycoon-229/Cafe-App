import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/product_controller.dart';
import '../../models/product.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final controller = ProductController.to;

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descController = TextEditingController();
  final sPriceController = TextEditingController();
  final mPriceController = TextEditingController();
  final lPriceController = TextEditingController();

  String selectedCategoryId = '';
  File? imageFile;
  String? imageUrl;
  bool isLoading = false;

  bool get isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      final p = widget.product!;
      nameController.text = p.name;
      descController.text = p.description ?? '';
      selectedCategoryId = p.categoryId ?? '';
      imageUrl = p.imageUrl;
      _loadSizes();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    sPriceController.dispose();
    mPriceController.dispose();
    lPriceController.dispose();
    super.dispose();
  }

  // =======================
  // LOAD SIZES (khi edit)
  // =======================

  Future<void> _loadSizes() async {
    final sizes = await controller.getSizes(widget.product!.id);

    for (var s in sizes) {
      if (s.name == 'S') sPriceController.text = s.price.toString();
      if (s.name == 'M') mPriceController.text = s.price.toString();
      if (s.name == 'L') lPriceController.text = s.price.toString();
    }

    setState(() {});
  }

  // =======================
  // PICK IMAGE
  // =======================

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  // =======================
  // SAVE
  // =======================

  Future<void> _saveProduct() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final sizes = _buildSizeList();

      if (isEdit) {
        final updated = Product(
          id: widget.product!.id,
          name: nameController.text.trim(),
          description: descController.text.trim(),
          imageUrl: imageUrl,
          categoryId: selectedCategoryId.isEmpty ? null : selectedCategoryId,
          cafeId: widget.product!.cafeId,
          isAvailable: widget.product!.isAvailable,
          createdAt: widget.product!.createdAt,
        );

        await controller.updateProduct(product: updated, image: imageFile);

        // Cập nhật sizes
        await controller.updateProductSizes(
          productId: updated.id,
          sizes: sizes,
        );
      } else {
        final newProduct = Product(
          id: '',
          name: nameController.text.trim(),
          description: descController.text.trim(),
          imageUrl: null,
          categoryId: selectedCategoryId.isEmpty ? null : selectedCategoryId,
        );

        final productId = await controller.addProductAndGetId(
          product: newProduct,
          image: imageFile,
          sizes: sizes,
        );

        if (productId == null) return;
      }

      Get.back();

      Get.snackbar(
        'Thành công',
        isEdit ? 'Đã cập nhật sản phẩm' : 'Đã thêm sản phẩm',
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // =======================
  // BUILD SIZE LIST
  // =======================

  List<Map<String, dynamic>> _buildSizeList() {
    final sizes = <Map<String, dynamic>>[];

    void addSize(String name, TextEditingController txt) {
      if (txt.text.trim().isEmpty) return;
      sizes.add({
        'name': name,
        'price': double.tryParse(txt.text) ?? 0,
      });
    }

    addSize('S', sPriceController);
    addSize('M', mPriceController);
    addSize('L', lPriceController);

    return sizes;
  }

  // =======================
  // BUILD
  // =======================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: Text(isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm'),
      ),

      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// IMAGE PICKER
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: imageFile != null
                      ? Image.file(imageFile!, fit: BoxFit.cover)
                      : imageUrl != null
                      ? Image.network(imageUrl!, fit: BoxFit.cover)
                      : const Center(child: Text('Chọn ảnh sản phẩm')),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// NAME
            _buildInput(
              controller: nameController,
              label: 'Tên sản phẩm',
              validator: (v) =>
              v == null || v.isEmpty ? 'Nhập tên sản phẩm' : null,
            ),

            const SizedBox(height: 16),

            /// DESC
            _buildInput(
              controller: descController,
              label: 'Mô tả',
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            /// CATEGORY
            Obx(() {
              return DropdownButtonFormField<String>(
                value: selectedCategoryId.isEmpty ? null : selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Danh mục'),
                items: controller.categories
                    .where((cat) =>
                cat['id'] != null &&
                    cat['id'].toString().isNotEmpty)
                    .map((cat) => DropdownMenuItem(
                  value: cat['id'].toString(),
                  child: Text(cat['name']),
                ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => selectedCategoryId = value ?? ''),
              );
            }),

            const SizedBox(height: 20),

            /// SIZES
            Row(
              children: [
                Expanded(child: _buildPriceInput('Size S', sPriceController)),
                const SizedBox(width: 10),
                Expanded(child: _buildPriceInput('Size M', mPriceController)),
                const SizedBox(width: 10),
                Expanded(child: _buildPriceInput('Size L', lPriceController)),
              ],
            ),

            const SizedBox(height: 30),

            /// SUBMIT
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveProduct,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : Text(isEdit ? 'Cập nhật sản phẩm' : 'Thêm sản phẩm'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildPriceInput(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}