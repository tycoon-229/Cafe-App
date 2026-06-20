import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:project/CafeApp/pages/auth/reset_password_page.dart';

import '../../controllers/auth_controller.dart';

class ForgotPasswordOtpPage
    extends StatelessWidget {
  final String email;

  ForgotPasswordOtpPage({
    super.key,
    required this.email,
  });

  final otpController =
  TextEditingController();

  final auth = AuthController.to;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text('Xác thực OTP'),
      ),

      body: Padding(
        padding:
        const EdgeInsets.all(20),

        child: Column(
          children: [
            Text(
              'Nhập mã OTP được gửi tới $email',
            ),

            const SizedBox(
              height: 20,
            ),

            TextField(
              controller:
              otpController,

              keyboardType:
              TextInputType.number,

              decoration:
              const InputDecoration(
                labelText: 'OTP',
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            ElevatedButton(
              onPressed: () async {
                final success =
                await auth
                    .verifyResetPasswordOtp(
                  email: email,
                  otp:
                  otpController.text,
                );

                if (success) {
                  Get.off(
                        () =>  ResetPasswordPage(),
                  );
                }
              },

              child: const Text(
                'Xác nhận',
              ),
            ),
          ],
        ),
      ),
    );
  }
}