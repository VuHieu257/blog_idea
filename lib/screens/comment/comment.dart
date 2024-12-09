import 'package:blog_idea_app/models/b_idea.dart';
import 'package:blog_idea_app/service/database/database_comment_service.dart';
import 'package:blog_idea_app/service/database/database_user_service.dart';
import 'package:blog_idea_app/service/get_x/get_x.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:get/get.dart';

import '../../service/auth_service.dart';

class PostCommentScreen extends StatefulWidget {
  final PanelController panelController;
  final String id;
  const PostCommentScreen({super.key,
    required this.panelController,
    required this.id,
  });

  @override
  State<PostCommentScreen> createState() => _PostCommentScreenState();
}
// Text( "${doc?["comments"][index]['id']}"),

class _PostCommentScreenState extends State<PostCommentScreen> {
  String imageUrl="";
  final ImagePicker _imagePicker=ImagePicker();
  bool isloading=false;
  pickImage()async{
    setState(() {
      isloading=true;
    });
    final res= (await _imagePicker.pickImage(source: ImageSource.gallery)) ;
    print("No selected $res");
    if(res!=null){
      imageUrl = await AuthService().uploadImage(res.path);
      print("------------------$imageUrl");
      // uploadtoFirebase(File(res.path));
    }
    setState(() {
      isloading=false;
    });
  }
   // final DatabaseService _databaseService=DatabaseService();
  final DatabaseCommentService _commentService=DatabaseCommentService();
  final UserDataController userDataController = Get.put(UserDataController());
  final DatabaseUserService _databaseUserService=DatabaseUserService();


  TextEditingController emojiPicker=TextEditingController();
  TextEditingController updateDescriptonComment=TextEditingController();

