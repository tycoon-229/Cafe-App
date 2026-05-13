import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/temp/controllers/order_controller.dart';
import 'package:project/temp/controllers/product_controller.dart';
import 'package:project/temp/controllers/table_controller.dart';
import 'package:project/temp/pages/table_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
    debug: true,
  );

  Get.put(OrderController());
  Get.put(ProductController());
  Get.put(TableController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      home: TablePage(),
      
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
    );
  }
}