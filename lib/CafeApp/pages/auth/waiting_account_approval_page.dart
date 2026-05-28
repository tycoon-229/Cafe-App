import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';

class WaitingAccountApprovalPage
    extends StatelessWidget {
  WaitingAccountApprovalPage({
    super.key,
  });

  final controller =
  Get.find<AuthController>();

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      const Color(
        0xfff5f5f5,
      ),

      body: Center(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets
              .all(20),

          child:
          ConstrainedBox(
            constraints:
            const BoxConstraints(
              maxWidth: 430,
            ),

            child: Container(
              padding:
              const EdgeInsets
                  .all(28),

              decoration:
              BoxDecoration(
                color:
                Colors.white,

                borderRadius:
                BorderRadius
                    .circular(
                  28,
                ),

                boxShadow: [
                  BoxShadow(
                    color: Colors
                        .black
                        .withOpacity(
                      .06,
                    ),
                    blurRadius:
                    20,
                    offset:
                    const Offset(
                      0,
                      6,
                    ),
                  ),
                ],
              ),

              child: Column(
                mainAxisSize:
                MainAxisSize.min,

                children: [
                  /// ICON
                  Container(
                    width: 120,
                    height: 120,

                    decoration:
                    BoxDecoration(
                      color: Colors
                          .orange
                          .withOpacity(
                        0.12,
                      ),

                      shape:
                      BoxShape
                          .circle,
                    ),

                    child:
                    const Icon(
                      Icons
                          .hourglass_top_rounded,
                      size: 58,
                      color:
                      Colors.orange,
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  /// TITLE
                  const Text(
                    "Tài khoản đang chờ duyệt",

                    textAlign:
                    TextAlign
                        .center,

                    style:
                    TextStyle(
                      fontSize:
                      28,
                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  /// SUBTITLE
                  Text(
                    "Tài khoản của bạn đã được xác thực OTP.\n"
                        "Vui lòng chờ admin xét duyệt trước khi sử dụng hệ thống.",

                    textAlign:
                    TextAlign
                        .center,

                    style:
                    TextStyle(
                      color: Colors
                          .grey
                          .shade600,

                      fontSize:
                      15,

                      height:
                      1.5,
                    ),
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  /// STATUS BOX
                  Container(
                    width:
                    double.infinity,

                    padding:
                    const EdgeInsets
                        .all(16),

                    decoration:
                    BoxDecoration(
                      color:
                      Colors
                          .orange
                          .withOpacity(
                        .08,
                      ),

                      borderRadius:
                      BorderRadius.circular(
                        18,
                      ),
                    ),

                    child: Row(
                      children: [
                        const Icon(
                          Icons
                              .info_outline_rounded,
                          color:
                          Colors.orange,
                        ),

                        const SizedBox(
                          width:
                          12,
                        ),

                        Expanded(
                          child:
                          Text(
                            "Thông báo sẽ được cập nhật sau khi tài khoản được phê duyệt.",

                            style:
                            TextStyle(
                              color: Colors
                                  .grey
                                  .shade700,
                              fontSize:
                              14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  /// LOGOUT BUTTON
                  SizedBox(
                    width:
                    double.infinity,
                    height:
                    58,

                    child:
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
                      controller
                          .logout,

                      child:
                      const Text(
                        "Đăng xuất",

                        style:
                        TextStyle(
                          fontSize:
                          16,
                          fontWeight:
                          FontWeight
                              .bold,
                        ),
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