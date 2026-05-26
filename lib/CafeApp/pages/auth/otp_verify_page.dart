import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../controllers/auth_controller.dart';

class OtpVerifyPage extends StatefulWidget {
  final String email;
  final String password;

  const OtpVerifyPage({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<OtpVerifyPage> createState() =>
      _OtpVerifyPageState();
}

class _OtpVerifyPageState
    extends State<OtpVerifyPage> {
  final controller = AuthController.to;

  final otpController =
  TextEditingController();

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> verifyOtp() async {
    final otp =
    otpController.text.trim();

    if (otp.isEmpty) {
      Get.snackbar(
        'Thiếu mã OTP',
        'Vui lòng nhập mã OTP',
      );
      return;
    }

    if (otp.length < 6) {
      Get.snackbar(
        'OTP không hợp lệ',
        'OTP gồm 6 ký tự',
      );
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
      await controller.supabase.auth
          .resend(
        type: OtpType.signup,
        email: widget.email,
      );

      Get.snackbar(
        'Đã gửi lại',
        'OTP mới đã gửi tới email',
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xfff5f5f5),

      body: Center(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.all(24),

          child: Container(
            constraints:
            const BoxConstraints(
              maxWidth: 420,
            ),

            padding:
            const EdgeInsets.all(24),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(
                24,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(.08),
                  blurRadius: 20,
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.mark_email_read,
                  size: 80,
                  color: Colors.brown,
                ),

                const SizedBox(height: 20),

                const Text(
                  'Xác thực OTP',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Nhập mã OTP đã gửi đến\n${widget.email}',
                  textAlign:
                  TextAlign.center,
                  style: TextStyle(
                    color:
                    Colors.grey[600],
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 32),

                TextField(
                  controller:
                  otpController,
                  keyboardType:
                  TextInputType
                      .number,

                  textAlign:
                  TextAlign.center,

                  style:
                  const TextStyle(
                    letterSpacing: 8,
                    fontSize: 24,
                    fontWeight:
                    FontWeight.bold,
                  ),

                  decoration:
                  InputDecoration(
                    hintText:
                    '000000',
                    border:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width:
                  double.infinity,
                  height: 52,

                  child: Obx(
                        () => ElevatedButton(
                      onPressed: controller
                          .isLoading
                          .value
                          ? null
                          : verifyOtp,

                      child: controller
                          .isLoading
                          .value
                          ? const CircularProgressIndicator()
                          : const Text(
                        'Xác thực',
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed:
                  resendOtp,
                  child: const Text(
                    'Gửi lại OTP',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}