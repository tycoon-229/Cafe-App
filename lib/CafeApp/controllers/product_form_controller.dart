import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import 'product_controller.dart';

class ProductFormController extends GetxController {
  final Product? initialProduct;

  ProductFormController({this.initialProduct});

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final sPriceController = TextEditingController();
  final mPriceController = TextEditingController();
  final lPriceController = TextEditingController();

  final selectedCategoryId = ''.obs;
  final imageFile = Rxn<File>();
  final imageUrl = Rxn<String>();
  final isLoading = false.obs;

  bool get isEdit => initialProduct != null;

  @override
  void onInit() {
    super.onInit();
    if (isEdit) {
      final p = initialProduct!;
      nameController.text = p.name;
      descController.text = p.description ?? '';
      selectedCategoryId.value = p.categoryId ?? '';
      imageUrl.value = p.imageUrl;
      _loadSizes();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descController.dispose();
    sPriceController.dispose();
    mPriceController.dispose();
    lPriceController.dispose();
    super.onClose();
  }

  Future<void> _loadSizes() async {
    final sizes = await ProductController.to.getSizes(initialProduct!.id);
    for (var s in sizes) {
      if (s.name == 'S') sPriceController.text = s.price.toString();
      if (s.name == 'M') mPriceController.text = s.price.toString();
      if (s.name == 'L') lPriceController.text = s.price.toString();
    }
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) {
      imageFile.value = File(picked.path);
    }
  }

  Future<void> saveProduct() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final sizes = _buildSizeList();
      final productController = ProductController.to;

      if (isEdit) {
        final updated = Product(
          id: initialProduct!.id,
          name: nameController.text.trim(),
          description: descController.text.trim(),
          imageUrl: imageUrl.value,
          categoryId: selectedCategoryId.value.isEmpty
              ? null
              : selectedCategoryId.value,
          cafeId: initialProduct!.cafeId,
          isAvailable: initialProduct!.isAvailable,
          createdAt: initialProduct!.createdAt,
        );

        await productController.updateProduct(
          product: updated,
          image: imageFile.value,
        );

        await productController.updateProductSizes(
          productId: updated.id,
          sizes: sizes,
        );
      } else {
        final newProduct = Product(
          id: '',
          name: nameController.text.trim(),
          description: descController.text.trim(),
          imageUrl: null,
          categoryId: selectedCategoryId.value.isEmpty
              ? null
              : selectedCategoryId.value,
        );

        await productController.addProductAndGetId(
          product: newProduct,
          image: imageFile.value,
          sizes: sizes,
        );
      }

      Get.back();
      Get.snackbar(
        'Thành công',
        isEdit ? 'Đã cập nhật sản phẩm' : 'Đã thêm sản phẩm',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
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

  List<Map<String, dynamic>> _buildSizeList() {
    final sizes = <Map<String, dynamic>>[];
    void addSize(String name, TextEditingController txt) {
      if (txt.text.trim().isEmpty) return;
      sizes.add({'name': name, 'price': double.tryParse(txt.text) ?? 0});
    }

    addSize('S', sPriceController);
    addSize('M', mPriceController);
    addSize('L', lPriceController);
    return sizes;
  }
}
