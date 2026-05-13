import 'package:flutter/material.dart';
import 'package:project/temp/pages/table_page.dart';

import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController authController = AuthController();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  bool isLogin = true;
  bool loading = false;

  void handleAuth() async {
    setState(() {
      loading = true;
    });

    if (isLogin) {
      await authController.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),

        onSuccess: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => TablePage(),
            ),
          );
        },

        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        },
      );
    } else {
      await authController.register(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        username: usernameController.text.trim(),

        onSuccess: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        },

        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        },
      );
    }

    setState(() {
      loading = false;
    });
  }

  Widget buildInput({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white12,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            children: [
              const Icon(
                Icons.lock,
                size: 80,
                color: Colors.green,
              ),

              const SizedBox(height: 20),

              Text(
                isLogin ? "Đăng nhập" : "Đăng ký",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              if (!isLogin)
                buildInput(
                  controller: usernameController,
                  hint: "Username",
                ),

              if (!isLogin)
                const SizedBox(height: 16),

              buildInput(
                controller: emailController,
                hint: "Email",
              ),

              const SizedBox(height: 16),

              buildInput(
                controller: passwordController,
                hint: "Password",
                obscure: true,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed: loading ? null : handleAuth,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),

                  child: loading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : Text(
                    isLogin ? "Đăng nhập" : "Đăng ký",
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;
                  });
                },

                child: Text(
                  isLogin
                      ? "Chưa có tài khoản? Đăng ký"
                      : "Đã có tài khoản? Đăng nhập",
                  style: const TextStyle(
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}