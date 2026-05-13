import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'order_list_page.dart';
import 'product_manage_page.dart';

class ManagementPage extends StatelessWidget {
  const ManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),

      appBar: AppBar(
        title: const Text("Quản lý"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            /// ORDER
            _MenuButton(
              title: "Quản lý đơn hàng",
              icon: Icons.receipt_long,
              color: Colors.orange,

              onTap: () {
                Get.to(() => OrderListPage());
              },
            ),

            const SizedBox(height: 16),

            /// PRODUCT
            _MenuButton(
              title: "Quản lý sản phẩm",
              icon: Icons.fastfood,
              color: Colors.green,

              onTap: () {
                Get.to(() => ProductManagePage());
              },
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////

class _MenuButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),

      onTap: onTap,

      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(22),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          children: [

            /// ICON
            Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),

              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            /// TITLE
            Expanded(
              child: Text(
                title,

                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Icon(Icons.arrow_forward_ios_rounded),
          ],
        ),
      ),
    );
  }
}