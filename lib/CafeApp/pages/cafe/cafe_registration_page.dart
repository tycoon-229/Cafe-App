import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CafeRegistrationPage extends StatelessWidget {
  CafeRegistrationPage({super.key});

  final supabase = Supabase.instance.client;
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final descriptionController = TextEditingController();

  final isLoading = false.obs;

  Future<void> registerCafe() async {
    try {
      isLoading.value = true;
      final user = supabase.auth.currentUser;

      await supabase.from('cafes').insert({
        'owner_id': user!.id,
        'cafe_name': nameController.text.trim(),
        'address': addressController.text.trim(),
        'phone': phoneController.text.trim(),
        'description': descriptionController.text.trim(),
      });

      Get.snackbar(
        'Thành công',
        'Đăng ký quán cafe thành công',
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );

      Get.offAllNamed('/');
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Đăng ký quán cafe",
          style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Minimal Icon Brand
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.storefront_outlined,
                        size: 38,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Thông tin quán cafe",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Điền thông tin chi tiết để hoàn tất tạo quán trên hệ thống",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 36),

                  // TÊN QUÁN
                  _buildInput(
                    controller: nameController,
                    label: "Tên quán",
                    icon: Icons.store_outlined,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return "Vui lòng nhập tên quán";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ĐỊA CHỈ
                  _buildInput(
                    controller: addressController,
                    label: "Địa chỉ",
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 16),

                  // SỐ ĐIỆN THOẠI
                  _buildInput(
                    controller: phoneController,
                    label: "Số điện thoại liên hệ",
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // MÔ TẢ
                  _buildInput(
                    controller: descriptionController,
                    label: "Mô tả quán",
                    icon: Icons.description_outlined,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),

                  // SUBMIT BUTTON
                  Obx(() {
                    return SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isLoading.value
                            ? null
                            : () {
                          if (!formKey.currentState!.validate()) return;
                          registerCafe();
                        },
                        child: isLoading.value
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          "Gửi đăng ký",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xfffafafa),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe5e5e5)),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.black54, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}