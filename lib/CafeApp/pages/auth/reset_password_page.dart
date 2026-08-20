import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../controllers/auth_controller.dart';

class ResetPasswordPage extends StatelessWidget {
  ResetPasswordPage({super.key});

  final passwordController = TextEditingController();

  final confirmController = TextEditingController();

  final auth = AuthController.to;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mật khẩu mới')),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: passwordController,

              obscureText: true,

              decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: confirmController,

              obscureText: true,

              decoration: const InputDecoration(labelText: 'Nhập lại mật khẩu'),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () async {
                if (passwordController.text != confirmController.text) {
                  Get.snackbar('Lỗi', 'Mật khẩu không khớp');
                  return;
                }

                await auth.resetPassword(passwordController.text);

                Get.offAllNamed('/login');
              },

              child: const Text('Đổi mật khẩu'),
            ),
          ],
        ),
      ),
    );
  }
}
