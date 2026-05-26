import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() =>
      _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late AuthController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AuthController>();
  }

  final emailController =
  TextEditingController();

  final passwordController =
  TextEditingController();

  bool isLogin = true;
  bool obscure = true;

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
              children: [
                const Icon(
                  Icons.local_cafe,
                  size: 70,
                  color: Colors.brown,
                ),

                const SizedBox(height: 16),

                Text(
                  isLogin
                      ? 'Đăng nhập'
                      : 'Đăng ký',
                  style:
                  const TextStyle(
                    fontSize: 28,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  isLogin
                      ? 'Đăng nhập tài khoản'
                      : 'Tạo tài khoản mới',
                  style: TextStyle(
                    color:
                    Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 32),

                TextField(
                  controller:
                  emailController,
                  keyboardType:
                  TextInputType
                      .emailAddress,

                  decoration:
                  InputDecoration(
                    labelText: 'Email',
                    prefixIcon:
                    const Icon(
                      Icons.email,
                    ),
                    border:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller:
                  passwordController,
                  obscureText: obscure,

                  decoration:
                  InputDecoration(
                    labelText:
                    'Password',
                    prefixIcon:
                    const Icon(
                      Icons.lock,
                    ),

                    suffixIcon:
                    IconButton(
                      onPressed: () {
                        setState(() {
                          obscure =
                          !obscure;
                        });
                      },
                      icon: Icon(
                        obscure
                            ? Icons
                            .visibility_off
                            : Icons
                            .visibility,
                      ),
                    ),

                    border:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(
                        14,
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
                          : submit,

                      child: controller
                          .isLoading
                          .value
                          ? const CircularProgressIndicator()
                          : Text(
                        isLogin
                            ? 'Đăng nhập'
                            : 'Đăng ký',
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin =
                      !isLogin;
                    });
                  },
                  child: Text(
                    isLogin
                        ? 'Chưa có tài khoản? Đăng ký'
                        : 'Đã có tài khoản? Đăng nhập',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> submit() async {
    final email =
    emailController.text.trim();

    final password =
        passwordController.text;

    if (email.isEmpty ||
        password.isEmpty) {
      Get.snackbar(
        'Thiếu thông tin',
        'Vui lòng nhập đầy đủ',
      );
      return;
    }

    if (password.length < 6) {
      Get.snackbar(
        'Password yếu',
        'Tối thiểu 6 ký tự',
      );
      return;
    }

    if (isLogin) {
      await controller.login(
        email: email,
        password: password,
      );
    } else {
      await controller.register(
        email: email,
        password: password,
      );
    }
  }
}