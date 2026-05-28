import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/product_controller.dart';
import '../../models/product.dart';

class ProductFormPage
    extends StatefulWidget {
  final Product? product;

  const ProductFormPage({
    super.key,
    this.product,
  });

  @override
  State<ProductFormPage>
  createState() =>
      _ProductFormPageState();
}

class _ProductFormPageState
    extends State<ProductFormPage> {
  final controller =
      ProductController.to;

  final formKey =
  GlobalKey<FormState>();

  final nameController =
  TextEditingController();

  final descController =
  TextEditingController();

  final sPriceController =
  TextEditingController();

  final mPriceController =
  TextEditingController();

  final lPriceController =
  TextEditingController();

  String selectedCategoryId =
      '';

  File? imageFile;
  String? imageUrl;
  bool isLoading = false;

  bool get isEdit =>
      widget.product != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      final p =
      widget.product!;

      nameController.text =
          p.name;

      descController.text =
          p.description ?? '';

      selectedCategoryId =
          p.categoryId ?? '';

      imageUrl =
          p.imageUrl;

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

  Future<void>
  _loadSizes() async {
    final sizes =
    await controller
        .getSizes(
      widget.product!.id,
    );

    for (var s in sizes) {
      if (s.name == 'S') {
        sPriceController
            .text = s.price
            .toString();
      }

      if (s.name == 'M') {
        mPriceController
            .text = s.price
            .toString();
      }

      if (s.name == 'L') {
        lPriceController
            .text = s.price
            .toString();
      }
    }

    setState(() {});
  }

  Future<void>
  _pickImage() async {
    final picked =
    await ImagePicker()
        .pickImage(
      source:
      ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() {
        imageFile =
            File(picked.path);
      });
    }
  }

  Future<void>
  _saveProduct() async {
    if (!formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final sizes =
      _buildSizeList();

      if (isEdit) {
        final updated =
        Product(
          id: widget.product!.id,
          name:
          nameController.text
              .trim(),
          description:
          descController.text
              .trim(),
          imageUrl:
          imageUrl,
          categoryId:
          selectedCategoryId
              .isEmpty
              ? null
              : selectedCategoryId,
          cafeId: widget
              .product!
              .cafeId,
          isAvailable:
          widget.product!
              .isAvailable,
          createdAt:
          widget.product!
              .createdAt,
        );

        await controller
            .updateProduct(
          product: updated,
          image: imageFile,
        );

        await controller
            .updateProductSizes(
          productId:
          updated.id,
          sizes: sizes,
        );
      } else {
        final newProduct =
        Product(
          id: '',
          name:
          nameController.text
              .trim(),
          description:
          descController.text
              .trim(),
          imageUrl: null,
          categoryId:
          selectedCategoryId
              .isEmpty
              ? null
              : selectedCategoryId,
        );

        final productId =
        await controller
            .addProductAndGetId(
          product:
          newProduct,
          image:
          imageFile,
          sizes:
          sizes,
        );

        if (productId ==
            null) {
          return;
        }
      }

      Get.back();

      Get.snackbar(
        'Thành công',
        isEdit
            ? 'Đã cập nhật sản phẩm'
            : 'Đã thêm sản phẩm',
        backgroundColor:
        Colors.green,
        colorText:
        Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
        backgroundColor:
        Colors.red,
        colorText:
        Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>>
  _buildSizeList() {
    final sizes =
    <Map<String, dynamic>>[];

    void addSize(
        String name,
        TextEditingController
        txt,
        ) {
      if (txt.text
          .trim()
          .isEmpty) {
        return;
      }

      sizes.add({
        'name': name,
        'price':
        double.tryParse(
          txt.text,
        ) ??
            0,
      });
    }

    addSize(
      'S',
      sPriceController,
    );

    addSize(
      'M',
      mPriceController,
    );

    addSize(
      'L',
      lPriceController,
    );

    return sizes;
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      const Color(
        0xfff5f5f5,
      ),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor:
        Colors.white,
        foregroundColor:
        Colors.black,

        title: Text(
          isEdit
              ? 'Sửa sản phẩm'
              : 'Thêm sản phẩm',

          style:
          const TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),

      body: Form(
        key: formKey,

        child: ListView(
          padding:
          const EdgeInsets
              .all(16),

          children: [
            /// IMAGE PICKER
            GestureDetector(
              onTap:
              _pickImage,

              child: Container(
                height: 220,

                decoration:
                BoxDecoration(
                  color:
                  Colors.white,

                  borderRadius:
                  BorderRadius
                      .circular(
                    26,
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
                ClipRRect(
                  borderRadius:
                  BorderRadius
                      .circular(
                    26,
                  ),

                  child:
                  imageFile !=
                      null
                      ? Image.file(
                    imageFile!,
                    fit:
                    BoxFit.cover,
                  )
                      : imageUrl !=
                      null
                      ? Image.network(
                    imageUrl!,
                    fit:
                    BoxFit.cover,
                  )
                      : Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Container(
                        width:
                        70,
                        height:
                        70,

                        decoration:
                        BoxDecoration(
                          color: Colors.orange.withOpacity(
                            0.12,
                          ),

                          borderRadius:
                          BorderRadius.circular(
                            20,
                          ),
                        ),

                        child:
                        const Icon(
                          Icons
                              .image_outlined,
                          color:
                          Colors.orange,
                          size:
                          36,
                        ),
                      ),

                      const SizedBox(
                        height:
                        16,
                      ),

                      const Text(
                        'Chọn ảnh sản phẩm',
                        style:
                        TextStyle(
                          fontSize:
                          16,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),

                      const SizedBox(
                        height:
                        6,
                      ),

                      Text(
                        'Nhấn để tải ảnh lên',
                        style:
                        TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 22,
            ),

            /// NAME
            _buildInput(
              controller:
              nameController,
              label:
              'Tên sản phẩm',
              validator:
                  (v) {
                if (v == null ||
                    v.isEmpty) {
                  return 'Nhập tên sản phẩm';
                }

                return null;
              },
            ),

            const SizedBox(
              height: 16,
            ),

            /// DESCRIPTION
            _buildInput(
              controller:
              descController,
              label:
              'Mô tả sản phẩm',
              maxLines: 4,
            ),

            const SizedBox(
              height: 16,
            ),

            /// CATEGORY
            Obx(() {
              return Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal:
                  18,
                ),

                decoration:
                BoxDecoration(
                  color:
                  Colors.white,

                  borderRadius:
                  BorderRadius.circular(
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
                    value:
                    selectedCategoryId
                        .isEmpty
                        ? null
                        : selectedCategoryId,

                    hint:
                    const Text(
                      'Danh mục',
                    ),

                    isExpanded:
                    true,

                    items: controller
                        .categories
                        .where(
                          (cat) =>
                      cat['id'] !=
                          null &&
                          cat['id']
                              .toString()
                              .isNotEmpty,
                    )
                        .map(
                          (cat) =>
                          DropdownMenuItem<
                              String>(
                            value: cat[
                            'id']
                                .toString(),

                            child:
                            Text(
                              cat[
                              'name'],
                            ),
                          ),
                    )
                        .toList(),

                    onChanged:
                        (value) {
                      setState(() {
                        selectedCategoryId =
                            value ??
                                '';
                      });
                    },
                  ),
                ),
              );
            }),

            const SizedBox(
              height: 24,
            ),

            const Text(
              "Giá theo size",
              style:
              TextStyle(
                fontSize:
                16,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            Row(
              children: [
                Expanded(
                  child:
                  _buildPriceCard(
                    "S",
                    sPriceController,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child:
                  _buildPriceCard(
                    "M",
                    mPriceController,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child:
                  _buildPriceCard(
                    "L",
                    lPriceController,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 32,
            ),

            /// BUTTON
            SizedBox(
              height: 58,

              child:
              ElevatedButton(
                style:
                ElevatedButton
                    .styleFrom(
                  backgroundColor:
                  Colors.orange,

                  elevation:
                  0,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
                  ),
                ),

                onPressed:
                isLoading
                    ? null
                    : _saveProduct,

                child:
                isLoading
                    ? const SizedBox(
                  height:
                  22,
                  width:
                  22,
                  child:
                  CircularProgressIndicator(
                    color:
                    Colors.white,
                    strokeWidth:
                    2.5,
                  ),
                )
                    : Text(
                  isEdit
                      ? 'Cập nhật sản phẩm'
                      : 'Thêm sản phẩm',
                  style:
                  const TextStyle(
                    fontSize:
                    16,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController
    controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)?
    validator,
  }) {
    return Container(
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(
          20,
        ),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(
              0.04,
            ),
            blurRadius: 10,
            offset:
            const Offset(0, 4),
          ),
        ],
      ),

      child: TextFormField(
        controller:
        controller,
        maxLines:
        maxLines,
        validator:
        validator,

        decoration:
        InputDecoration(
          hintText:
          label,

          border:
          InputBorder.none,

          contentPadding:
          const EdgeInsets.all(
            18,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceCard(
      String label,
      TextEditingController
      controller,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(
        14,
      ),

      decoration:
      BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(
          20,
        ),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(
              0.04,
            ),
            blurRadius: 10,
            offset:
            const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        children: [
          Text(
            'Size $label',
            style:
            const TextStyle(
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          TextField(
            controller:
            controller,
            keyboardType:
            TextInputType.number,

            textAlign:
            TextAlign.center,

            decoration:
            const InputDecoration(
              hintText:
              '0đ',
              border:
              InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}