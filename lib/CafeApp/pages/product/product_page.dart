import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/product_controller.dart';
import '../../dialogs/product_detail_popup.dart';

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

              return GridView.builder(
                padding:
                const EdgeInsets
                    .fromLTRB(
                  16,
                  0,
                  16,
                  16,
                ),

                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                  2,

                  childAspectRatio:
                  0.72,

                  crossAxisSpacing:
                  14,

                  mainAxisSpacing:
                  14,
                ),

                itemCount:
                list.length,

                itemBuilder:
                    (context,
                    index) {
                  final p =
                  list[index];

                  return InkWell(
                    borderRadius:
                    BorderRadius
                        .circular(
                      24,
                    ),

                    onTap: () {
                      showModalBottomSheet(
                        context:
                        context,
                        isScrollControlled:
                        true,
                        backgroundColor:
                        Colors
                            .transparent,
                        builder:
                            (_) =>
                            ProductDetailPopup(
                              product:
                              p,
                            ),
                      );
                    },

                    child:
                    Container(
                      decoration:
                      BoxDecoration(
                        color:
                        Colors.white,

                        borderRadius:
                        BorderRadius.circular(
                          24,
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: Colors
                                .black
                                .withOpacity(
                              0.05,
                            ),
                            blurRadius:
                            12,
                            offset:
                            const Offset(
                              0,
                              5,
                            ),
                          ),
                        ],
                      ),

                      child:
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          /// IMAGE
                          Container(
                            height:
                            130,

                            margin:
                            const EdgeInsets.all(
                              10,
                            ),

                            decoration:
                            BoxDecoration(
                              color:
                              Colors.grey[
                              100],
                              borderRadius:
                              BorderRadius.circular(
                                18,
                              ),
                            ),

                            child:
                            ClipRRect(
                              borderRadius:
                              BorderRadius.circular(
                                18,
                              ),

                              child:
                              p.imageUrl !=
                                  null
                                  ? Image.network(
                                p.imageUrl!,
                                width:
                                double.infinity,
                                fit: BoxFit.cover,
                              )
                                  : Center(
                                child:
                                Icon(
                                  Icons.image_outlined,
                                  color: Colors.grey.shade400,
                                  size: 34,
                                ),
                              ),
                            ),
                          ),

                          Expanded(
                            child:
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal:
                                14,
                              ),

                              child:
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    maxLines:
                                    1,
                                    overflow:
                                    TextOverflow.ellipsis,
                                    style:
                                    const TextStyle(
                                      fontWeight:
                                      FontWeight.bold,
                                      fontSize:
                                      16,
                                    ),
                                  ),

                                  const SizedBox(
                                    height:
                                    6,
                                  ),

                                  Text(
                                    p.description ??
                                        'Không có mô tả',
                                    maxLines:
                                    2,
                                    overflow:
                                    TextOverflow.ellipsis,
                                    style:
                                    TextStyle(
                                      color:
                                      Colors.grey.shade600,
                                      fontSize:
                                      13,
                                    ),
                                  ),

                                  const Spacer(),

                                  Text(
                                    p.minPrice !=
                                        null
                                        ? "${p.minPrice!.toInt()}đ"
                                        : "Chưa có giá",

                                    style:
                                    const TextStyle(
                                      color:
                                      Colors.orange,
                                      fontWeight:
                                      FontWeight.bold,
                                      fontSize:
                                      18,
                                    ),
                                  ),

                                  const SizedBox(
                                    height:
                                    14,
                                  ),
                                ],
                              ),
                            ),
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
    );
  }
}