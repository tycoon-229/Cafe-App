import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CafeApprovalPage
    extends StatefulWidget {
  const CafeApprovalPage({
    super.key,
  });

  @override
  State<CafeApprovalPage>
  createState() =>
      _CafeApprovalPageState();
}

class _CafeApprovalPageState
    extends State<
        CafeApprovalPage> {
  final supabase =
      Supabase.instance.client;

  final cafes =
      <Map<String, dynamic>>[]
          .obs;

  final isLoading =
      false.obs;

  @override
  void initState() {
    super.initState();
    loadPendingCafes();
  }

  // =========================
  // LOAD CAFE
  // =========================

  Future<void>
  loadPendingCafes() async {
    try {
      isLoading.value =
      true;

      final response =
      await supabase
          .from('cafes')
          .select(
        '''
                *,
                profiles (
                  username,
                  email,
                  phone
                )
                ''',
      )
          .eq(
        'approval_status',
        'pending',
      )
          .order(
        'created_at',
        ascending:
        false,
      );

      cafes.value =
      List<
          Map<String,
              dynamic>>.from(
        response,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
      );
    } finally {
      isLoading.value =
      false;
    }
  }

  // =========================
  // APPROVE
  // =========================

  Future<void> approveCafe(
      String cafeId,
      ) async {
    try {
      await supabase
          .from('cafes')
          .update({
        'approval_status':
        'approved',
      }).eq('id', cafeId);

      cafes.removeWhere(
            (e) =>
        e['id'] ==
            cafeId,
      );

      Get.snackbar(
        'Thành công',
        'Đã duyệt quán',
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
      );
    }
  }

  // =========================
  // REJECT
  // =========================

  Future<void> rejectCafe(
      String cafeId,
      ) async {
    try {
      await supabase
          .from('cafes')
          .update({
        'approval_status':
        'rejected',
      }).eq('id', cafeId);

      cafes.removeWhere(
            (e) =>
        e['id'] ==
            cafeId,
      );

      Get.snackbar(
        'Đã từ chối',
        'Quán đã bị từ chối',
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
      );
    }
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(
        0xfff5f7fb,
      ),

      body: Padding(
        padding:
        const EdgeInsets
            .all(20),

        child: Column(
          children: [
            // HEADER
            Row(
              children: [
                const Text(
                  'Danh sách quán chờ duyệt',
                  style:
                  TextStyle(
                    fontSize:
                    24,
                    fontWeight:
                    FontWeight
                        .bold,
                  ),
                ),

                const Spacer(),

                IconButton(
                  onPressed:
                  loadPendingCafes,
                  icon:
                  const Icon(
                    Icons.refresh,
                  ),
                ),
              ],
            ),

            const SizedBox(
                height: 20),

            Expanded(
              child: Obx(
                    () {
                  if (isLoading
                      .value) {
                    return const Center(
                      child:
                      CircularProgressIndicator(),
                    );
                  }

                  if (cafes
                      .isEmpty) {
                    return const Center(
                      child:
                      Text(
                        'Không có quán chờ duyệt',
                        style:
                        TextStyle(
                          fontSize:
                          18,
                        ),
                      ),
                    );
                  }

                  return ListView
                      .builder(
                    itemCount:
                    cafes
                        .length,

                    itemBuilder:
                        (_, index) {
                      final cafe =
                      cafes[
                      index];

                      final owner =
                      cafe[
                      'profiles'];

                      return Card(
                        elevation:
                        2,

                        margin:
                        const EdgeInsets.only(
                          bottom:
                          16,
                        ),

                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                            20,
                          ),
                        ),

                        child:
                        Padding(
                          padding:
                          const EdgeInsets.all(
                            20,
                          ),

                          child:
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.storefront,
                                    size:
                                    35,
                                    color:
                                    Colors.brown,
                                  ),

                                  const SizedBox(
                                      width:
                                      12),

                                  Expanded(
                                    child:
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cafe['cafe_name'] ??
                                              '',
                                          style:
                                          const TextStyle(
                                            fontSize:
                                            20,
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                        ),

                                        Text(
                                          cafe['address'] ??
                                              '',
                                          style:
                                          const TextStyle(
                                            color:
                                            Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const Divider(
                                  height:
                                  30),

                              _info(
                                'Chủ quán',
                                owner?[
                                'username'] ??
                                    '',
                              ),

                              _info(
                                'Email',
                                owner?[
                                'email'] ??
                                    '',
                              ),

                              _info(
                                'SĐT',
                                cafe['phone'] ??
                                    '',
                              ),

                              _info(
                                'Mô tả',
                                cafe['description'] ??
                                    '',
                              ),

                              const SizedBox(
                                  height:
                                  20),

                              Row(
                                children: [
                                  Expanded(
                                    child:
                                    ElevatedButton.icon(
                                      style:
                                      ElevatedButton.styleFrom(
                                        backgroundColor:
                                        Colors.green,
                                        foregroundColor:
                                        Colors.white,
                                        minimumSize:
                                        const Size(
                                          0,
                                          50,
                                        ),
                                      ),
                                      onPressed:
                                          () {
                                        approveCafe(
                                          cafe[
                                          'id'],
                                        );
                                      },
                                      icon:
                                      const Icon(
                                        Icons.check,
                                      ),
                                      label:
                                      const Text(
                                        'Duyệt',
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                      width:
                                      12),

                                  Expanded(
                                    child:
                                    ElevatedButton.icon(
                                      style:
                                      ElevatedButton.styleFrom(
                                        backgroundColor:
                                        Colors.red,
                                        foregroundColor:
                                        Colors.white,
                                        minimumSize:
                                        const Size(
                                          0,
                                          50,
                                        ),
                                      ),
                                      onPressed:
                                          () {
                                        rejectCafe(
                                          cafe[
                                          'id'],
                                        );
                                      },
                                      icon:
                                      const Icon(
                                        Icons.close,
                                      ),
                                      label:
                                      const Text(
                                        'Từ chối',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(
      String title,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 10,
      ),

      child: RichText(
        text: TextSpan(
          style:
          const TextStyle(
            color:
            Colors.black,
            fontSize: 15,
          ),

          children: [
            TextSpan(
              text:
              '$title: ',
              style:
              const TextStyle(
                fontWeight:
                FontWeight.bold,
              ),
            ),

            TextSpan(
              text: value,
            ),
          ],
        ),
      ),
    );
  }
}