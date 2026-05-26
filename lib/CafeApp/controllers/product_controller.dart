import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';
import '../models/product_size.dart';

class ProductController extends GetxController {
  static ProductController get to => Get.find();

  final supabase = Supabase.instance.client;

  // =======================
  // STATE
  // =======================

  final products = <Product>[].obs;
  final cart = <CartItem>[].obs;
  final categories = <Map<String, dynamic>>[].obs;
  final selectedCategoryId = ''.obs;
  final searchText = ''.obs;
  final isLoading = false.obs;

  // Cache cafe_id
  String? _cafeId;

  // =======================
  // GETTERS
  // =======================

  int get totalItems => cart.length;

  int get totalQuantity =>
      cart.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      cart.fold(0, (sum, item) => sum + (item.price * item.quantity));

  List<Product> get filteredProducts {
    final keyword = _removeVietnameseTones(searchText.value);

    return products.where((p) {
      final name = _removeVietnameseTones(p.name);
      final matchSearch = name.contains(keyword);
      final matchCategory = selectedCategoryId.value.isEmpty ||
          p.categoryId.toString() == selectedCategoryId.value;
      return matchSearch && matchCategory;
    }).toList();
  }

  // =======================
  // INIT / CLOSE
  // =======================

  @override
  void onInit() {
    super.onInit();

    _resetState();

    Future.microtask(() {
      _initData();
    });
  }

  @override
  void onClose() {
    _resetState();
    super.onClose();
  }

  void _resetState() {
    products.clear();
    cart.clear();
    categories.clear();
    selectedCategoryId.value = '';
    searchText.value = '';
    _cafeId = null;
  }

  Future<void> _initData() async {
    await fetchCategories();
    await loadProducts();
  }

  // =======================
  // LẤY CAFE ID (có cache)
  // =======================

  Future<String> getCafeId() async {
    if (_cafeId != null) {
      return _cafeId!;
    }

    final user =
        supabase.auth.currentUser;

    if (user == null) {
      throw 'User chưa đăng nhập';
    }

    final cafe = await supabase
        .from('cafes')
        .select('id')
        .eq('owner_id', user.id)
        .single();

    _cafeId =
        cafe['id'].toString();

    return _cafeId!;
  }

  // =======================
  // PRODUCTS - FETCH
  // =======================

