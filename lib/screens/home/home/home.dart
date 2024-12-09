import 'package:blog_idea_app/models/b_idea.dart';
import 'package:blog_idea_app/screens/comment/comment.dart';
import 'package:blog_idea_app/screens/view/view_create.dart';
import 'package:blog_idea_app/service/database/database_like_service.dart';
import 'package:blog_idea_app/service/database/database_user_service.dart';
import 'package:blog_idea_app/style/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../service/auth_service.dart';
import '../../../service/database/database_service.dart';
import '../../../service/get_x/get_x.dart';
import '../../account/my_account.dart';
import '../../login/sign_in.dart';
import '../trending/trending.dart';

class TabBarHome extends StatefulWidget {
  const TabBarHome({super.key});

  @override
  State<TabBarHome> createState() => _TabBarHomeState();
}

class _TabBarHomeState extends State<TabBarHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Styles.nearlyWhite,
        title: const Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage("assets/images/logo.jpeg"),
            ),
            Text(
              "IDea",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            )
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: GestureDetector(
              onTapDown: (TapDownDetails details) {
                _showPopupMenu(context, details.globalPosition, "a");
              },
              child: const Icon(
                Icons.settings,
                size: 30,
              ),
            ),
          ),
        ],
      ),
      body: const HomeScreen(),
    );
  }

  void _showPopupMenu(
      BuildContext context, Offset position, String name) async {
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx, position.dy, position.dx, position.dy),
      items: [
        PopupMenuItem(
            child: InkWell(
          onTap: () {
            FirebaseAuth.instance.signOut();
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignInScreen(),
                ));
            // userDataController.updateUserData("","","");
          },
          child: Row(
            children: [
              const Icon(Icons.person),
              const SizedBox(
                width: 5,
              ),
              Text(name),
              const Divider(),
            ],
          ),
        )),
        PopupMenuItem(
            child: InkWell(
          onTap: () {
            FirebaseAuth.instance.signOut();
            Get.offAll(
              const SignInScreen(),
            );
            // userDataController.updateUserData("","","");
          },
          child: const Row(
            children: [
              Icon(Icons.logout),
              SizedBox(
                width: 5,
              ),
              Text("LogOut"),
            ],
          ),
        )),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value != null) {
        if (value == 'edit') {
          if (kDebugMode) {
            print('Edit option selected');
          }
        } else if (value == 'delete') {
          if (kDebugMode) {
            print('Delete option selected');
          }
        }
      }
    });
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserDataController userDataController = Get.put(UserDataController());

  final TextEditingController emojiPicker = TextEditingController();
  final TextEditingController textEditingControllerLength =
      TextEditingController();

  bool statusemojiPicker = false;
  bool statusLike = false;
  String nameSearch = "";

  String idUser = '';
  String id = '';
  String name = '';
  String description = '';
  int numberOfLike = 0;
  int datePostsFor = 0;
  String role = '';
  Timestamp date = Timestamp.now();

  final user = FirebaseAuth.instance.currentUser;
  final DatabaseService _databaseService = DatabaseService();
  final DatabaseUserService _databaseUserService = DatabaseUserService();
  final DatabaseLikeService _databaseLikeService = DatabaseLikeService();
  PanelController panelController = PanelController();

  @override
  Widget build(BuildContext context) {
    return Localizations(
        locale: const Locale('en', 'US'),
        delegates: const <LocalizationsDelegate<dynamic>>[
          DefaultWidgetsLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
        ],
        child: SlidingUpPanel(
          controller: panelController,
          minHeight: 0,
          maxHeight: MediaQuery.of(context).size.height * 0.84,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          panelBuilder: (ScrollController sc) {
            return PostCommentScreen(
              panelController: panelController,
              id: id,
            );
          },
          body: GestureDetector(
            onTap: () => AuthService().hideKeyBoard(),
            child: _messagesListView(),
          ),
        ));
  }

  Widget _messagesListView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8.0, top: 10),
            child: Text(
              "TOP TRENDING",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Container(
            height: 220,
            color: Colors.grey.shade200,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('db_posts')
                  .orderBy('numberOfLike', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                var docs = snapshot.data?.docs;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
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
                          margin: const EdgeInsets.only(left: 5),
                          // padding: const EdgeInsets.only(bottom: 15,top: 10),
                          child: doc["datePostsFor"] >= daysPassed
                              ? Column(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Visibility(
                                          visible: doc['imgPost'] != "",
                                          child: Container(
                                              width: 200,
                                              height: 200,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 5),
                                              alignment: Alignment.bottomLeft,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                          doc['imgPost']),
                                                      fit: BoxFit.fitHeight)),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      StreamBuilder(
                                                        stream:
                                                            _databaseUserService
                                                                .getFind(
                                                                    'displayName',
                                                                    doc['name']),
                                                        builder: (context,
                                                            snapshot) {
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
                                                              snapshot
                                                                  .data!
                                                                  .docs
                                                                  .isEmpty) {
                                                            // Nếu không có dữ liệu hoặc không có bản ghi nào tương ứng với idPost
                                                            return const CircleAvatar(
                                                              radius: 20,
                                                              backgroundImage:
                                                                  AssetImage(
                                                                      "assets/images/avatar.png"),
                                                            );
                                                          } else {
                                                            // Nếu có dữ liệu
                                                            final userData =
                                                                snapshot.data!
                                                                    .docs.first;
                                                            return doc['name'] ==
                                                                    userData[
                                                                        'displayName']
                                                                ? userData['img'] !=
                                                                        ''
                                                                    ? CircleAvatar(
                                                                        radius:
                                                                            15,
                                                                        backgroundImage:
                                                                            NetworkImage(userData['img']))
                                                                    : const CircleAvatar(
                                                                        radius:
                                                                            15,
                                                                        backgroundImage:
                                                                            AssetImage("assets/images/avatar.png"),
                                                                      )
                                                                : const CircleAvatar(
                                                                    radius: 15,
                                                                    backgroundImage:
                                                                        AssetImage(
                                                                            "assets/images/avatar.png"),
                                                                  );
                                                          }
                                                        },
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            doc['name'],
                                                            style:
                                                                const TextStyle(
                                                              color: Styles
                                                                  .nearlyWhite,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          Text(
                                                            minutesPassed > 60
                                                                ? hoursPassed >
                                                                        24
                                                                    ? "$daysPassed day ago"
                                                                    : "$hoursPassed hours ago"
                                                                : "$minutesPassed minutes ago",
                                                            style:
                                                                const TextStyle(
                                                              color: Styles
                                                                  .deactivatedText,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const Spacer(),
                                                      StreamBuilder(
                                                          stream: FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  "db_user")
                                                              .where("email",
                                                                  isEqualTo:
                                                                      "${user!.email}")
                                                              .snapshots(),
                                                          builder: (context,
                                                              snapshot) {
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
                                                                snapshot
                                                                    .data!
                                                                    .docs
                                                                    .isEmpty) {
                                                              // Nếu không có dữ liệu hoặc không có bản ghi nào tương ứng với idPost
                                                              return const Text(
                                                                  'Không có dữ liệu');
                                                            } else {
                                                              // Nếu có dữ liệu
                                                              final docUser =
                                                                  snapshot
                                                                      .data!
                                                                      .docs
                                                                      .first;
                                                              userDataController.updateUserData(
                                                                  docUser.id,
                                                                  docUser[
                                                                      "displayName"],
                                                                  docUser[
                                                                      "password"],
                                                                  "${user!.email}",
                                                                  docUser[
                                                                      'role']);
                                                              return Visibility(
                                                                visible: (docUser['role'] ==
                                                                            'blogger' &&
                                                                        doc['idUser'] ==
                                                                            docUser
                                                                                .id) ||
                                                                    docUser['role'] ==
                                                                        'admin',
                                                                child: InkWell(
                                                                    onTap: () {
                                                                      showModalBottomSheet(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) =>
                                                                                Container(
                                                                          height:
                                                                              context.height * 0.21,
                                                                          width:
                                                                              context.width,
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              20),
                                                                          decoration: BoxDecoration(
                                                                              color: Styles.defaultLightGreyColor.withOpacity(0.3),
                                                                              borderRadius: const BorderRadius.only(topRight: Radius.circular(25), topLeft: Radius.circular(25))),
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              Container(
                                                                                height: context.height * 0.01,
                                                                                width: context.width * 0.3,
                                                                                margin: const EdgeInsets.only(bottom: 20),
                                                                                decoration: const BoxDecoration(color: Styles.nearlyWhite, borderRadius: BorderRadius.all(Radius.circular(15))),
                                                                              ),
                                                                              Container(
                                                                                width: context.width,
                                                                                padding: const EdgeInsets.all(15),
                                                                                decoration: const BoxDecoration(color: Styles.nearlyWhite, borderRadius: BorderRadius.all(Radius.circular(15))),
                                                                                child: Column(
                                                                                  children: [
                                                                                    InkWell(
                                                                                      onTap: () {
                                                                                        Get.to(ViewCreateBlogIdea(
                                                                                          id: docId,
                                                                                          idUser: "${userDataController.id}",
                                                                                          imgPost: doc['imgPost'],
                                                                                          likeNumer: doc['numberOfLike'],
                                                                                          name: doc['name'],
                                                                                          description: doc["description"],
                                                                                          postsId: docId,
                                                                                          statusViewCreateBlogIdea: true,
                                                                                        ));
                                                                                      },
                                                                                      child: const Row(
                                                                                        children: [
                                                                                          Icon(
                                                                                            Icons.edit,
                                                                                            size: 25,
                                                                                          ),
                                                                                          SizedBox(
                                                                                            width: 5,
                                                                                          ),
                                                                                          Text(
                                                                                            "Edit article",
                                                                                            style: TextStyle(
                                                                                              fontWeight: FontWeight.bold,
                                                                                              fontSize: 18,
                                                                                            ),
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    const Divider(thickness: 1),
                                                                                    InkWell(
                                                                                      onTap: () async {
                                                                                        await _databaseService.deleteTodo(docId);
                                                                                      },
                                                                                      child: const Row(
                                                                                        children: [
                                                                                          Icon(
                                                                                            Icons.restore_from_trash,
                                                                                            size: 25,
                                                                                          ),
                                                                                          SizedBox(
                                                                                            width: 5,
                                                                                          ),
                                                                                          Text(
                                                                                            "Move to trash",
                                                                                            style: TextStyle(
                                                                                              fontWeight: FontWeight.bold,
                                                                                              fontSize: 18,
                                                                                            ),
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                    child:
                                                                        const Icon(
                                                                      Icons
                                                                          .more_horiz,
                                                                      size: 30,
                                                                      color: Styles
                                                                          .deactivatedText,
                                                                    )),
                                                              );
                                                            }
                                                          }),
                                                    ],
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    doc["description"],
                                                    maxLines: 5,
                                                    style: const TextStyle(
                                                      color: Styles.nearlyWhite,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  StreamBuilder(
                                                    stream: _databaseLikeService
                                                        .getFind('idUser',
                                                            "${userDataController.id}"),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return const CircularProgressIndicator();
                                                      } else if (snapshot
                                                          .hasError) {
                                                        return Text(
                                                            'Error: ${snapshot.error}');
                                                      }

                                                      // Kiểm tra nếu không có dữ liệu
                                                      final userLikes =
                                                          snapshot.data?.docs ??
                                                              [];
                                                      final userLikeDoc =
                                                          userLikes.isNotEmpty
                                                              ? userLikes.first
                                                              : null;
                                                      final isLiked =
                                                          userLikeDoc?[
                                                                  'isLike'] ??
                                                              false;

                                                      return InkWell(
                                                        onTap: () {
                                                          if (isLiked) {
                                                            // Người dùng bỏ thích
                                                            _databaseLikeService
                                                                .updateOnce(
                                                                    userLikeDoc!
                                                                        .id,
                                                                    'isLike',
                                                                    false);
                                                            _databaseService
                                                                .updateOnce(
                                                              docId,
                                                              "numberOfLike",
                                                              doc["numberOfLike"] -
                                                                  1,
                                                            );
                                                          } else {
                                                            // Người dùng thích
                                                            if (userLikeDoc ==
                                                                null) {
                                                              // Tạo mới bản ghi nếu chưa tồn tại
                                                              UserStatusLike
                                                                  like =
                                                                  UserStatusLike(
                                                                idUser:
                                                                    "${userDataController.id}",
                                                                idPost: docId,
                                                                isLike: true,
                                                              );
                                                              _databaseLikeService
                                                                  .addLike(
                                                                      like);
                                                            } else {
                                                              // Cập nhật bản ghi nếu đã tồn tại
                                                              _databaseLikeService
                                                                  .updateOnce(
                                                                      userLikeDoc
                                                                          .id,
                                                                      'isLike',
                                                                      true);
                                                            }
                                                            _databaseService
                                                                .updateOnce(
                                                              docId,
                                                              "numberOfLike",
                                                              doc["numberOfLike"] +
                                                                  1,
                                                            );
                                                          }
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              isLiked
                                                                  ? Icons
                                                                      .favorite
                                                                  : Icons
                                                                      .favorite_border,
                                                              color: isLiked
                                                                  ? Colors.red
                                                                  : Styles
                                                                      .nearlyWhite,
                                                              size: 25,
                                                            ),
                                                            const SizedBox(
                                                                width: 5),
                                                            Text(
                                                              "${doc["numberOfLike"]}",
                                                              style: const TextStyle(
                                                                  fontSize: 16,
                                                                  color: Styles
                                                                      .nearlyWhite),
                                                            ),
                                                            const SizedBox(
                                                                width: 10),
                                                            InkWell(
                                                              onTap: () {
                                                                panelController
                                                                    .open();
                                                                setState(() {
                                                                  id = docId;
                                                                  description =
                                                                      doc['description'];
                                                                  name = doc[
                                                                      'name'];
                                                                  numberOfLike =
                                                                      doc['numberOfLike'];
                                                                  datePostsFor =
                                                                      doc['datePostsFor'];
                                                                  role = doc[
                                                                      'role'];
                                                                  date = doc[
                                                                      'date'];
                                                                });
                                                              },
                                                              child: const Icon(
                                                                Icons
                                                                    .mode_comment_outlined,
                                                                color: Styles
                                                                    .nearlyWhite,
                                                                size: 25,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              )),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
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
                shrinkWrap: true,
                itemCount: docs?.length,
                itemBuilder: (context, index) {
                  var doc = docs?[index];
                  var isUser=doc?['idUser']??"";
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
                          // child:doc["datePostsFor"]>=daysPassed && doc['statusPost']==2?
                          child: Column(
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
                                                              userData['img']))
                                                  : const CircleAvatar(
                                                      radius: 20,
                                                      backgroundImage: AssetImage(
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
                                          Text(
                                            doc['name'],
                                            style: const TextStyle(
                                              color: Styles.blackText,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                            ),
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
                                                  color: Styles.deactivatedText,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              const Icon(
                                                Icons.language,
                                                size: 20,
                                                color: Styles.deactivatedText,
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    StreamBuilder(
                                        stream: _databaseUserService.getFind(
                                            'email', "${user!.email}"),
                                        builder: (context, snapshot) {
                                          print(idUser==user!.uid);
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
                                            userDataController.updateUserData(
                                                docUser.id,
                                                docUser["displayName"],
                                                docUser["password"],
                                                "${user!.email}",
                                                docUser['role']);
                                            return Visibility(
                                              visible: idUser==user!.uid,
                                              // visible: (docUser['role']=='blogger'&& doc['idUser']==docUser.id)||docUser['role']=='admin',
                                              child: InkWell(
                                                  onTap: () {
                                                    showModalBottomSheet(
                                                      context: context,
                                                      builder: (context) =>
                                                          Container(
                                                        height: context.height *
                                                            0.21,
                                                        width: context.width,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(20),
                                                        decoration: BoxDecoration(
                                                            color: Styles
                                                                .defaultLightGreyColor
                                                                .withOpacity(
                                                                    0.3),
                                                            borderRadius: const BorderRadius
                                                                .only(
                                                                topRight: Radius
                                                                    .circular(
                                                                        25),
                                                                topLeft: Radius
                                                                    .circular(
                                                                        25))),
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              height: context
                                                                      .height *
                                                                  0.01,
                                                              width: context
                                                                      .width *
                                                                  0.3,
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          20),
                                                              decoration: const BoxDecoration(
                                                                  color: Styles
                                                                      .nearlyWhite,
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              15))),
                                                            ),
                                                            Container(
                                                              width:
                                                                  context.width,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(15),
                                                              decoration: const BoxDecoration(
                                                                  color: Styles
                                                                      .nearlyWhite,
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              15))),
                                                              child: Column(
                                                                children: [
                                                                  InkWell(
                                                                    onTap: () {
                                                                      Get.to(
                                                                          ViewCreateBlogIdea(
                                                                        id: docId,
                                                                        idUser:
                                                                            idUser,
                                                                        imgPost:
                                                                            doc['imgPost'],
                                                                        likeNumer:
                                                                            doc['numberOfLike'],
                                                                        name: doc[
                                                                            'name'],
                                                                        description:
                                                                            doc["description"],
                                                                        postsId:
                                                                            docId,
                                                                        statusViewCreateBlogIdea:
                                                                            true,
                                                                      ));
                                                                    },
                                                                    child:
                                                                        const Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .edit,
                                                                          size:
                                                                              25,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        Text(
                                                                          "Edit article",
                                                                          style:
                                                                              TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                18,
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const Divider(
                                                                      thickness:
                                                                          1),
                                                                  InkWell(
                                                                    onTap:
                                                                        () async {
                                                                      await _databaseService
                                                                          .deleteTodo(
                                                                              docId);
                                                                    },
                                                                    child:
                                                                        const Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .restore_from_trash,
                                                                          size:
                                                                              25,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        Text(
                                                                          "Move to trash",
                                                                          style:
                                                                              TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                18,
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: const Icon(
                                                    Icons.more_horiz,
                                                    size: 30,
                                                    color:
                                                        Styles.deactivatedText,
                                                  )),
                                            );
                                          }
                                        }),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    child: SizedBox(
                                        width: context.width,
                                        child: Image(
                                          image: NetworkImage(doc['imgPost']),
                                          fit: BoxFit.fitWidth,
                                        )),
                                  ),
                                  Container(
                                    height: 0.5,
                                    color: Styles.deactivatedText,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 30,
                                        ),
                                        SizedBox(
                                          height: context.height * 0.05,
                                          child: StreamBuilder(
                                            stream:
                                                _databaseLikeService.getFind(
                                                    'idUser',
                                                    "${userDataController.id}"),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const CircularProgressIndicator();
                                              } else if (snapshot.hasError) {
                                                return Text(
                                                    'Error: ${snapshot.error}');
                                              } else if (!snapshot.hasData ||
                                                  snapshot.data!.docs.isEmpty) {
                                                // Nếu không có dữ liệu hoặc không có bản ghi nào tương ứng với idPost
                                                return InkWell(
                                                  onTap: () {
                                                    UserStatusLike like =
                                                        UserStatusLike(
                                                            idUser:
                                                                "${userDataController.id}",
                                                            idPost: docId,
                                                            isLike: true);
                                                    _databaseLikeService
                                                        .addLike(like);
                                                    _databaseService.updateOnce(
                                                        docId,
                                                        "numberOfLike",
                                                        doc["numberOfLike"] +
                                                            1);
                                                  },
                                                  child: const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.favorite_border,
                                                        color: Styles
                                                            .deactivatedText,
                                                        size: 25,
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        "Like",
                                                        style: TextStyle(
                                                          color: Styles
                                                              .deactivatedText,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              } else {
                                                List docLikes =
                                                    snapshot.data!.docs ?? [];
                                                for (final like in docLikes) {
                                                  // print(like['idUser']=="${userDataController.id}");
                                                  var docLikeId = like.id;
                                                  if (like['idUser'] ==
                                                          "${userDataController.id}" &&
                                                      like['idPost'] == docId) {
                                                    return like['isLike']
                                                        ? InkWell(
                                                            onTap: () {
                                                              _databaseLikeService
                                                                  .updateOnce(
                                                                      docLikeId,
                                                                      'isLike',
                                                                      false);
                                                              _databaseService
                                                                  .updateOnce(
                                                                      docId,
                                                                      "numberOfLike",
                                                                      doc["numberOfLike"] -
                                                                          1);
                                                            },
                                                            child: Row(
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
                                                                  "${doc["numberOfLike"] ?? ""}",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        : InkWell(
                                                            onTap: () {
                                                              _databaseLikeService
                                                                  .updateOnce(
                                                                      docLikeId,
                                                                      'isLike',
                                                                      true);
                                                              _databaseService
                                                                  .updateOnce(
                                                                      docId,
                                                                      "numberOfLike",
                                                                      doc["numberOfLike"] +
                                                                          1);
                                                            },
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
                                                                  "${doc["numberOfLike"] ?? ""}",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                  }
                                                }
                                                return InkWell(
                                                  onTap: () {
                                                    UserStatusLike like =
                                                        UserStatusLike(
                                                            idUser:
                                                                "${userDataController.id}",
                                                            idPost: docId,
                                                            isLike: true);
                                                    _databaseLikeService
                                                        .addLike(like);
                                                    _databaseService.updateOnce(
                                                        docId,
                                                        "numberOfLike",
                                                        doc["numberOfLike"] +
                                                            1);
                                                  },
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
                                                        "${doc["numberOfLike"] ?? ""}",
                                                        style: const TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            panelController.open();
                                            setState(() {
                                              id = docId;
                                              description = doc['description'];
                                              name = doc['name'];
                                              numberOfLike =
                                                  doc['numberOfLike'];
                                              datePostsFor =
                                                  doc['datePostsFor'];
                                              role = doc['role'];
                                              date = doc['date'];
                                            });
                                          },
                                          child: const Icon(
                                            Icons.mode_comment_outlined,
                                            color: Styles.deactivatedText,
                                            size: 25,
                                          ),
                                        ),
                                        const Spacer(),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 1,
                                    color: Colors.grey.shade200,
                                  ),
                                ],
                              ),
                            ],
                          )
                          // const SizedBox(),
                          ),
                      // Visibility(visible: doc["datePostsFor"]>=daysPassed && doc['statusPost']==2,child: Divider(thickness: 3,color: Colors.grey.shade400,))
                    ],
                  );
                },
              );
            },
          ),
          Container(
              color: Colors.black54,
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              child: const Text(
                "There are no new posts yet",
                style: TextStyle(color: Colors.white),
              )),
          // SizedBox(height: context.height*0.17,),
        ],
      ),
    );
  }

  TextField customeTextField(TextEditingController controller,
      TextInputType keyboardType, String texthint) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
          hintText: texthint, hintStyle: const TextStyle(fontSize: 18)),
    );
  }
}
