import 'package:get/get.dart';
import '../models/product.dart';
import '../models/product_size.dart';
import 'order_controller.dart';
import 'product_controller.dart';
import 'package:flutter/material.dart';

class ProductDetailController extends GetxController {
  final Product product;

  ProductDetailController({required this.product});

  final sizes = <ProductSize>[].obs;
  final selectedSize = Rxn<ProductSize>();
  final quantity = 1.obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadSizes();
  }

  Future<void> loadSizes() async {
    try {
      isLoading.value = true;
      final data = await ProductController.to.getSizes(product.id);
      sizes.assignAll(data);
      if (sizes.isNotEmpty) {
        selectedSize.value = sizes.first;
      }
    } finally {
      isLoading.value = false;
    }
  }

  void selectSize(ProductSize size) {
    selectedSize.value = size;
  }

  void incrementQuantity() {
    quantity.value++;
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  double get currentPrice => selectedSize.value?.price ?? 0;
  double get totalPrice => currentPrice * quantity.value;

  Future<void> addToOrder() async {
    if (selectedSize.value == null) {
      Get.snackbar(
        'Nhắc nhở',
        'Vui lòng chọn kích cỡ trước khi thêm vào đơn',
        backgroundColor: Colors.amber,
        colorText: Colors.black,
      );
      return;
    }

    await Get.find<OrderController>().addProduct(
      productId: product.id,
      productName: product.name,
      sizeId: selectedSize.value!.id,
      sizeName: selectedSize.value!.name,
      price: selectedSize.value!.price.toDouble(),
      quantity: quantity.value,
    );

    Get.back();

    Get.snackbar(
      'Thành công',
      'Đã thêm ${quantity.value} ${product.name} vào đơn',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
}
