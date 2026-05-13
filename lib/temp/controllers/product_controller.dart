import 'dart:async';
import 'package:get/get.dart';
import '../models/product.dart';
import '../models/product_size.dart';
import '../models/supabase_helper.dart';

class ProductController extends GetxController {
  /// ================= STATE =================
  final products = <Product>[].obs;
  final cart = <CartItem>[].obs;
  final categories = <Map<String, dynamic>>[].obs;
  final selectedCategoryId = ''.obs;

  static ProductController get to => Get.find();

  /// ================= SEARCH =================
  final searchText = ''.obs;

  /// ================= GETTERS =================

  int get totalItems => cart.length;

  int get totalQuantity =>
      cart.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => cart.fold(
    0,
        (sum, item) => sum + (item.price * item.quantity),
  );

  String removeVietnameseTones(String str) {
    str = str.toLowerCase();

    const vietnamese = {
      'a': 'àáạảãâầấậẩẫăằắặẳẵ',
      'e': 'èéẹẻẽêềếệểễ',
      'i': 'ìíịỉĩ',
      'o': 'òóọỏõôồốộổỗơờớợởỡ',
      'u': 'ùúụủũưừứựửữ',
      'y': 'ỳýỵỷỹ',
      'd': 'đ'
    };

    vietnamese.forEach((nonAccent, accents) {
      for (var accent in accents.split('')) {
        str = str.replaceAll(accent, nonAccent);
      }
    });

    return str;
  }

  /// FILTER (search)
  List<Product> get filteredProducts {
    final keyword = removeVietnameseTones(searchText.value);

    return products.where((p) {
      final name = removeVietnameseTones(p.name);

      final matchSearch = name.contains(keyword);

      final matchCategory =
          selectedCategoryId.value.isEmpty ||
              p.categoryId.toString() == selectedCategoryId.value;

      return matchSearch && matchCategory;
    }).toList();
  }

  Future<void> fetchCategories() async {
    try {
      final res = await supabase.from('categories').select();

      print("CATEGORIES RAW: $res");

      final data = List<Map<String, dynamic>>.from(res);

      categories.value = [
        {'id': '', 'name': 'Tất cả'},
        ...data,
      ];

      print("CATEGORIES FINAL: ${categories.length}");
    } catch (e) {
      print("ERROR categories: $e");
    }
  }

  /// ================= STREAM =================
  StreamSubscription? _sub;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
    fetchCategories();
  }

  Future<void> loadProducts() async {
    final data =
    await ProductSnapshot.getProductsWithMinPrice();

    products.assignAll(data);
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  /// ================= CART =================

  /// ADD
  void addToCartWithSize({
    required Product product,
    ProductSize? size,
  }) {
    final index = cart.indexWhere((e) =>
    e.product.id == product.id &&
        e.size?.id == size?.id);

    if (index != -1) {
      cart[index].quantity++;
      cart.refresh();
    } else {
      cart.add(CartItem(
        product: product,
        size: size,
        quantity: 1,
      ));
    }
  }

  /// INCREASE
  void increaseQuantity(String productId) {
    final index = cart.indexWhere((e) => e.product.id == productId);

    if (index != -1) {
      cart[index].quantity++;
      cart.refresh();
    }
  }

  /// DECREASE
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

  /// REMOVE
  void removeFromCart(String productId) {
    cart.removeWhere((item) => item.product.id == productId);
  }

  /// CLEAR
  void clearCart() {
    cart.clear();
  }
}

class CartItem {
  Product product;
  ProductSize? size;
  int quantity;

  CartItem({
    required this.product,
    this.size,
    required this.quantity,
  });

  double get price =>
      size?.price ?? product.minPrice ?? 0;

  double get subtotal => price * quantity;
}