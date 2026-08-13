import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/product_controller.dart';
import '../../dialogs/product_detail_popup.dart';
import '../../widgets/product_parallax_item.dart';

class ProductPage extends StatelessWidget {
  ProductPage({super.key});

  final controller = ProductController.to;
  final searchController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xfff5f5f5),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor:
        Colors.white,
        foregroundColor:
        Colors.black,

        title: const Text(
          "Menu",
          style: TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          /// SEARCH
          Padding(
            padding:
            const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              10,
            ),

            child: Container(
              decoration:
              BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius
                    .circular(22),

                boxShadow: [
                  BoxShadow(
                    color: Colors
                        .black
                        .withOpacity(
                      0.04,
                    ),
                    blurRadius: 10,
                    offset:
                    const Offset(
                      0,
                      4,
                    ),
                  ),
                ],
              ),

              child: TextField(
                controller:
                searchController,

                onChanged:
                    (value) {
                  controller
                      .searchText
                      .value =
                      value;
                },

                decoration:
                InputDecoration(
                  hintText:
                  "Tìm sản phẩm...",
                  hintStyle:
                  TextStyle(
                    color: Colors
                        .grey
                        .shade500,
                  ),

                  prefixIcon:
                  Container(
                    margin:
                    const EdgeInsets
                        .all(10),

                    decoration:
                    BoxDecoration(
                      color: Colors
                          .orange
                          .withOpacity(
                        0.12,
                      ),

                      borderRadius:
                      BorderRadius
                          .circular(
                        14,
                      ),
                    ),

                    child:
                    const Icon(
                      Icons.search,
                      color: Colors
                          .orange,
                    ),
                  ),

                  border:
                  InputBorder.none,

                  contentPadding:
                  const EdgeInsets
                      .symmetric(
                    vertical: 18,
                  ),
                ),
              ),
            ),
          ),

          /// CATEGORY
          Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 16,
            ),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                const Padding(
                  padding:
                  EdgeInsets.only(
                    left: 4,
                    bottom: 8,
                  ),

                  child: Text(
                    "Loại sản phẩm",
                    style:
                    TextStyle(
                      fontSize: 15,
                      fontWeight:
                      FontWeight
                          .w600,
                    ),
                  ),
                ),

                Obx(() {
                  return Container(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 16,
                    ),

                    decoration:
                    BoxDecoration(
                      color:
                      Colors.white,

                      borderRadius:
                      BorderRadius
                          .circular(
                        20,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors
                              .black
                              .withOpacity(
                            0.04,
                          ),
                          blurRadius:
                          10,
                          offset:
                          const Offset(
                            0,
                            4,
                          ),
                        ),
                      ],
                    ),

                    child:
                    DropdownButtonHideUnderline(
                      child:
                      DropdownButton<
                          String>(
                        value: controller
                            .selectedCategoryId
                            .value
                            .isEmpty
                            ? ''
                            : controller
                            .selectedCategoryId
                            .value,

                        isExpanded:
                        true,

                        borderRadius:
                        BorderRadius.circular(
                          18,
                        ),

                        hint:
                        const Text(
                          "Chọn loại sản phẩm",
                        ),

                        items: controller
                            .categories
                            .map((cat) {
                          return DropdownMenuItem<
                              String>(
                            value: cat[
                            'id']
                                .toString(),
                            child: Text(
                              cat[
                              'name'],
                            ),
                          );
                        }).toList(),

                        onChanged:
                            (value) {
                          controller
                              .selectedCategoryId
                              .value =
                              value ??
                                  '';
                        },
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          /// GRID
          Expanded(
            child: Obx(() {
              final list =
                  controller
                      .filteredProducts;

              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                    children: [
                      Icon(
                        Icons
                            .fastfood_outlined,
                        size: 80,
                        color: Colors
                            .grey
                            .shade400,
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      const Text(
                        "Không có sản phẩm",
                        style:
                        TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight
                              .w600,
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Text(
                        "Danh sách món sẽ hiển thị tại đây",
                        style:
                        TextStyle(
                          color: Colors
                              .grey
                              .shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
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
                        builder: (_) => ProductDetailPopup(
                          product: p,
                        ),
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