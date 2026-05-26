import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';

class WaitingCafeApprovalPage extends StatelessWidget {
  WaitingCafeApprovalPage({super.key});

  final controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(30),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.storefront_rounded,
                size: 90,
                color: Colors.brown,
              ),

              const SizedBox(height: 20),

              const Text(
                "Quán cafe đang chờ duyệt",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Thông tin quán đã được gửi.\n"
                    "Vui lòng chờ admin xét duyệt.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: controller.logout,
                  child: const Text("Đăng xuất"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}