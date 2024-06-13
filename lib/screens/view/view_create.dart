import 'package:blog_idea_app/models/b_idea.dart';
import 'package:blog_idea_app/screens/home/home/home.dart';
import 'package:blog_idea_app/screens/layout/bottom/bottom_navigation_bar.dart';
import 'package:blog_idea_app/service/auth_service.dart';
import 'package:blog_idea_app/service/database/database_service.dart';
import 'package:blog_idea_app/service/get_x/get_x.dart';
import 'package:blog_idea_app/style/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ViewCreateBlogIdea extends StatefulWidget {
  String idUser;
  String id;
  String name;
  String description;
  String imgPost;
  int likeNumer;
  String? postsId;
  bool statusViewCreateBlogIdea;
  ViewCreateBlogIdea({super.key,required this.id,required this.idUser,required this.name,required this.imgPost,required this.likeNumer,required this.description,required this.postsId,required this.statusViewCreateBlogIdea,});

  @override
  State<ViewCreateBlogIdea> createState() => _ViewCreateBlogIdeaState();
}

class _ViewCreateBlogIdeaState extends State<ViewCreateBlogIdea> {
  TextEditingController emojiPicker=TextEditingController();
  bool statusemojiPicker = false;

  final DatabaseService _databaseService=DatabaseService();
  @override
  void initState() {
   widget.description!=''?emojiPicker.text =widget.description:null;
    super.initState();
  }

  int _selectedDay = 1;

  final List<int> _days = const [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,1000000000000000000];

