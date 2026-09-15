import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import 'forgot_password_page.dart';

class AuthPage extends GetView<AuthController> {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Minimal Brand Icon
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.coffee_rounded,
                        size: 32,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Header
                  Obx(
                        () => Text(
                      controller.isLogin.value ? 'Đăng nhập' : 'Tạo tài khoản',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                        () => Text(
                      controller.isLogin.value
                          ? 'Nhập thông tin xác thực để tiếp tục'
                          : 'Đăng ký thông tin để trải nghiệm dịch vụ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Email
                  _buildInput(
                    textController: controller.emailController,
                    label: 'Email',
                    icon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  _buildPasswordField(
                    textController: controller.passwordController,
                    label: 'Mật khẩu',
                  ),

                  // Confirm Password
                  Obx(
                        () => !controller.isLogin.value
                        ? Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildPasswordField(
                          textController:
                          controller.confirmPasswordController,
                          label: 'Xác nhận mật khẩu',
                        ),
                      ],
                    )
                        : const SizedBox.shrink(),
                  ),

                  // Forgot Password Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () => Get.to(() => ForgotPasswordPage()),
                      child: Text(
                        'Quên mật khẩu?',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    height: 52,
                    child: Obx(
                          () => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.submitAuth,
                        child: controller.isLoading.value
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Text(
                          controller.isLogin.value
                              ? 'Đăng nhập'
                              : 'Đăng ký',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Toggle Login/Register
                  TextButton(
                    onPressed: () => controller.isLogin.toggle(),
                    child: Obx(
                          () => RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          children: [
                            TextSpan(
                              text: controller.isLogin.value
                                  ? 'Chưa có tài khoản? '
                                  : 'Đã có tài khoản? ',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            TextSpan(
                              text: controller.isLogin.value
                                  ? 'Đăng ký ngay'
                                  : 'Đăng nhập',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController textController,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xfffcfcfc),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe5e5e5)),
      ),
      child: TextField(
        controller: textController,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.black54, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController textController,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xfffcfcfc),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe5e5e5)),
      ),
      child: Obx(
            () => TextField(
          controller: textController,
          obscureText: controller.obscure.value,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.black54, size: 20),
            suffixIcon: IconButton(
              onPressed: () => controller.obscure.toggle(),
              icon: Icon(
                controller.obscure.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.black45,
                size: 20,
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ),
    );
  }
}