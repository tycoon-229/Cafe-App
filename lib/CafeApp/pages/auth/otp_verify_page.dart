import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../controllers/auth_controller.dart';

class OtpVerifyPage extends StatefulWidget {
  final String email;
  final String password;

  const OtpVerifyPage({super.key, required this.email, required this.password});

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  final controller = AuthController.to;

  final otpController = TextEditingController();

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      Get.snackbar('Thiếu mã OTP', 'Vui lòng nhập mã OTP');
      return;
    }

    if (otp.length != 6) {
      Get.snackbar('OTP không hợp lệ', 'OTP gồm đúng 6 ký tự');
      return;
    }

    await controller.verifyOtp(
      email: widget.email,
      password: widget.password,
      token: otp,
    );
  }

  Future<void> resendOtp() async {
    try {
      await controller.supabase.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );

      Get.snackbar(
        'Đã gửi lại',
        'OTP mới đã gửi tới email',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),

            child: Container(
              padding: const EdgeInsets.all(28),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(28),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.06),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),

              child: Column(
                children: [
                  /// ICON
                  Container(
                    width: 120,
                    height: 120,

                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),

                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.mark_email_read_rounded,
                      size: 58,
                      color: Colors.orange,
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// TITLE
                  const Text(
                    'Xác thực OTP',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  /// SUBTITLE
                  Text(
                    'Nhập mã OTP đã gửi đến\n${widget.email}',

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// OTP FIELD
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xfff9f9f9),

                      borderRadius: BorderRadius.circular(22),
                    ),

                    child: TextField(
                      controller: otpController,

                      keyboardType: TextInputType.number,

                      textAlign: TextAlign.center,

                      maxLength: 6,

                      style: const TextStyle(
                        letterSpacing: 10,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),

                      decoration: const InputDecoration(
                        counterText: '',

                        hintText: '000000',

                        border: InputBorder.none,

                        contentPadding: EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// VERIFY BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 58,

                    child: Obx(
                      () => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,

                          elevation: 0,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),

                        onPressed: controller.isLoading.value
                            ? null
                            : verifyOtp,

                        child: controller.isLoading.value
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Xác thực',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// RESEND
                  TextButton(
                    onPressed: resendOtp,

                    child: const Text(
                      'Gửi lại OTP',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
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
}
