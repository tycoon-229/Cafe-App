import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';

class WaitingCafeApprovalPage
    extends StatelessWidget {
  WaitingCafeApprovalPage({
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
        child:
        SingleChildScrollView(
          padding:
          const EdgeInsets
              .all(20),

          child: ConstrainedBox(
            constraints:
            const BoxConstraints(
              maxWidth: 450,
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
                      0.05,
                    ),
                    blurRadius:
                    16,
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
                    width: 130,
                    height: 130,

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
                          .storefront_rounded,
                      size: 62,
                      color:
                      Colors.orange,
                    ),
                  ),

                  const SizedBox(
                    height: 26,
                  ),

                  /// TITLE
                  const Text(
                    "Quán cafe đang chờ duyệt",
                    textAlign:
                    TextAlign
                        .center,

                    style:
                    TextStyle(
                      fontSize:
                      24,
                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  /// DESCRIPTION
                  Text(
                    "Thông tin quán của bạn đã được gửi thành công.\n"
                        "Vui lòng chờ quản trị viên xét duyệt trước khi sử dụng hệ thống.",

                    textAlign:
                    TextAlign
                        .center,

                    style:
                    TextStyle(
                      fontSize:
                      15,
                      height:
                      1.6,
                      color: Colors
                          .grey
                          .shade700,
                    ),
                  ),

                  const SizedBox(
                    height: 26,
                  ),

                  /// STATUS BOX
                  Container(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal:
                      18,
                      vertical:
                      16,
                    ),

                    decoration:
                    BoxDecoration(
                      color:
                      Colors.orange
                          .withOpacity(
                        0.08,
                      ),

                      borderRadius:
                      BorderRadius.circular(
                        18,
                      ),
                    ),

                    child: Row(
                      children: [
                        Container(
                          width:
                          42,
                          height:
                          42,

                          decoration:
                          BoxDecoration(
                            color: Colors
                                .orange
                                .withOpacity(
                              0.15,
                            ),

                            borderRadius:
                            BorderRadius.circular(
                              14,
                            ),
                          ),

                          child:
                          const Icon(
                            Icons
                                .hourglass_top_rounded,
                            color:
                            Colors.orange,
                          ),
                        ),

                        const SizedBox(
                          width: 14,
                        ),

                        const Expanded(
                          child:
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [
                              Text(
                                "Trạng thái",
                                style:
                                TextStyle(
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),

                              SizedBox(
                                height:
                                4,
                              ),

                              Text(
                                "Đang chờ xét duyệt",
                                style:
                                TextStyle(
                                  color:
                                  Colors.orange,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 34,
                  ),

                  /// LOGOUT BUTTON
                  SizedBox(
                    width:
                    double.infinity,
                    height: 58,

                    child:
                    ElevatedButton(
                      style:
                      ElevatedButton
                          .styleFrom(
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
                          FontWeight.bold,
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