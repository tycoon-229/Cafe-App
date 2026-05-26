import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/product_controller.dart';
import '../../models/product.dart';
import 'product_form_page.dart';

class ProductManagePage extends StatelessWidget {
  ProductManagePage({super.key});

  final controller = ProductController.to;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text('Quản lý sản phẩm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: _showCategoryManager,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
        onPressed: () => Get.to(() => ProductFormPage()),
      ),

      body: Obx(() {
        final products = controller.products;

        if (products.isEmpty) {
          return const Center(child: Text('Chưa có sản phẩm'));
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      p.description ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.minPrice != null
                          ? '${p.minPrice!.toInt()}đ'
                          : 'Chưa có giá',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                trailing: PopupMenuButton(
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Sửa'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Xóa', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      Get.to(() => ProductFormPage(product: p));
                    }
                    if (value == 'delete') {
                      _confirmDelete(p);
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

  // =======================
  // DELETE
  // =======================

  void _confirmDelete(Product p) {
    Get.defaultDialog(
      title: 'Xóa sản phẩm',
      middleText: 'Bạn có chắc muốn xóa ${p.name}?',
      textCancel: 'Hủy',
      textConfirm: 'Xóa',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();

        await controller.deleteProduct(p.id);
      },
    );
  }

  // =======================
  // CATEGORY MANAGER
  // =======================

  void _showCategoryManager() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Quản lý Danh mục',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddCategoryDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: Obx(() {
                final categories =
                controller.categories.where((e) => e['id'] != '').toList();

                if (categories.isEmpty) {
                  return const Center(child: Text('Chưa có danh mục'));
                }

                return ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (_, index) {
                    final c = categories[index];

                    return Card(
                      child: ListTile(
                        title: Text(c['name']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditCategoryDialog(
                                c['id'],
                                c['name'],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  controller.deleteCategory(c['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showAddCategoryDialog() {
    final textController = TextEditingController();

    Get.defaultDialog(
      title: 'Thêm danh mục',
      content: TextField(
        controller: textController,
        decoration: const InputDecoration(hintText: 'Tên danh mục'),
      ),
      textCancel: 'Huỷ',
      textConfirm: 'Thêm',
      onConfirm: () async {
        final name = textController.text.trim();
        if (name.isEmpty) return;
        Get.back();
        await controller.addCategory(name);
      },
    );
  }

  void _showEditCategoryDialog(String id, String currentName) {
    final textController = TextEditingController(text: currentName);

    Get.defaultDialog(
      title: 'Sửa danh mục',
      content: TextField(controller: textController),
      textCancel: 'Huỷ',
      textConfirm: 'Lưu',
      onConfirm: () async {
        final name = textController.text.trim();
        if (name.isEmpty) return;
        Get.back();
        await controller.updateCategory(id, name);
      },
    );
  }
}