import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/temp/pages/auth_page.dart';
import 'package:project/temp/pages/table_page.dart';
import 'package:project/temp/pages/user_info_page.dart';
import 'package:project/temp/pages/waiting_account_approval_page.dart';
import 'package:project/temp/pages/waiting_cafe_approval_page.dart';

import '../controllers/auth_controller.dart';
import 'cafe_registration_page.dart';

class AppRouterPage extends StatelessWidget {
  const AppRouterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return FutureBuilder<AppFlow>(
      future: controller.checkFlow(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        switch (snapshot.data!) {
          case AppFlow.login:
            return AuthPage();

          case AppFlow.fillProfile:
            return UserInfoPage();

          case AppFlow.waitAccountApproval:
            return WaitingAccountApprovalPage();

          case AppFlow.registerCafe:
            return CafeRegistrationPage();

          case AppFlow.waitCafeApproval:
            return WaitingCafeApprovalPage();

          case AppFlow.home:
            return TablePage();
        }
      },
    );
  }
}