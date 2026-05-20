import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class WaitingAccountApprovalPage extends StatelessWidget {
  WaitingAccountApprovalPage({super.key});

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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.hourglass_top_rounded,
                size: 90,
                color: Colors.orange,
              ),

              const SizedBox(height: 20),

              const Text(
                "Tài khoản đang chờ duyệt",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Tài khoản của bạn đã được xác thực OTP.\n"
                    "Vui lòng chờ admin duyệt trước khi sử dụng hệ thống.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
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