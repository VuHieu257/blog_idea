import 'package:blog_idea_app/screens/layout/bottom/bottom_navigation_bar.dart';
import 'package:blog_idea_app/service/database/database_like_service.dart';
import 'package:blog_idea_app/service/database/database_service.dart';
import 'package:blog_idea_app/service/database/database_user_service.dart';
import 'package:blog_idea_app/service/get_x/get_x.dart';
import 'package:blog_idea_app/style/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ExpriceScreen extends StatefulWidget {
  const ExpriceScreen({super.key});

  @override
  State<ExpriceScreen> createState() => _ExpriceScreenState();
}

class _ExpriceScreenState extends State<ExpriceScreen> {
  final UserDataController userDataController = Get.put(UserDataController());

  final user = FirebaseAuth.instance.currentUser;
  final DatabaseService _databaseService = DatabaseService();
  final DatabaseUserService _databaseUserService = DatabaseUserService();
  final DatabaseLikeService _databaseLikeService = DatabaseLikeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _messagesListView(),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      leading: InkWell(
        onTap: () {
          Get.offAll(const BottomNavigationBarWidget());
        },
        child: const Icon(Icons.arrow_back),
      ),
      backgroundColor: Colors.white,
      title: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Center(
          child: Text(
            "Expired articles",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            // textDirection: TextDirection.ltr,
          ),
        ),
      ),
      actions: const [
        Icon(
          Icons.wallet,
          color: Colors.white,
        )
      ],
    );
  }

  Widget _messagesListView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          StreamBuilder(
            stream: _databaseService.getTodos(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              var docs = snapshot.data?.docs;
              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                // scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: docs?.length,
                itemBuilder: (context, index) {
                  var doc = docs?[index];
                  String docId = doc!.id;
                  DateTime pastDate = doc['date'].toDate();
                  DateTime now = DateTime.now();
                  Duration difference = now.difference(pastDate);
                  int daysPassed = difference.inDays;
                  int hoursPassed = difference.inHours;
                  int minutesPassed = difference.inMinutes;
                  return Column(
                    children: [
                      Container(
                        width: context.width,
                        color: Colors.white,
                        child: doc["datePostsFor"] <= daysPassed
                            ? Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: Row(
                                      children: [
                                        StreamBuilder(
                                          stream: _databaseUserService.getFind(
                                              'displayName', doc['name']),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              // Nếu đang chờ dữ liệu
                                              return const CircularProgressIndicator();
                                            } else if (snapshot.hasError) {
                                              // Nếu có lỗi xảy ra
                                              return Text(
                                                  'Error: ${snapshot.error}');
                                            } else if (!snapshot.hasData ||
                                                snapshot.data!.docs.isEmpty) {
                                              // Nếu không có dữ liệu hoặc không có bản ghi nào tương ứng với idPost
                                              return const CircleAvatar(
                                                radius: 20,
                                                backgroundImage: AssetImage(
                                                    "assets/images/avatar.png"),
                                              );
                                            } else {
                                              // Nếu có dữ liệu
                                              final userData =
                                                  snapshot.data!.docs.first;
                                              return doc['name'] ==
                                                      userData['displayName']
                                                  ? userData['img'] != ''
                                                      ? CircleAvatar(
                                                          radius: 20,
                                                          backgroundImage:
                                                              NetworkImage(
                                                                  userData[
                                                                      'img']))
                                                      : const CircleAvatar(
                                                          radius: 20,
                                                          backgroundImage:
                                                              AssetImage(
                                                                  "assets/images/avatar.png"),
                                                        )
                                                  : const CircleAvatar(
                                                      radius: 20,
                                                      backgroundImage: AssetImage(
                                                          "assets/images/avatar.png"),
                                                    );
                                            }
                                          },
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    "${doc['name']} ",
                                                    style: const TextStyle(
                                                      color: Styles.blackText,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  Text(
                                                    "*Date:${DateFormat("MM-dd-yyyy").format(doc["date"].toDate())} deadline:${doc["datePostsFor"]}*",
                                                    style: const TextStyle(
                                                      color: Styles.grey,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    minutesPassed > 60
                                                        ? hoursPassed > 24
                                                            ? "$daysPassed day ago"
                                                            : "$hoursPassed hours ago"
                                                        : "$minutesPassed minutes ago",
                                                    style: const TextStyle(
                                                      color: Styles
                                                          .deactivatedText,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  const Icon(
                                                    Icons.language,
                                                    size: 20,
                                                    color:
                                                        Styles.deactivatedText,
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        StreamBuilder(
                                            stream: FirebaseFirestore.instance
                                                .collection("db_user")
                                                .where("email",
                                                    isEqualTo: "${user!.email}")
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                // Nếu đang chờ dữ liệu
                                                return const CircularProgressIndicator();
                                              } else if (snapshot.hasError) {
                                                // Nếu có lỗi xảy ra
                                                return Text(
                                                    'Error: ${snapshot.error}');
                                              } else if (!snapshot.hasData ||
                                                  snapshot.data!.docs.isEmpty) {
                                                // Nếu không có dữ liệu hoặc không có bản ghi nào tương ứng với idPost
                                                return const Text(
                                                    'Không có dữ liệu');
                                              } else {
                                                // Nếu có dữ liệu
                                                final docUser =
                                                    snapshot.data!.docs.first;
                                                userDataController
                                                    .updateUserData(
                                                        docUser.id,
                                                        docUser["displayName"],
                                                        docUser["password"],
                                                        "${user!.email}",
                                                        docUser['role']);
                                                return Visibility(
                                                  visible:
                                                      docUser['role'] != 'user',
                                                  child: const Icon(
                                                    Icons.more_horiz,
                                                    size: 30,
                                                    color:
                                                        Styles.deactivatedText,
                                                  ),
                                                );
                                              }
                                            }),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 14),
                                        child: Text(
                                          doc["description"],
                                          style: const TextStyle(
                                            color: Styles.blackText,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: doc['imgPost'] != "",
                                        child: Image(
                                            image:
                                                NetworkImage(doc['imgPost'])),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 5),
                                        child: Visibility(
                                            visible: doc["numberOfLike"] != 0,
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.favorite,
                                                  color: Colors.red,
                                                  size: 20,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  "${doc["numberOfLike"]}",
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ],
                                            )),
                                      ),
                                      Container(
                                        height: 0.5,
                                        color: Styles.deactivatedText,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: Row(
                                          children: [
                                            const SizedBox(
                                              width: 30,
                                            ),
                                            StreamBuilder(
                                              stream:
                                                  _databaseLikeService.getFind(
                                                      'idUser',
                                                      "${userDataController.id}"),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  // Nếu đang chờ dữ liệu
                                                  return const CircularProgressIndicator();
                                                } else if (snapshot.hasError) {
                                                  return Text(
                                                      'Error: ${snapshot.error}');
                                                } else if (!snapshot.hasData ||
                                                    snapshot
                                                        .data!.docs.isEmpty) {
                                                  // Nếu không có dữ liệu hoặc không có bản ghi nào tương ứng với idPost
                                                  return Visibility(
                                                    visible: true,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(
                                                          Icons.favorite_border,
                                                          color: Styles
                                                              .deactivatedText,
                                                          size: 25,
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          "${doc["numberOfLike"]}",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 16),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                } else {
                                                  // Nếu có dữ liệu
                                                  final docLike =
                                                      snapshot.data!.docs.first;
                                                  return StreamBuilder(
                                                    stream: _databaseLikeService
                                                        .getFind(
                                                            'idPost', docId),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        // Nếu đang chờ dữ liệu
                                                        return const CircularProgressIndicator();
                                                      } else if (snapshot
                                                          .hasError) {
                                                        // Nếu có lỗi xảy ra
                                                        return Text(
                                                            'Error: ${snapshot.error}');
                                                      } else if (!snapshot
                                                              .hasData ||
                                                          snapshot.data!.docs
                                                              .isEmpty) {
                                                        // Nếu không có dữ liệu hoặc không có bản ghi nào tương ứng với idPost
                                                        return Visibility(
                                                          visible: true,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .favorite_border,
                                                                color: Styles
                                                                    .deactivatedText,
                                                                size: 25,
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                "${doc["numberOfLike"]}",
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            16),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      } else {
                                                        // Nếu có dữ liệu
                                                        final docLike = snapshot
                                                            .data!.docs.first;
                                                        return docLike['isLike']
                                                            ? Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  const Icon(
                                                                    Icons
                                                                        .favorite,
                                                                    color: Colors
                                                                        .red,
                                                                    size: 25,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  Text(
                                                                    "${doc["numberOfLike"]}",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                ],
                                                              )
                                                            : const Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .favorite_border,
                                                                    color: Styles
                                                                        .deactivatedText,
                                                                    size: 25,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  Text(
                                                                    "Like",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Styles
                                                                          .deactivatedText,
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                      }
                                                    },
                                                  );
                                                }
                                              },
                                            ),
                                            const SizedBox(width: 15,),
                                            const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.mode_comment_outlined,
                                                  color: Styles.deactivatedText,
                                                  size: 25,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              )
                            : const SizedBox(),
                      ),
                      Visibility(
                          visible: doc["datePostsFor"] <= daysPassed,
                          child: Divider(
                            thickness: 3,
                            color: Colors.grey.shade400,
                          ))
                    ],
                  );
                },
              );
            },
          ),
          SizedBox(
            height: context.height * 0.01,
          ),
        ],
      ),
    );
  }
}
