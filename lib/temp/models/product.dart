import 'package:project/temp/models/product_size.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_helper.dart';

class Product {
  String id;
  String name;
  String? description, imageUrl;
  String? categoryId;
  bool isAvailable;
  DateTime? createdAt;
  double? minPrice;

  Product({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.categoryId,
    this.isAvailable = true,
    this.createdAt,
    this.minPrice
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'],
      imageUrl: json['image_url'],
      categoryId: json['category_id']?.toString(),
      isAvailable: json['is_available'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      minPrice: json['min_price'] != null
          ? double.tryParse(json['min_price'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "image_url": imageUrl,
      "category_id": categoryId,
      "is_available": isAvailable,
      "created_at": createdAt?.toIso8601String(),
      "minPrice": minPrice,
    };
  }
}

class ProductSnapshot {
  Product product;

  ProductSnapshot(this.product);

  /// GET SIZE
  static Future<List<ProductSize>> getSizes(String productId) async {
    final supabase = Supabase.instance.client;

    final data = await supabase
        .from("product_sizes")
        .select()
        .eq("product_id", productId)
        .order("price", ascending: true);

    return (data as List)
        .map((e) => ProductSize.fromJson(e))
        .toList();
  }

  static Future<List<Product>> getProductsWithMinPrice() async {
    final supabase = Supabase.instance.client;

    final productData = await supabase.from('products').select();

    List<Product> products =
    (productData as List).map((e) => Product.fromJson(e)).toList();

    /// load size nhỏ nhất cho từng product
    for (var p in products) {
      final size = await supabase
          .from('product_sizes')
          .select('price')
          .eq('product_id', p.id)
          .order('price', ascending: true)
          .limit(1)
          .maybeSingle();

      if (size != null) {
        p.minPrice =
            double.tryParse(size['price'].toString()) ?? 0;
      }
    }

    return products;
  }

  /// UPDATE
  static Future<dynamic> update(Product newProduct) async {
    final supabase = Supabase.instance.client;

    var data = await supabase
        .from("products")
        .update(newProduct.toJson())
        .eq("id", newProduct.id)
        .select();

    return data;
  }

  /// DELETE
  static Future<void> delete(String productId) async {
    final supabase = Supabase.instance.client;

    await supabase.from("products").delete().eq("id", productId);

    await removeImage(
      bucket: "product-images",
      path: "products/product_$productId.jpg",
    );
  }

  /// INSERT
  static Future<dynamic> insert(Product newProduct) async {
    final supabase = Supabase.instance.client;

    var data = await supabase.from('products').insert(
      newProduct.toJson(),
    ).select();

    return data;
  }

  /// GET LIST
  static Future<List<Product>> getProducts() async {
    final supabase = Supabase.instance.client;

    var data = await supabase.from("products").select();

    return (data as List).map((e) => Product.fromJson(e)).toList();
  }

  /// REALTIME STREAM
  static Stream<List<Product>> getProductStream() {
    final supabase = Supabase.instance.client;

    return supabase
        .from('products_with_min_price')
        .stream(primaryKey: ['id'])
        .map((data) => data
        .map((e) => Product.fromJson(e))
        .toList());
  }

  /// MAP DATA
  static Future<Map<String, Product>> getMapProducts() async {
    return getMapData(
      table: "products",
      fromJson: Product.fromJson,
      getId: (t) => t.id,
    );
  }

  /// LISTEN REALTIME CHANGE
  static listenProductChange(
      Map<String, Product> maps, {
        Function()? updateUI,
      }) async {
    return listenDatachange(
      maps,
      channel: "products:public",
      schema: "public",
      table: "products",
      fromJson: Product.fromJson,
      getId: (t) => t.id,
      updateUI: updateUI,
    );
  }
}