import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({
    super.key,
  });

  @override
  State<AuthPage> createState() =>
      _AuthPageState();
}

class _AuthPageState
    extends State<AuthPage> {
  late AuthController
  controller;

  final emailController =
  TextEditingController();

  final passwordController =
  TextEditingController();

  final confirmPasswordController =
  TextEditingController();

  bool isLogin = true;
  bool obscure = true;

  @override
  void initState() {
    super.initState();
    controller =
        Get.find<AuthController>();
  }

  bool isStrongPassword(
      String password,
      ) {
    final regex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$',
    );

    return regex.hasMatch(
      password,
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      body: Stack(
        children: [
          /// BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              'assets/images/auth_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          /// DARK OVERLAY
          Positioned.fill(
            child: Container(
              color: Colors.black
                  .withOpacity(
                .35,
              ),
            ),
          ),

          /// CONTENT
          Center(
            child:
            SingleChildScrollView(
              padding:
              const EdgeInsets
                  .all(20),

              child:
              Container(
                constraints:
                const BoxConstraints(
                  maxWidth:
                  430,
                ),

                padding:
                const EdgeInsets
                    .all(
                  28,
                ),

                decoration:
                BoxDecoration(
                  color: Colors
                      .white
                      .withOpacity(
                    .95,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    32,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors
                          .black
                          .withOpacity(
                        .15,
                      ),
                      blurRadius:
                      30,
                      offset:
                      const Offset(
                        0,
                        10,
                      ),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    /// LOGO
                    Container(
                      width:
                      110,
                      height:
                      110,

                      decoration:
                      BoxDecoration(
                        color:
                        Colors.orange
                            .withOpacity(
                          .12,
                        ),

                        shape:
                        BoxShape
                            .circle,
                      ),

                      child:
                      const Icon(
                        Icons
                            .local_cafe_rounded,
                        size:
                        55,
                        color:
                        Colors.orange,
                      ),
                    ),

                    const SizedBox(
                      height:
                      24,
                    ),

                    Text(
                      isLogin
                          ? 'Đăng nhập'
                          : 'Đăng ký',

                      style:
                      const TextStyle(
                        fontSize:
                        30,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height:
                      8,
                    ),

                    Text(
                      isLogin
                          ? 'Đăng nhập để tiếp tục'
                          : 'Tạo tài khoản mới',

                      style:
                      TextStyle(
                        color: Colors
                            .grey
                            .shade600,
                      ),
                    ),

                    const SizedBox(
                      height:
                      32,
                    ),

                    /// EMAIL
                    _buildInput(
                      controller:
                      emailController,
                      label:
                      'Email',
                      icon:
                      Icons
                          .email_outlined,
                      keyboardType:
                      TextInputType
                          .emailAddress,
                    ),

                    const SizedBox(
                      height:
                      16,
                    ),

                    /// PASSWORD
                    _buildPasswordField(
                      controller:
                      passwordController,
                      label:
                      'Mật khẩu',
                    ),

                    /// CONFIRM PASSWORD
                    if (!isLogin)
                      ...[
                        const SizedBox(
                          height:
                          16,
                        ),

                        _buildPasswordField(
                          controller:
                          confirmPasswordController,
                          label:
                          'Xác nhận mật khẩu',
                        ),
                      ],

                    const SizedBox(
                      height:
                      26,
                    ),

                    /// BUTTON
                    SizedBox(
                      width:
                      double
                          .infinity,
                      height:
                      58,

                      child:
                      Obx(
                            () =>
                            ElevatedButton(
                              style:
                              ElevatedButton.styleFrom(
                                backgroundColor:
                                Colors.orange,

                                elevation:
                                0,

                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                    20,
                                  ),
                                ),
                              ),

                              onPressed:
                              controller.isLoading.value
                                  ? null
                                  : submit,

                              child: controller
                                  .isLoading
                                  .value
                                  ? const SizedBox(
                                width:
                                24,
                                height:
                                24,
                                child:
                                CircularProgressIndicator(
                                  strokeWidth:
                                  2.5,
                                  color:
                                  Colors.white,
                                ),
                              )
                                  : Text(
                                isLogin
                                    ? 'Đăng nhập'
                                    : 'Đăng ký',

                                style:
                                const TextStyle(
                                  fontSize:
                                  16,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ),
                      ),
                    ),

                    const SizedBox(
                      height:
                      18,
                    ),

                    TextButton(
                      onPressed:
                          () {
                        setState(
                              () {
                            isLogin =
                            !isLogin;
                          },
                        );
                      },

                      child: Text(
                        isLogin
                            ? 'Chưa có tài khoản? Đăng ký'
                            : 'Đã có tài khoản? Đăng nhập',

                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.w600,
                          color:
                          Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController
    controller,
    required String label,
    required IconData icon,
    TextInputType?
    keyboardType,
  }) {
    return Container(
      decoration:
      BoxDecoration(
        color:
        const Color(
          0xfff9f9f9,
        ),

        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),

      child: TextField(
        controller:
        controller,
        keyboardType:
        keyboardType,

        decoration:
        InputDecoration(
          hintText:
          label,

          prefixIcon:
          Icon(
            icon,
            color:
            Colors.orange,
          ),

          border:
          InputBorder.none,

          contentPadding:
          const EdgeInsets.symmetric(
            horizontal:
            18,
            vertical:
            18,
          ),
        ),
      ),
    );
  }

  Widget
  _buildPasswordField({
    required TextEditingController
    controller,
    required String label,
  }) {
    return Container(
      decoration:
      BoxDecoration(
        color:
        const Color(
          0xfff9f9f9,
        ),

        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),

      child: TextField(
        controller:
        controller,
        obscureText:
        obscure,

        decoration:
        InputDecoration(
          hintText:
          label,

          prefixIcon:
          const Icon(
            Icons
                .lock_outline,
            color:
            Colors.orange,
          ),

          suffixIcon:
          IconButton(
            onPressed:
                () {
              setState(
                    () {
                  obscure =
                  !obscure;
                },
              );
            },

            icon: Icon(
              obscure
                  ? Icons
                  .visibility_off_outlined
                  : Icons
                  .visibility_outlined,
            ),
          ),

          border:
          InputBorder.none,

          contentPadding:
          const EdgeInsets.symmetric(
            horizontal:
            18,
            vertical:
            18,
          ),
        ),
      ),
    );
  }

  Future<void>
  submit() async {
    final email =
    emailController.text
        .trim();

    final password =
        passwordController.text;

    final confirmPassword =
        confirmPasswordController
            .text;

    if (email.isEmpty ||
        password.isEmpty) {
      Get.snackbar(
        'Thiếu thông tin',
        'Vui lòng nhập đầy đủ',
      );
      return;
    }

    if (!isStrongPassword(
      password,
    ) &&
        !isLogin) {
      Get.snackbar(
        'Mật khẩu không hợp lệ',
        'Ít nhất 8 ký tự,\n'
            'bao gồm chữ hoa, chữ thường và số',
      );
      return;
    }

    if (!isLogin) {
      if (password !=
          confirmPassword) {
        Get.snackbar(
          'Sai mật khẩu',
          'Mật khẩu xác nhận không khớp',
        );
        return;
      }
    }

    if (isLogin) {
      await controller.login(
        email: email,
        password:
        password,
      );
    } else {
      await controller.register(
        email: email,
        password:
        password,
      );
    }
  }
}