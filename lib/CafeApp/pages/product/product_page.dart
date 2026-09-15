import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/product_controller.dart';
import '../../dialogs/product_detail_popup.dart';
import '../../widgets/product_parallax_item.dart';

class ProductPage extends GetView<ProductController> {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          "Thực đơn",
          style: TextStyle(
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
      body: Column(
        children: [
          /// SEARCH INPUT
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xfffafafa),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffe5e5e5)),
              ),
              child: TextField(
                controller: controller.searchController,
                onChanged: (value) {
                  controller.searchText.value = value;
                },
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Tìm kiếm món...",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.black54, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          /// CATEGORY SELECTOR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xfffafafa),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffe5e5e5)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedCategoryId.value.isEmpty
                        ? ''
                        : controller.selectedCategoryId.value,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54, size: 20),
                    hint: const Text("Tất cả danh mục", style: TextStyle(fontSize: 13)),
                    items: controller.categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat['id'].toString(),
                        child: Text(
                          cat['name'],
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      controller.selectedCategoryId.value = value ?? '';
                    },
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 12),

          /// LIST PRODUCTS
          Expanded(
            child: Obx(() {
              final list = controller.filteredProducts;

              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 52,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Không tìm thấy món",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Thử tìm bằng từ khóa hoặc danh mục khác",
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final p = list[index];

                  return ProductParallaxItem(
                    product: p,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => ProductDetailPopup(product: p),
                      );
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}