  bool statusemojiPicker = false;
  bool statusData = true;
  @override
  Widget build(BuildContext context) {
    // print(statusData);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () {
                    widget.panelController.close();
                    setState(() {
                      imageUrl='';
                    });
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              const  Spacer(),
                const Text(
                  'Comment',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
              ],
            ),
          ),
          const Divider(thickness: 1),
          SizedBox(
            height:imageUrl!=""?
            (statusemojiPicker?context.height*0.38:context.height*0.6):
            (statusemojiPicker?context.height*0.46:context.height*0.67),
            child: StreamBuilder(
              stream: _commentService.getFind('idPost', widget.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var docs = snapshot.data?.docs;
                return ListView.builder(
                  itemCount: docs?.length,
                  itemBuilder: (context, index) {
                    var doc = docs?[index];
                    String docId = doc!.id;
                    DateTime pastDate = doc['time'].toDate();
                    DateTime now = DateTime.now();
                    Duration difference = now.difference(pastDate);
                    int daysPassed = difference.inDays;
                    int hoursPassed = difference.inHours;
                    int minutesPassed = difference.inMinutes;
                    return Container(
                      margin: const EdgeInsets.all(15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //image user
                          StreamBuilder(
                            stream: _databaseUserService.getFind('displayName', doc['nameUser']),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                // Nếu đang chờ dữ liệu
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                // Nếu có lỗi xảy ra
                                return Text('Error: ${snapshot.error}');
                              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return  const CircleAvatar(
                                  radius: 20,
                                  backgroundImage: AssetImage("assets/images/avatar.png"),
                                );
                              } else {
                                // Nếu có dữ liệu
                                final userData = snapshot.data!.docs.first;
                                return
                                  doc['nameUser']==userData['displayName']?
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
                          const SizedBox(width: 10,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                                      color: Colors.grey.shade200
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Text(doc['nameUser'],style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                          const SizedBox(width: 10,),
                                          Text(
                                            minutesPassed>60?hoursPassed>24?"$daysPassed day":"$hoursPassed hours":"$minutesPassed minute",
                                            style: const TextStyle(
                                              fontSize: 14,fontWeight: FontWeight.bold,color: Colors.black54,
                                            ),
                                          ),
                                        ],),
                                        SizedBox(
                                            width:doc['description'].toString().length>30?context.width*0.65:null,
                                            child:Text("${doc['description']}",style: const TextStyle(fontSize: 18),),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: userDataController.id==doc['idUser'],
                                    child: PopupMenuButton(
                                      iconColor: Colors.black54,
                                      iconSize: 30,
                                      itemBuilder: (context) =>
                                      [
                                        PopupMenuItem(child: InkWell(
                                          // onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountPage(),)),
                                          onTap: () {
                                            showModalBottomSheet(context: context, builder: (context) {
                                              return Container(
                                                margin: const EdgeInsets.all(20),
                                                width: context.width,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text("Descripton comment",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                                    const SizedBox(height: 10,),
                                                    TextField(
                                                      controller: updateDescriptonComment,
                                                      decoration: InputDecoration(
                                                        hintText: doc['description'],
                                                        border: const OutlineInputBorder(
                                                          borderSide: BorderSide(width: 1),
                                                          borderRadius: BorderRadius.all(Radius.circular(20))
                                                        )
                                                      ),
                                                    ),
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        imageUrl==''?
                                                        Container(
                                                          height: context.height*0.15,
                                                          width: context.width*0.3,
                                                          margin: const EdgeInsets.only(top: 8),
                                                          decoration: BoxDecoration(
                                                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                              image: DecorationImage(
                                                                  image: NetworkImage(doc['imgComment']),
                                                                  fit: BoxFit.fill
                                                              )
                                                          ),
                                                        ):
                                                        Container(
                                                          height: context.height*0.15,
                                                          width: context.width*0.3,
                                                          margin: const EdgeInsets.only(top: 8),
                                                          decoration: BoxDecoration(
                                                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                              image: DecorationImage(
                                                                  image: NetworkImage(imageUrl),
                                                                  fit: BoxFit.fill
                                                              )
                                                          ),
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            pickImage();
                                                          },
                                                          child: Container(
                                                            padding: const EdgeInsets.all(10),
                                                            margin: const EdgeInsets.symmetric(horizontal:20),
                                                            decoration: BoxDecoration(
                                                              color:Colors.grey.shade200,
                                                              border: Border.all(
                                                                width: 1
                                                              ),
                                                              borderRadius: const BorderRadius.all(Radius.circular(10))
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                const Text("Change Image "),
                                                                IconButton(onPressed: () {
                                                                }, icon: const Icon(Icons.upload,color: Colors.black,)),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        Comment comment =Comment(
                                                            idPost: widget.id,
                                                            idUser: doc['idUser'],
                                                            nameUser: doc['nameUser'],
                                                            imgUser: doc['imgUser'],
                                                            description:  updateDescriptonComment.text==''?doc['description']:updateDescriptonComment.text,
                                                            imgComment:  imageUrl==''?doc['imgComment']:imageUrl,
                                                            time: Timestamp.now());
                                                        _commentService.updateComments(docId,comment);
                                                        setState(() {
                                                          imageUrl='';
                                                        });
                                                        Fluttertoast.showToast(msg: 'Update success');
                                                      },
                                                      child: Container(
                                                        alignment: Alignment.center,
                                                        margin: const EdgeInsets.all(20),
                                                        padding: const EdgeInsets.all(20),
                                                        decoration: const BoxDecoration(
                                                            color:Colors.blue,
                                                            borderRadius: BorderRadius.all(Radius.circular(10))
                                                        ),
                                                        child: const Text("Save",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white),),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            },);
                                          },
                                          child: const Row(
                                            children: [
                                              Text("Edit"),
                                              SizedBox(width: 5,),
                                              Icon(Icons.edit),
                                            ],
                                          ),)),
                                        PopupMenuItem(child: InkWell(
                                          // onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountPage(),)),
                                          onTap: () {
                                            _commentService.deleteComment(docId);
                                            Fluttertoast.showToast(msg: 'Delete success');
                                          },
                                          child: const Row(
                                            children: [
                                              Text("Delete"),
                                              SizedBox(width: 5,),
                                              Icon(Icons.delete),
                                            ],
                                          ),)),
                                      ],),
                                  )
                                ],
                              ),
                              Visibility(
                                visible: doc['imgComment']!='',
                                child: Container(
                                  height: context.height*0.15,
                                  width: context.width*0.3,
                                  margin: const EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                    image: DecorationImage(
                                      image: NetworkImage(doc['imgComment']),
                                      fit: BoxFit.fill
                                    )
                                  ),
                                ),
                                // child: Image.network(comment['imageUrl'],
                                //   height: context.height*0.2,
                                // ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Visibility(
            visible: imageUrl!="",
            child: Container(
              height:isloading?(statusemojiPicker?context.height*0.055:context.height*0.04):
              (statusemojiPicker?context.height*0.08:context.height*0.07),
              width: context.width*0.14,
              margin: const EdgeInsets.only(left: 20),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.fill
                  )
              ),
            ),
          ),
          if(isloading)const SpinKitThreeBounce(color: Colors.black,size: 20,),
        ],
      ),
      bottomNavigationBar:
      SizedBox(
        height:statusemojiPicker?context.height*0.3:context.height*0.09,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      pickImage();
                    },
                    child: const Icon(Icons.camera_alt_outlined),),
                  Container(
                    margin: const EdgeInsets.only(left: 15),
                    height: 55,
                    width: context.width*0.85,
                    child: TextField(
                      controller: emojiPicker,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          hintText: "Enter something",
                          prefixIcon: InkWell(
                              onTap: () {
                                setState(() {
                                  statusemojiPicker=!statusemojiPicker;
                                });
                              },
                              child: const Icon(Icons.emoji_emotions_outlined)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                          suffixIcon: InkWell(
                            onTap: () async {
                                Comment comment=Comment(
                                    idPost: widget.id,
                                    idUser: "${userDataController.id}",
                                    nameUser: "${userDataController.displayName}",
                                    imgUser: '',
                                    description: emojiPicker.text,
                                    imgComment: imageUrl,
                                    time: Timestamp.now());
                                final message=await _commentService.addComment(comment);
                                if(message!.contains("success")){
                                  Fluttertoast.showToast(msg: 'Add comment success');
                                  setState(() {
                                    imageUrl='';
                                  });
                                  emojiPicker.clear();
                                }else{
                                  Fluttertoast.showToast(msg: 'Add comment failed');
                                }
                                emojiPicker.clear();
                            },
                            child: const Icon(Icons.send,color: Colors.blue,size: 25,),),
                          border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20))
                          )
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: statusemojiPicker,
              child: SizedBox(
                height:MediaQuery.of(context).size.height*0.21,
                child: EmojiPicker(
                  textEditingController: emojiPicker, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                  config: Config(
                    checkPlatformCompatibility: true,
                    emojiViewConfig: EmojiViewConfig(
                      emojiSizeMax: 20 *
                          (foundation.defaultTargetPlatform == TargetPlatform.android
                              ?  1.00
                              :  1.0),
                      backgroundColor: Colors.white,
                    ),
                    swapCategoryAndBottomBar:  true,
                    skinToneConfig: const SkinToneConfig(),
                    categoryViewConfig: const CategoryViewConfig(
                      backgroundColor: Colors.white,
                      showBackspaceButton: true,
                    ),
                    bottomActionBarConfig: const BottomActionBarConfig(enabled: false,),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
