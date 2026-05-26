import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/CafeApp/controllers/auth_controller.dart';
import 'package:project/CafeApp/pages/app_router_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
    debug: true,
  );

  // Chỉ khởi tạo AuthController khi app start.
  // OrderController, ProductController, TableController
  // sẽ được khởi tạo SAU KHI đăng nhập thành công (trong AuthController).
  Get.put(AuthController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AppRouterPage(),
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
    );
  }
}