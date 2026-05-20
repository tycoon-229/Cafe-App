import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../controllers/product_controller.dart';
import '../../models/product.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;

  const ProductFormPage({
    super.key,
    this.product,
  });

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {

  final controller = ProductController.to;
  final supabase = Supabase.instance.client;
  final formKey = GlobalKey<FormState>();

  ////////////////////////////////////////////////////////////

  final nameController = TextEditingController();
  final descController = TextEditingController();
  final sPriceController = TextEditingController();
  final mPriceController = TextEditingController();
  final lPriceController = TextEditingController();

  ////////////////////////////////////////////////////////////

  String selectedCategoryId = '';
  File? imageFile;
  String? imageUrl;
  bool isLoading = false;
  bool get isEdit => widget.product != null;

  ////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      final p = widget.product!;
      nameController.text = p.name;
      descController.text = p.description ?? '';
      selectedCategoryId = p.categoryId ?? '';
      imageUrl = p.imageUrl;
      loadSizes();
    }
  }

  ////////////////////////////////////////////////////////////

  Future<void> loadSizes() async {
    final sizes = await supabase
        .from('product_sizes')
        .select()
        .eq('product_id', widget.product!.id);

    for (var s in sizes) {
      if (s['name'] == 'S') {
        sPriceController.text = s['price'].toString();
      }
      if (s['name'] == 'M') {
        mPriceController.text = s['price'].toString();
      }
      if (s['name'] == 'L') {
        lPriceController.text = s['price'].toString();
      }
    }
    setState(() {});
  }

  ////////////////////////////////////////////////////////////

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null) {
      imageFile = File(picked.path);

      setState(() {});
    }
  }

  ////////////////////////////////////////////////////////////

  Future<String?> uploadImage(
      String productId,
      ) async {
    if (imageFile == null) {
      return imageUrl;
    }

    final path = "products/product_$productId.jpg";

    await supabase.storage
        .from('product_images')
        .upload(
      path,
      imageFile!,
      fileOptions:
      const FileOptions(upsert: true),
    );

    return supabase.storage
        .from('product_images')
        .getPublicUrl(path);
  }

  ////////////////////////////////////////////////////////////

  Future<void> saveProduct() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading = true;

      setState(() {});

      //////////////////////////////////////////////////////
      /// EDIT
      if (isEdit) {
        final productId = widget.product!.id;

        /// upload image
        final uploadedImage = await uploadImage(productId);

        /// update product
        await supabase
            .from('products')
            .update({
          'name': nameController.text.trim(),
          'description': descController.text.trim(),
          'image_url': uploadedImage,
          'category_id': selectedCategoryId,
        })
            .eq('id', productId);

        ////////////////////////////////////////////////////
        /// DELETE OLD SIZE
        await supabase
            .from('product_sizes')
            .delete()
            .eq('product_id', productId);

        ////////////////////////////////////////////////////
        /// INSERT SIZE
        await insertSizes(productId);
      }

      //////////////////////////////////////////////////////
      /// CREATE
      else {
        /// insert product first
        final inserted = await supabase
            .from('products')
            .insert({
          'name': nameController.text.trim(),
          'description': descController.text.trim(),
          'category_id': selectedCategoryId,
        })
            .select()
            .single();

        final productId =
        inserted['id'].toString();

        ////////////////////////////////////////////////////
        /// upload image
        final uploadedImage =
        await uploadImage(productId);

        ////////////////////////////////////////////////////
        /// update image url
        if (uploadedImage != null) {
          await supabase
              .from('products')
              .update({
            'image_url':
            uploadedImage,
          })
              .eq('id', productId);
        }

        ////////////////////////////////////////////////////
        /// insert sizes
        await insertSizes(productId);
      }

      //////////////////////////////////////////////////////

      await controller.loadProducts();

      //////////////////////////////////////////////////////

      Get.back();

      Get.snackbar(
        "Thành công",

        isEdit
            ? "Đã cập nhật sản phẩm"
            : "Đã thêm sản phẩm",

        backgroundColor: Colors.green,

        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Lỗi",
        e.toString(),

        backgroundColor: Colors.red,

        colorText: Colors.white,
      );
    } finally {
      isLoading = false;

      setState(() {});
    }
  }

  ////////////////////////////////////////////////////////////

  Future<void> insertSizes(
      String productId,
      ) async {
    List<Map<String, dynamic>> sizes = [];

    void addSize(
        String name,
        TextEditingController txt,
        ) {
      if (txt.text.trim().isEmpty) return;

      sizes.add({
        'product_id': productId,
        'name': name,
        'price':
        double.tryParse(txt.text) ?? 0,
      });
    }

    addSize('S', sPriceController);

    addSize('M', mPriceController);

    addSize('L', lPriceController);

    if (sizes.isNotEmpty) {
      await supabase
          .from('product_sizes')
          .insert(sizes);
    }
  }

  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: Text(
          isEdit
              ? "Sửa sản phẩm"
              : "Thêm sản phẩm",
        ),
      ),

      body: Form(
        key: formKey,

        child: ListView(
          padding: const EdgeInsets.all(16),

          children: [

            //////////////////////////////////////////////////
            /// IMAGE
            GestureDetector(
              onTap: pickImage,

              child: Container(
                height: 180,

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(18),

                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),

                child: ClipRRect(
                  borderRadius:
                  BorderRadius.circular(18),

                  child: imageFile != null
                      ? Image.file(
                    imageFile!,
                    fit: BoxFit.cover,
                  )
                      : imageUrl != null
                      ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                  )
                      : Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,

                    children: const [
                      Icon(
                        Icons.add_a_photo,
                        size: 40,
                        color: Colors.grey,
                      ),

                      SizedBox(height: 10),

                      Text(
                        "Chọn ảnh sản phẩm",
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            //////////////////////////////////////////////////
            /// NAME
            _buildInput(
              controller: nameController,

              label: "Tên sản phẩm",

              validator: (v) {
                if (v == null || v.isEmpty) {
                  return "Nhập tên sản phẩm";
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            //////////////////////////////////////////////////
            /// DESCRIPTION
            _buildInput(
              controller: descController,
              label: "Mô tả",
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            //////////////////////////////////////////////////
            /// CATEGORY
            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 14,
              ),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                BorderRadius.circular(14),

                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),

              child: Obx(() {
                return DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value:
                    selectedCategoryId.isEmpty
                        ? null
                        : selectedCategoryId,

                    hint:
                    const Text("Chọn loại"),

                    isExpanded: true,

                    items: controller.categories
                        .where(
                          (e) =>
                      e['id'] != '',
                    )
                        .map((cat) {
                      return DropdownMenuItem(
                        value:
                        cat['id']
                            .toString(),

                        child: Text(
                          cat['name'],
                        ),
                      );
                    }).toList(),

                    onChanged: (value) {
                      selectedCategoryId =
                          value ?? '';

                      setState(() {});
                    },
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            //////////////////////////////////////////////////
            /// SIZE
            const Text(
              "Giá theo size",

              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildPriceInput(
                    "Size S",
                    sPriceController,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _buildPriceInput(
                    "Size M",
                    mPriceController,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _buildPriceInput(
                    "Size L",
                    lPriceController,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            //////////////////////////////////////////////////
            /// BUTTON
            SizedBox(
              height: 55,

              child: ElevatedButton(
                onPressed:
                isLoading
                    ? null
                    : saveProduct,

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  Colors.orange,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(16),
                  ),
                ),

                child: isLoading
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : Text(
                  isEdit
                      ? "Cập nhật sản phẩm"
                      : "Thêm sản phẩm",

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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

  ////////////////////////////////////////////////////////////

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

        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),

          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////

  Widget _buildPriceInput(
      String label,
      TextEditingController controller,
      ) {
    return TextFormField(
      controller: controller,

      keyboardType: TextInputType.number,

      decoration: InputDecoration(
        labelText: label,

        filled: true,

        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),

          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}