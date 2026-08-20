import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../controllers/auth_controller.dart';
import 'forgot_password_otp_page.dart';

class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({super.key});

  final emailController = TextEditingController();

  final auth = AuthController.to;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quên mật khẩu')),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: emailController,

              decoration: const InputDecoration(labelText: 'Email'),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () async {
                await auth.sendResetPasswordOtp(emailController.text);

                Get.to(
                  () => ForgotPasswordOtpPage(email: emailController.text),
                );
              },

              child: const Text('Gửi OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
