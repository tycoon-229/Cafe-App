import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CafeRegistrationPage extends StatelessWidget {
  CafeRegistrationPage({super.key});

  final supabase = Supabase.instance.client;

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final descriptionController = TextEditingController();

  Future<void> registerCafe() async {
    final user = supabase.auth.currentUser;

    await supabase.from('cafes').insert({
      'owner_id': user!.id,
      'cafe_name': nameController.text.trim(),
      'address': addressController.text.trim(),
      'phone': phoneController.text.trim(),
      'description': descriptionController.text.trim(),
    });

    Get.offAllNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Đăng ký quán cafe",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Tên quán",
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: "Địa chỉ",
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: "Số điện thoại",
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Mô tả quán",
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: registerCafe,
                    child: const Text("Gửi đăng ký"),
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