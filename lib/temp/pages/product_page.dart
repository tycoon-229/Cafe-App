import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../dialogs/product_detail_popup.dart';

class ProductPage extends StatelessWidget {
  ProductPage({super.key});

  final controller = ProductController.to;
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Menu"),
        centerTitle: true,
      ),

      body: Column(
        children: [

          /// 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                controller.searchText.value = value;
              },
              decoration: InputDecoration(
                hintText: "Tìm sản phẩm...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          /// Lọc Category
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "Loại sản phẩm",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 6),
              /// DROPDOWN CATEGORY
              Obx(() {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedCategoryId.value.isEmpty
                            ? ''
                            : controller.selectedCategoryId.value,
                        isExpanded: true,
                        hint: const Text("Chọn loại sản phẩm"),

                        items: controller.categories.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat['id'].toString(),
                            child: Text(cat['name']),
                          );
                        }).toList(),

                        onChanged: (value) {
                          controller.selectedCategoryId.value = value ?? '';
                        },
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),

          /// GRID
          Expanded(
            child: Obx(() {
              final list = controller.filteredProducts;

              if (list.isEmpty) {
                return const Center(child: Text("Không có sản phẩm"));
              }

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                padding: const EdgeInsets.all(12),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final p = list[index];

                  return GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => ProductDetailPopup(product: p),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// IMAGE
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              height: 110,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: p.imageUrl != null
                                    ? Image.network(
                                  p.imageUrl!,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                                    : const Center(
                                  child: Icon(Icons.image, size: 30),
                                ),
                              ),
                            ),
                          ),

                          /// INFO
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                /// NAME
                                Center(
                                  child: Text(
                                    p.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 4),

                                /// DESCRIPTION
                                Text(
                                  p.description ?? 'Không có mô tả',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                /// PRICE
                                Center(
                                  child: Text(
                                    p.minPrice != null
                                        ? "${p.minPrice!.toInt()}đ"
                                        : "Chưa có giá",
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          )
        ],
      ),
    );
  }
}