  String imgUser="";
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
  UserDataController userDataController=Get.put(UserDataController());
  @override
  Widget build(BuildContext context) {
    print('${widget.id}--');
    return Scaffold(
      appBar:widget.statusViewCreateBlogIdea?
      AppBar(
        leading: InkWell(
          onTap: () => Get.to(const BottomNavigationBarWidget()),
         // onTap: () {
           // Navigator.pop(context);
         // },
          child: const Icon(Icons.arrow_back),
        ),
        title: const Center(child: Text("Edit Posts",style: TextStyle(fontWeight: FontWeight.bold))),
        actions: [
          InkWell(
            onTap: () async {
                Todo todo = Todo(
                  idUser: widget.id,
                   imgUser: imgUser,
                    name: widget.name,
                    imgPost: imageUrl==""?widget.imgPost:imageUrl,
                    description: emojiPicker.text,
                    date: Timestamp.now(),
                    numberOfLike: widget.likeNumer,
                    datePostsFor:_selectedDay,
                    role:"${userDataController.role}",
                    statusPost: 2,
                    comments: []
                );
                try {
                  await _databaseService.updateTodo(widget.id,todo);
                  Get.offAll(const BottomNavigationBarWidget());
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Update success'),
                  ));
                } catch (error) {
                  print('Error updating todo: $error');
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Update failed. Please try again.'),
                  ));
                }
                emojiPicker.clear();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(horizontal: 15),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: const Text("Save",style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Container(
            height: 0.5,
            color: Colors.grey,
          ),
        ),
      ):
      AppBar(
        leading: InkWell(
          onTap: () => Get.offAll(const BottomNavigationBarWidget()),
          child: const Icon(Icons.arrow_back),
        ),
        title: const Center(child: Text("New Posts",style: TextStyle(fontWeight: FontWeight.bold))),
        actions: [
          InkWell(
            onTap: () async {
              Todo todo = Todo(
                idUser: widget.id,
                imgUser: imgUser,
                  name: widget.name,
                  imgPost: imageUrl,
                  description: emojiPicker.text,
                  date: Timestamp.now(),
                  numberOfLike: 0,
                  datePostsFor: _selectedDay,
                  role: "${userDataController.role}",
                  statusPost: 0,
                  comments: []
              );
              try {
                await _databaseService.addTodo(todo);
                Get.offAll(const BottomNavigationBarWidget());
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Your post is being approved, please wait'),
                ));
              } catch (error) {
                print('Error updating todo: $error');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Update failed. Please try again.'),
                ));
              }
              emojiPicker.clear();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(horizontal: 15),
              decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: const Text("Send",style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Container(
            height: 0.5,
            color: Colors.grey,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(bottom:8.0),
              child: Row(
                children: [
                  StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("db_user").where("email",isEqualTo:"${userDataController.email}").snapshots(),
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
                          final doc = snapshot.data!.docs.first;
                          imgUser=doc['img'];
                          return doc['img']==''?
                          const CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage("assets/images/avatar.png"),
                          ):  CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(doc['img']),
                          );
                        }
                      }
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:  15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            color: Styles.blackText,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            const Text("Save post for",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                            DropdownButton<int>(
                              value: _selectedDay,
                              items: _days.map((day) => DropdownMenuItem<int>(
                                value: day,
                                child:day>31?const Text(" No date"):Text(' $day day'),
                              )).toList(),
                              onChanged: (int? newValue) {
                                setState(() {
                                  _selectedDay = newValue!;
                                });
                              },
                              // Tắt gạch chân bằng cách sử dụng UnderlineInputBorder với borderSide.none
                              underline: Container(
                                height: 1,
                                // color: Colors.blue,
                              ),
                              dropdownColor: Colors.white,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                ],
              ),
            ),
              Column(
                children: [
                  TextField(
                    maxLines: null,
                    controller:  emojiPicker,
                    decoration: const InputDecoration(
                      hintText: "What are you thinking?......",
                      hintStyle: TextStyle(fontSize: 20,fontWeight: FontWeight.w300,color: Styles.blackText),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  imageUrl==""? Visibility(
                    visible: widget.imgPost!="" && widget.statusViewCreateBlogIdea,
                    child: Container(
                      height: context.height*0.4,
                      width: context.width,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(widget.imgPost),
                              fit: BoxFit.fill
                          )
                      ),
                    ),
                  ):
                  Visibility(
                    visible: imageUrl!="",
                    child: Container(
                      height: context.height*0.4,
                      width: context.width,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.fill
                        )
                      ),
                    ),
                  )
                ],
              ),
            if(isloading)const SpinKitThreeBounce(color: Colors.black,size: 20,),
              Expanded(
                  child: SlidingUpPanel(
                    backdropColor: Styles.nearlyWhite,
                    color: Styles.nearlyWhite,
                    // Cấu hình panel ở đây
                    panel: Column(
                      children: [
                        const Divider(thickness: 1),
                        InkWell(
                          onTap: () {
                            pickImage();
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.image,size: 30,color: Colors.green,),
                              SizedBox(width: 10,),
                              Text("Emoticon",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
                              Spacer(),
                            ],
                          ),
                        ),
                        const Divider(thickness: 1),
                        InkWell(
                          onTap: () {
                            setState(() {
                              statusemojiPicker=!statusemojiPicker;
                            });
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.emoji_emotions_outlined,size: 30,color: Colors.orange,),
                              const SizedBox(width: 10,),
                              const Text("Emoticon",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
                              const SizedBox(width: 20,),
                              statusemojiPicker?Icon(Icons.arrow_drop_down,color: Styles.defaultLightGreyColor,size: 35,):Icon(Icons.arrow_drop_up,color: Styles.defaultLightGreyColor,size: 35,),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: statusemojiPicker,
                          child: SizedBox(
                            height:MediaQuery.of(context).size.height*0.15,
                            child: EmojiPicker(
                              textEditingController: emojiPicker, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                              config: Config(
                                checkPlatformCompatibility: true,
                                emojiViewConfig: EmojiViewConfig(
                                  emojiSizeMax: 20 *
                                      (foundation.defaultTargetPlatform == TargetPlatform.android
                                          ?  1.00
                                          :  1.0),
                                  backgroundColor: Styles.scaffoldBackgroundColor,
                                ),
                                swapCategoryAndBottomBar:  true,
                                skinToneConfig: const SkinToneConfig(),
                                categoryViewConfig: CategoryViewConfig(
                                  backgroundColor: Styles.scaffoldBackgroundColor,
                                  showBackspaceButton: true,
                                ),
                                bottomActionBarConfig: const BottomActionBarConfig(enabled: false,),
                              ),
                            ),
                          ),
                        ),
                        const Divider(thickness: 1),
                        InkWell(
                          onTap: () {
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.camera_alt,size: 30,color: Colors.blue,),
                              SizedBox(width: 10,),
                              Text("Camera",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
                              Spacer(),
                            ],
                          ),
                        ),
                        const Divider(thickness: 1),
                        InkWell(
                          onTap: () {
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.local_library,size: 30,color: Colors.red,),
                              SizedBox(width: 10,),
                              Text("Check In",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
                              Spacer(),
                            ],
                          ),
                        ),
                        const Divider(thickness: 1),
                      ],
                    ), // Nội dung của panel khi trượt lên
                    body: const Text("aa"), // Nội dung chính của ứng dụng
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
