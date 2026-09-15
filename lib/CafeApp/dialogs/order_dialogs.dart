import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/order_detail.dart';

class OrderDialogs {
  static Future<String?> showPaymentMethodSelector() {
    return Get.dialog<String>(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xffe5e5e5)),
        ),
        title: const Text(
          'Hình thức thanh toán',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: -0.3),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
              leading: const Icon(Icons.payments_outlined, color: Colors.black),
              title: const Text('Tiền mặt', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black26),
              onTap: () => Get.back(result: 'cash'),
            ),
            const Divider(color: Color(0xfff0f0f0), height: 1),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
              leading: const Icon(Icons.qr_code_2_rounded, color: Colors.black),
              title: const Text('Chuyển khoản ngân hàng', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black26),
              onTap: () => Get.back(result: 'transfer'),
            ),
          ],
        ),
      ),
    );
  }

  static Future<bool?> showCashPaymentDialog({required double totalAmount}) {
    final TextEditingController cashController = TextEditingController();
    num khachDua = 0;

    return Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          final tienThua = khachDua - totalAmount;
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xffe5e5e5)),
            ),
            title: const Text(
              'Thanh toán tiền mặt',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: -0.3),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xfffafafa),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xffe5e5e5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng hóa đơn:', style: TextStyle(fontSize: 14, color: Colors.black54)),
                      Text(
                        '${totalAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cashController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'Tiền khách đưa',
                    labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    suffixText: 'đ',
                    filled: true,
                    fillColor: const Color(0xfffafafa),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xffe5e5e5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xffe5e5e5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      khachDua = num.tryParse(value) ?? 0;
                    });
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tiền thừa trả khách:', style: TextStyle(fontSize: 14)),
                    Text(
                      '${tienThua > 0 ? tienThua.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.') : 0}đ',
                      style: TextStyle(
                        color: tienThua >= 0 ? Colors.black : Colors.black45,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
                if (tienThua < 0 && khachDua > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Số tiền nhận chưa đủ thanh toán',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ),
              ],
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Hủy', style: TextStyle(color: Colors.black54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                onPressed: tienThua >= 0 ? () => Get.back(result: true) : null,
                child: const Text('Xác nhận hoàn tất'),
              ),
            ],
          );
        },
      ),
    );
  }

  static void showOrderDetailsSheet({
    required List<OrderDetail> items,
    required VoidCallback onComplete,
  }) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Chi tiết đơn hàng",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text("Đơn hàng hiện chưa có món", style: TextStyle(color: Colors.black45)),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(color: Color(0xfff0f0f0), height: 16),
                    itemBuilder: (_, index) {
                      final item = items[index];
                      return Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xfffafafa),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xffe5e5e5)),
                            ),
                            child: Text(
                              "${item.quantity}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.sizeName,
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "${item.subtotal.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: items.isEmpty ? null : onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Hoàn tất thanh toán',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}