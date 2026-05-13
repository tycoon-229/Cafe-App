import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/product_controller.dart';
import '../models/product.dart';
import 'product_form_page.dart';

class ProductManagePage extends StatelessWidget {
  ProductManagePage({super.key});

  final controller = ProductController.to;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Quản lý sản phẩm"),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,

        child: const Icon(Icons.add),

        onPressed: () {
          Get.to(() => ProductFormPage());
        },
      ),

      body: Obx(() {
        final products = controller.products;

        if (products.isEmpty) {
          return const Center(
            child: Text("Chưa có sản phẩm"),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: products.length,

          itemBuilder: (_, index) {
            final p = products[index];

            return Card(
              elevation: 0,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),

              child: ListTile(
                contentPadding: const EdgeInsets.all(12),

                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),

                  child: p.imageUrl != null
                      ? Image.network(
                    p.imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],

                    child: const Icon(Icons.image),
                  ),
                ),

                title: Text(
                  p.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                subtitle: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    const SizedBox(height: 4),

                    Text(
                      p.description ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      p.minPrice != null
                          ? "${p.minPrice!.toInt()}đ"
                          : "Chưa có giá",

                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                trailing: PopupMenuButton(
                  itemBuilder: (_) => [

                    /// EDIT
                    const PopupMenuItem(
                      value: 'edit',

                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text("Sửa"),
                        ],
                      ),
                    ),

                    /// DELETE
                    const PopupMenuItem(
                      value: 'delete',

                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),

                          SizedBox(width: 8),

                          Text(
                            "Xóa",
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  onSelected: (value) {
                    if (value == 'edit') {
                      Get.to(
                            () => ProductFormPage(
                          product: p,
                        ),
                      );
                    }

                    if (value == 'delete') {
                      _deleteProduct(p);
                    }
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }

  ////////////////////////////////////////////////////////////

  void _deleteProduct(Product p) {
    Get.defaultDialog(
      title: "Xóa sản phẩm",

      middleText:
      "Bạn có chắc muốn xóa ${p.name} ?",

      textCancel: "Hủy",

      textConfirm: "Xóa",

      confirmTextColor: Colors.white,

      buttonColor: Colors.red,

      onConfirm: () async {
        Get.back();

        await ProductSnapshot.delete(p.id);

        controller.loadProducts();

        Get.snackbar(
          "Thành công",
          "Đã xóa sản phẩm",
        );
      },
    );
  }
}