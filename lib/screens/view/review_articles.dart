import 'package:blog_idea_app/models/b_idea.dart';
import 'package:blog_idea_app/screens/layout/bottom/bottom_navigation_bar.dart';
import 'package:blog_idea_app/screens/view/view_create.dart';
import 'package:blog_idea_app/service/database/database_like_service.dart';
import 'package:blog_idea_app/service/database/database_service.dart';
import 'package:blog_idea_app/service/database/database_user_service.dart';
import 'package:blog_idea_app/service/get_x/get_x.dart';
import 'package:blog_idea_app/style/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class ReviewArticles extends StatefulWidget {
  const ReviewArticles({super.key});

  @override
  State<ReviewArticles> createState() => _ReviewArticlesState();
}

class _ReviewArticlesState extends State<ReviewArticles> {
  final user = FirebaseAuth.instance.currentUser;
  final DatabaseService _databaseService=DatabaseService();
  final DatabaseUserService _databaseUserService=DatabaseUserService();
  final DatabaseLikeService _databaseLikeService=DatabaseLikeService();
  final UserDataController userDataController = Get.put(UserDataController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _trending(),
    );
  }
  PreferredSizeWidget _appBar(){
    return AppBar(
      leading: InkWell(
        onTap:() => Get.offAll(const BottomNavigationBarWidget()),
        child: const Icon(Icons.arrow_back),
      ),
      title: const Text("Review Articles",style: TextStyle(fontWeight: FontWeight.bold),),
      backgroundColor: Colors.white,
    );
  }
  Widget _trending() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(thickness: 3,color: Colors.grey.shade400,),
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
                physics:const NeverScrollableScrollPhysics(),
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
                        // margin: const EdgeInsets.only(bottom:5),
                        // padding: const EdgeInsets.only(bottom: 15,top: 10),
                        color: Colors.white,
                        child:doc['statusPost']==0?
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Row(
                                children: [
                                  StreamBuilder(
                                    stream: _databaseUserService.getFind('displayName', doc['name']),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        // Nếu đang chờ dữ liệu
                                        return const CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        // Nếu có lỗi xảy ra
                                        return Text('Error: ${snapshot.error}');
                                      } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                        // Nếu không có dữ liệu hoặc không có bản ghi nào tương ứng với idPost
                                        return  const CircleAvatar(
                                          radius: 20,
                                          backgroundImage: AssetImage("assets/images/avatar.png"),
                                        );
                                      } else {
                                        // Nếu có dữ liệu
                                        final userData = snapshot.data!.docs.first;
                                        return
                                          doc['name']==userData['displayName']?
                                          userData['img']!=''?
                                          CircleAvatar(
                                              radius: 20,
                                              backgroundImage: NetworkImage(userData['img'])):
                                          const CircleAvatar(
                                            radius: 20,
                                            backgroundImage: AssetImage("assets/images/avatar.png"),
                                          ):
                                          const CircleAvatar(
                                            radius: 20,
                                            backgroundImage: AssetImage("assets/images/avatar.png"),
                                          );
                                      }
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal:8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              doc['name'],
                                              style: const TextStyle(
                                                color: Styles.blackText,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Visibility(visible: doc['statusPost']==0,child: statusPost("Process",Colors.orange.shade300)),
                                            Visibility(visible: doc['statusPost']==1,child: statusPost("Unapproved",Colors.red.shade300)),
                                            Visibility(visible: doc['statusPost']==3,child: statusPost("Approval",Colors.green.shade300))
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              minutesPassed>60?hoursPassed>24?"$daysPassed day ago":"$hoursPassed hours ago":"$minutesPassed minutes ago",
                                              style: const TextStyle(
                                                color: Styles.deactivatedText,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 5,),
                                            const Icon(Icons.language,size: 20,color: Styles.deactivatedText,)
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  StreamBuilder(
                                      stream: FirebaseFirestore.instance.collection("db_user").where("email",isEqualTo:"${user!.email}").snapshots(),
                                      builder: (context,snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          // Nếu đang chờ dữ liệu
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          // Nếu có lỗi xảy ra
                                          return Text('Error: ${snapshot.error}');
                                        } else if (!snapshot.hasData ||
                                            snapshot.data!.docs.isEmpty) {
                                          // Nếu không có dữ liệu hoặc không có bản ghi nào tương ứng với idPost
                                          return const Text('Không có dữ liệu');
                                        } else {
                                          // Nếu có dữ liệu
                                          final docUser = snapshot.data!.docs.first;
                                          userDataController.updateUserData(
                                              docUser.id,
                                              docUser["displayName"],
                                              docUser["password"],
                                              "${user!.email}",
                                              docUser['role']
                                          );
                                          return Visibility(
                                            visible: (docUser['role']=='blogger'&& doc['idUser']==docUser.id)||docUser['role']=='admin',
                                            child: InkWell(
                                                onTap: () {
                                                  showModalBottomSheet(
                                                    context: context,
                                                    builder: (context) => Container(
                                                      height: context.height*0.32,
                                                      width: context.width,
                                                      padding: const EdgeInsets.all(20),
                                                      decoration: BoxDecoration(
                                                          color: Styles.defaultLightGreyColor.withOpacity(0.3),
                                                          borderRadius: const BorderRadius.only(topRight: Radius.circular(25),topLeft: Radius.circular(25))
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            height: context.height*0.01,
                                                            width: context.width*0.3,
                                                            margin:const EdgeInsets.only(bottom: 20) ,
                                                            decoration: const BoxDecoration(
                                                                color: Styles.nearlyWhite,
                                                                borderRadius: BorderRadius.all(Radius.circular(15))
                                                            ),
                                                          ),
                                                          Container(
                                                            width: context.width,
                                                            padding: const EdgeInsets.all(15),
                                                            decoration: const BoxDecoration(
                                                                color: Styles.nearlyWhite,
                                                                borderRadius: BorderRadius.all(Radius.circular(15))
                                                            ),
                                                            child: Column(
                                                              children: [
                                                                InkWell(
                                                                  onTap: () {
                                                                    Get.to(ViewCreateBlogIdea(id: docId,idUser: "${userDataController.id}",imgPost: doc['imgPost'],likeNumer: doc['numberOfLike'],name: doc['name'],description: doc["description"],postsId: docId, statusViewCreateBlogIdea: true,));
                                                                  },
                                                                  child: const Row(
                                                                    children: [
                                                                      Icon(Icons.edit,size: 25,),
                                                                      SizedBox(width: 5,),
                                                                      Text("Edit article",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,),)
                                                                    ],
                                                                  ),
                                                                ),const Divider(thickness: 1),
                                                                InkWell(
                                                                  onTap: () async {
                                                                    await _databaseService.updateOnce(docId, 'statusPost', 2);
                                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                                      content: Text('Post approval success'),
                                                                    ));
                                                                  },
                                                                  child: const Row(
                                                                    children: [
                                                                      Icon(Icons.done_all,size: 25,),
                                                                      SizedBox(width: 5,),
                                                                      Text("Post approval",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,),)
                                                                    ],
                                                                  ),
                                                                ),
                                                                const Divider(thickness: 1),
                                                                InkWell(
                                                                  onTap: () async {
                                                                    await _databaseService.updateOnce(docId, 'statusPost', 1);
                                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                                      content: Text('Post not approved'),
                                                                    ));
                                                                  },
                                                                  child: const Row(
                                                                    children: [
                                                                      Icon(Icons.info,size: 25,),
                                                                      SizedBox(width: 5,),
                                                                      Text("Post not approved",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,),)
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
                                                                      Icon(Icons.restore_from_trash,size: 25,),
                                                                      SizedBox(width: 5,),
                                                                      Text("Move to trash",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,),)
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
                                                child: const Icon(Icons.more_horiz,size: 30, color: Styles.deactivatedText,)),
                                          );
                                        }
                                      }
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 14),
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
                                  visible: doc['imgPost']!="",
                                  child: SizedBox(width: context.width,child: Image(image: NetworkImage(doc['imgPost']),fit: BoxFit.fitWidth ,)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 5),
                                  child: Visibility(visible: doc["numberOfLike"]!=0,
                                      child:  Row(
                                        children: [
                                          const Icon(Icons.favorite,color: Colors.red,size: 20,),
                                          const SizedBox(width: 5,),
                                          Text("${doc["numberOfLike"]}",style: TextStyle(fontSize: 16),),
                                        ],
                                      )),
                                ),
                              ],
                            ),
                          ],
                        ):
                        const SizedBox(),
                      ),
                      Visibility(visible: doc['statusPost']==0,child: Divider(thickness: 3,color: Colors.grey.shade400,))
                    ],
                  );
                },
              );
            },
          ),
          SizedBox(height: context.height*0.17,),
        ],
      ),
    );
  }
  Container statusPost(String title,Color color){
    return  Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.only(left:10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child:Text(title,style: TextStyle(color: Styles.nearlyWhite,fontWeight: FontWeight.bold),),
    );
  }
}