  Future<void> loadProducts() async {
    try {
      isLoading.value = true;

      final cafeId = await getCafeId();

      final productData = await supabase
          .from('products')
          .select()
          .eq('cafe_id', cafeId);

      List<Product> list =
      (productData as List).map((e) => Product.fromJson(e)).toList();

      // Load giá nhỏ nhất cho từng sản phẩm
      for (var p in list) {
        final size = await supabase
            .from('product_sizes')
            .select('price')
            .eq('product_id', p.id)
            .order('price', ascending: true)
            .limit(1)
            .maybeSingle();

        if (size != null) {
          p.minPrice = double.tryParse(size['price'].toString()) ?? 0;
        }
      }

      products.assignAll(list);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không tải được sản phẩm: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // =======================
  // PRODUCTS - CRUD
  // =======================

  Future<void> addProduct({
    required Product product,
    File? image,
  }) async {
    try {
      isLoading.value = true;

      final cafeId = await getCafeId();
      product.cafeId = cafeId;

      if (image != null) {
        product.imageUrl = await _uploadProductImage(image, product.id);
      }

      final data = await supabase
          .from('products')
          .insert(product.toJson())
          .select()
          .single();

      final newProduct = Product.fromJson(data);
      products.add(newProduct);

      Get.snackbar('Thành công', 'Đã thêm sản phẩm');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể thêm sản phẩm: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProduct({
    required Product product,
    File? image,
  }) async {
    try {
      isLoading.value = true;

      final cafeId = await getCafeId();
      product.cafeId = cafeId;

      if (image != null) {
        product.imageUrl = await _uploadProductImage(image, product.id);
      }

      final data = await supabase
          .from('products')
          .update({...product.toJson(), 'cafe_id': product.cafeId})
          .eq('id', product.id)
          .select()
          .single();

      final updated = Product.fromJson(data);
      final index = products.indexWhere((p) => p.id == product.id);

      if (index != -1) products[index] = updated;

      Get.snackbar('Thành công', 'Đã cập nhật sản phẩm');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật sản phẩm: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Dùng bởi ProductFormPage khi tạo mới: trả về productId sau khi insert
  Future<String?> addProductAndGetId({
    required Product product,
    File? image,
    List<Map<String, dynamic>> sizes = const [],
  }) async {
    try {
      isLoading.value = true;

      final cafeId = await getCafeId();
      product.cafeId = cafeId;

      // Insert product trước để có id
      final data = await supabase
          .from('products')
          .insert(product.toJson())
          .select()
          .single();

      final productId = data['id'].toString();

      // Upload ảnh nếu có, rồi update image_url
      if (image != null) {
        final uploadedUrl = await _uploadProductImage(image, productId);
        if (uploadedUrl != null) {
          await supabase
              .from('products')
              .update({'image_url': uploadedUrl}).eq('id', productId);
          data['image_url'] = uploadedUrl;
        }
      }

      // Insert sizes
      if (sizes.isNotEmpty) {
        await _insertSizes(productId: productId, cafeId: cafeId, sizes: sizes);
      }

      // Load minPrice cho product vừa thêm
      final newProduct = Product.fromJson(data);
      final minSize = await supabase
          .from('product_sizes')
          .select('price')
          .eq('product_id', productId)
          .order('price', ascending: true)
          .limit(1)
          .maybeSingle();
      if (minSize != null) {
        newProduct.minPrice = double.tryParse(minSize['price'].toString()) ?? 0;
      }

      products.add(newProduct);

      return productId;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể thêm sản phẩm: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProductSizes({
    required String productId,
    required List<Map<String, dynamic>> sizes,
  }) async {
    try {
      final cafeId = await getCafeId();

      // Lấy size hiện tại trong DB
      final existingSizes = await supabase
          .from('product_sizes')
          .select()
          .eq('product_id', productId);

      for (final size in sizes) {
        final sizeName =
        size['name']
            .toString()
            .trim();

        final price =
            double.tryParse(
              size['price']
                  .toString(),
            ) ??
                0;

        // tìm size đã tồn tại chưa
        final existing =
        (existingSizes as List)
            .cast<
            Map<String,
                dynamic>
        >()
            .firstWhere(
              (s) =>
          s['name'] ==
              sizeName,
          orElse:
              () => {},
        );

        // nếu có -> update
        if (existing.isNotEmpty) {
          await supabase
              .from(
            'product_sizes',
          )
              .update({
            'price': price,
          })
              .eq(
            'id',
            existing['id'],
          );
        }

        // chưa có -> insert
        else {
          await supabase
              .from(
            'product_sizes',
          )
              .insert({
            'product_id':
            productId,
            'cafe_id':
            cafeId,
            'name':
            sizeName,
            'price':
            price,
          });
        }
      }

      // XÓA size không còn tồn tại
      final currentNames =
      sizes
          .map(
            (e) =>
            e['name']
                .toString(),
      )
          .toList();

      for (final existing
      in existingSizes) {
        if (!currentNames.contains(
          existing['name'],
        )) {
          await supabase
              .from(
            'product_sizes',
          )
              .delete()
              .eq(
            'id',
            existing['id'],
          );
        }
      }

      // cập nhật minPrice local
      final minSize =
      await supabase
          .from(
        'product_sizes',
      )
          .select('price')
          .eq(
        'product_id',
        productId,
      )
          .order(
        'price',
        ascending: true,
      )
          .limit(1)
          .maybeSingle();

      final index =
      products.indexWhere(
            (p) =>
        p.id ==
            productId,
      );

      if (index != -1 &&
          minSize != null) {
        products[index]
            .minPrice =
            double.tryParse(
              minSize['price']
                  .toString(),
            ) ??
                0;

        products.refresh();
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể cập nhật size: $e',
      );

      print(e);
    }
  }

  Future<void> _insertSizes({
    required String productId,
    required String cafeId,
    required List<Map<String, dynamic>> sizes,
  }) async {
    if (sizes.isEmpty) return;

    final rows =
    sizes.map((s) {
      return {
        'product_id':
        productId,
        'cafe_id':
        cafeId,
        'name':
        s['name']
            .toString()
            .trim(),
        'price':
        double.tryParse(
          s['price']
              .toString(),
        ) ??
            0,
      };
    }).toList();

    await supabase
        .from('product_sizes')
        .insert(rows);
  }

  Future<void> deleteProduct(
      String productId,
      ) async {
    try {
      isLoading.value = true;

      // 1. Xóa size trước
      await supabase
          .from(
        'product_sizes',
      )
          .delete()
          .eq(
        'product_id',
        productId,
      );

      // 2. Xóa product
      await supabase
          .from(
        'products',
      )
          .delete()
          .eq(
        'id',
        productId,
      );

      // 3. Xóa ảnh storage
      await _removeProductImage(
        productId,
      );

      // 4. Xóa local list
      products.removeWhere(
            (p) =>
        p.id ==
            productId,
      );

      Get.snackbar(
        'Thành công',
        'Đã xóa sản phẩm',
      );
    } catch (e) {
      print(e);

      Get.snackbar(
        'Lỗi',
        'Không thể xóa sản phẩm: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =======================
  // PRODUCT SIZES
  // =======================

  Future<List<ProductSize>> getSizes(String productId) async {
    final data = await supabase
        .from('product_sizes')
        .select()
        .eq('product_id', productId)
        .order('price', ascending: true);

    return (data as List).map((e) => ProductSize.fromJson(e)).toList();
  }

  // =======================
  // CATEGORIES
  // =======================

  Future<void> fetchCategories() async {
    try {
      final cafeId = await getCafeId();

      // ✅ Lọc category theo cafe_id
      final res = await supabase
          .from('categories')
          .select()
          .eq('cafe_id', cafeId);

      final data = List<Map<String, dynamic>>.from(res);

      categories.value = [
        {'id': '', 'name': 'Tất cả'},
        ...data,
      ];
    } catch (e) {
      Get.snackbar('Lỗi', 'Không tải được danh mục: $e');
    }
  }

  Future<void> addCategory(String name) async {
    try {
      final cafeId = await getCafeId();

      await supabase.from('categories').insert({
        'name': name,
        'cafe_id': cafeId,
      });

      await fetchCategories();
      Get.snackbar('Thành công', 'Đã thêm danh mục');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể thêm danh mục: $e');
    }
  }

  Future<void> updateCategory(String id, String name) async {
    try {
      await supabase.from('categories').update({'name': name}).eq('id', id);

      await fetchCategories();
      Get.snackbar('Thành công', 'Đã cập nhật danh mục');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật danh mục: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      final productsUsing =
      await supabase.from('products').select('id').eq('category_id', id);

      if (productsUsing.isNotEmpty) {
        Get.snackbar('Không thể xoá', 'Danh mục đang có sản phẩm');
        return;
      }

      await supabase.from('categories').delete().eq('id', id);

      await fetchCategories();
      Get.snackbar('Thành công', 'Đã xoá danh mục');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa danh mục: $e');
    }
  }

  // =======================
  // CART
  // =======================

  void addToCartWithSize({
    required Product product,
    ProductSize? size,
  }) {
    final index = cart.indexWhere(
            (e) => e.product.id == product.id && e.size?.id == size?.id);

    if (index != -1) {
      cart[index].quantity++;
      cart.refresh();
    } else {
      cart.add(CartItem(product: product, size: size, quantity: 1));
    }
  }

  void increaseQuantity(String productId) {
    final index = cart.indexWhere((e) => e.product.id == productId);
    if (index != -1) {
      cart[index].quantity++;
      cart.refresh();
    }
  }

  void decreaseQuantity(String productId) {
    final index = cart.indexWhere((e) => e.product.id == productId);
    if (index != -1) {
      if (cart[index].quantity > 1) {
        cart[index].quantity--;
      } else {
        cart.removeAt(index);
      }
      cart.refresh();
    }
  }

  void removeFromCart(String productId) {
    cart.removeWhere((item) => item.product.id == productId);
  }

  void clearCart() {
    cart.clear();
  }

  // =======================
  // PRIVATE HELPERS
  // =======================

  String _removeVietnameseTones(String str) {
    str = str.toLowerCase();

    const vietnamese = {
      'a': 'àáạảãâầấậẩẫăằắặẳẵ',
      'e': 'èéẹẻẽêềếệểễ',
      'i': 'ìíịỉĩ',
      'o': 'òóọỏõôồốộổỗơờớợởỡ',
      'u': 'ùúụủũưừứựửữ',
      'y': 'ỳýỵỷỹ',
      'd': 'đ',
    };

    vietnamese.forEach((nonAccent, accents) {
      for (var accent in accents.split('')) {
        str = str.replaceAll(accent, nonAccent);
      }
    });

    return str;
  }

  Future<String?> _uploadProductImage(File image, String productId) async {
    try {
      final filePath = 'products/product_$productId.jpg';

      await supabase.storage.from('product_images').upload(
        filePath,
        image,
        fileOptions: const FileOptions(upsert: true),
      );

      return supabase.storage.from('product_images').getPublicUrl(filePath);
    } catch (e) {
      Get.snackbar('Upload thất bại', e.toString());
      return null;
    }
  }

  Future<void> _removeProductImage(String productId) async {
    try {
      await supabase.storage
          .from('product_images')
          .remove(['products/product_$productId.jpg']);
    } catch (_) {
      // Bỏ qua nếu file không tồn tại
    }
  }
}

// =======================
// CART ITEM MODEL
// (di chuyển vào đây vì chỉ ProductController sử dụng)
// =======================

class CartItem {
  Product product;
  ProductSize? size;
  int quantity;

  CartItem({
    required this.product,
    this.size,
    required this.quantity,
  });

  double get price => size?.price ?? product.minPrice ?? 0;

  double get subtotal => price * quantity;
}