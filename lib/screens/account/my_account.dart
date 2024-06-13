
import 'package:blog_idea_app/screens/home/expire/expired_articles.dart';
import 'package:blog_idea_app/screens/view/review_articles.dart';
import 'package:blog_idea_app/service/database/database_user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../service/auth_service.dart';
import '../../service/get_x/get_x.dart';
class AccountPage extends StatefulWidget {
  String id;
  AccountPage({super.key,required this.id});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final UserDataController userDataController = Get.put(UserDataController());

  late bool obsCurrentText=true;
  late bool obsCurrentTextOldPassword=true;
  late bool obsCurrentTextNewPassword=true;
  late bool statusEditProfile=true;
  final user = FirebaseAuth.instance.currentUser;
  TextEditingController textEditingControllerName=TextEditingController();
  TextEditingController textEditingControllerOldPassword=TextEditingController();
  TextEditingController textEditingControllerNewPassword=TextEditingController();

  final DatabaseUserService _databaseUserService=DatabaseUserService();

  String imageUrl='';
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
    _databaseUserService.updateOnce("${userDataController.id}", 'img', imageUrl);
  }
  bool statusEdit=false;
  @override
  Widget build(BuildContext context) {
    print(userDataController.role);
    return GestureDetector(
      onTap: ()=>AuthService().hideKeyBoard(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: statusEditProfile?
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left:8.0,top: 8),
                child: Text("My Profile",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22,color: Colors.black),),
              ),
              Divider(thickness: 3,color: Colors.grey.shade400,),
              SizedBox(
                height:context.height*0.2,
                width:context.width*0.4,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if(isloading)const SpinKitThreeBounce(color: Colors.black,size: 20,),
                    Padding(padding: const EdgeInsets.all(15),
                      child: StreamBuilder(
                        stream: _databaseUserService.getFind('email', '${user?.email}'),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            // Nếu đang chờ dữ liệu
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            // Nếu có lỗi xảy ra
                            return Text('Error: ${snapshot.error}');
                          } else {
                            // Nếu có dữ liệu
                            final doc = snapshot.data!.docs.first;
                            return
                              doc['img']!=''?
                              CircleAvatar(
                                radius: 60,
                                backgroundImage: NetworkImage(doc['img'])):
                              const CircleAvatar(
                                radius: 60,
                                backgroundImage: AssetImage("assets/images/avatar.png"),
                              );
                          }
                        },
                      ),
                    ),
                    Positioned(
                      right: 20,
                      bottom: 20,
                      child: InkWell(
                        onTap: () {
                          pickImage();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: const BorderRadius.all(Radius.circular(50)),
                            border: Border.all(width: 1,color: Colors.white)
                          ),
                          child: const Icon(Icons.camera_alt),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left:20.0,top: 8),
                child: Text("${userDataController.displayName}",style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 22,color: Colors.black),),
              ),
              const Divider(),
              InkWell(
                onTap: () {
                  setState(() {
                    statusEdit=!statusEdit;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal:15.0),
                  child: Row(children: [
                    const Icon(Icons.edit),
                    const SizedBox(width: 10,),
                    const Text("Edit information",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                    statusEdit?Icon(Icons.arrow_drop_down_sharp,size: 30,color: Colors.grey.shade400,):Icon(Icons.arrow_drop_up_sharp,size: 30,color: Colors.grey.shade400,)
                  ],),
                ),
              ),
              Visibility(
                visible: statusEdit,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child:costomTextField("E-mail","${userDataController.email}",textEditingControllerName,Icons.email_outlined,statusEditProfile),
                    ),
                    // costomTextField("Full Name","${userDataController.displayName}",textEditingControllerName,Icons.account_circle_outlined,statusEditProfile),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0,horizontal: 15),
                      child: TextFormField(
                        readOnly: true,
                        controller: TextEditingController(text: "${userDataController.password}"),
                        keyboardType:  TextInputType.visiblePassword,
                        obscureText: obsCurrentText,
                        decoration: InputDecoration(
                          label: const Text("Password"),
                          labelStyle: TextStyle(color:Theme.of(context).colorScheme.primary),
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.lock_outline,color: Theme.of(context).colorScheme.primary,size: 30,),
                          border: const OutlineInputBorder(
                              borderSide: BorderSide(width: 1.5),
                              borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                          suffixIcon: GestureDetector(
                            onTap: (){
                              setState(() {
                                obsCurrentText=!obsCurrentText;
                              });
                            },
                            child: Icon(obsCurrentText?Icons.visibility_off_outlined:Icons.visibility_outlined),
                          ),

                        ),),
                    ),
                    InkWell(
                      onTap: (){
                        setState(() {
                          statusEditProfile=!statusEditProfile;
                        });
                      },
                      child: Container(
                        height: context.height*0.06,
                        margin: const EdgeInsets.symmetric(vertical: 20,horizontal: 18),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: const BorderRadius.all(Radius.circular(20))
                        ),
                        child: const Text("Edit Profile",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.white),),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(visible: !statusEdit,child:const Divider()),
              InkWell(
                onTap: () {
                  Get.to(const ExpriceScreen());
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal:15.0),
                  child: Row(children: [
                    Icon(Icons.remove_red_eye),
                    SizedBox(width: 10,),
                    Text("Expired articles",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                  ],),
                ),
              ),
              const Divider(),
              Visibility(
                visible: "${userDataController.role}"=="admin",
                  child:Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Get.to(const ReviewArticles());
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal:15.0),
                          child: Row(children: [
                            Icon(Icons.verified_user),
                            SizedBox(width: 10,),
                            Text("review articles",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                          ],),
                        ),
                      ),
                      const Divider(),
                    ],
                  ) )
            ],
          ):
          Column(
            children: [
              const Text("My Profile",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22,color: Colors.black),),
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: context.height*0.2,
                  width: context.width*0.4,
                  margin: const EdgeInsets.symmetric(vertical: 35),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child:StreamBuilder(
                          stream: _databaseUserService.getFind('email', '${user?.email}'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              // Nếu đang chờ dữ liệu
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              // Nếu có lỗi xảy ra
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              // Nếu không có dữ liệu hoặc không có bản ghi nào tương ứng với idPost
                              return Text('Không có dữ liệu');
                            } else {
                              // Nếu có dữ liệu
                              final doc = snapshot.data!.docs.first;
                              return
                                doc['img']!=''?
                                CircleAvatar(
                                    radius: 60,
                                    backgroundImage: NetworkImage(doc['img'])):
                                const CircleAvatar(
                                  radius: 60,
                                  backgroundImage: AssetImage("assets/images/avatar.png"),
                                );
                            }
                          },
                        ),
                      ),
                      Positioned(
                        right: 20,
                        bottom: 20,
                        child: InkWell(
                          onTap: () {
                            pickImage();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade300,
                              borderRadius: const BorderRadius.all(Radius.circular(50)),
                            ),
                            child: const Icon(Icons.add_a_photo_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: TextFormField(
                  controller:textEditingControllerName,
                  keyboardType:  TextInputType.text,
                  decoration: InputDecoration(
                    label: const Text("User Name"),
                    hintText: "Enter User Name",
                    labelStyle: TextStyle(color:Theme.of(context).colorScheme.primary),
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.lock_outline,color: Theme.of(context).colorScheme.primary,size: 30,),
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(width: 1.5),
                        borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                  ),),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: TextFormField(
                  controller:textEditingControllerOldPassword,
                  keyboardType:  TextInputType.visiblePassword,
                  obscureText: obsCurrentTextOldPassword,
                  decoration: InputDecoration(
                    label: const Text("Old Password"),
                    hintText: "Enter Old password",
                    labelStyle: TextStyle(color:Theme.of(context).colorScheme.primary),
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.lock_outline,color: Theme.of(context).colorScheme.primary,size: 30,),
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(width: 1.5),
                        borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    suffixIcon: GestureDetector(
                      onTap: (){
                        setState(() {
                          obsCurrentTextOldPassword=!obsCurrentTextOldPassword;
                        });
                      },
                      child: Icon(obsCurrentTextOldPassword?Icons.visibility_off_outlined:Icons.visibility_outlined),
                    ),

                  ),),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: TextFormField(
                  controller:textEditingControllerNewPassword,
                  keyboardType:  TextInputType.visiblePassword,
                  obscureText: obsCurrentTextNewPassword,
                  decoration: InputDecoration(
                    label: const Text("New Password"),
                    hintText: "Enter New password",
                    labelStyle: TextStyle(color:Theme.of(context).colorScheme.primary),
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.lock_outline,color: Theme.of(context).colorScheme.primary,size: 30,),
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(width: 1.5),
                        borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    suffixIcon: GestureDetector(
                      onTap: (){
                        setState(() {
                          obsCurrentTextNewPassword=!obsCurrentTextNewPassword;
                        });
                      },
                      child: Icon(obsCurrentTextNewPassword?Icons.visibility_off_outlined:Icons.visibility_outlined),
                    ),

                  ),),
              ),
              InkWell(
                onTap: () async {
                  await AuthService().changePassword(
                    email: "${userDataController.email}",
                    oldPassword: textEditingControllerOldPassword.text,
                    newPassword: textEditingControllerNewPassword.text,
                  );
                  setState(() {
                    statusEditProfile=!statusEditProfile;
                    userDataController.updateUserData(
                      "${userDataController.id}",
                      textEditingControllerName.text,
                      textEditingControllerNewPassword.text,
                      "${user!.email}",
                        "${userDataController.role}"
                    );
                  });
                  textEditingControllerName.clear();
                  textEditingControllerOldPassword.clear();
                  textEditingControllerNewPassword.clear();
                },
                child: Container(
                  height: context.height*0.06,
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.all(Radius.circular(20))
                  ),
                  child: const Text("Save",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.white),),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  Padding costomTextField(String title,String description,TextEditingController controller,IconData icon,bool status){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: TextField(
        controller: status?TextEditingController(text: description):controller,
        readOnly:status?true:false,
        decoration: InputDecoration(
            label: Text(title),
            hintText: status?"":"Previous name: $description",
            labelStyle: TextStyle(color:Theme.of(context).colorScheme.primary),
            alignLabelWithHint: true,
            prefixIcon: Icon(icon,color: Theme.of(context).colorScheme.primary,size: 30,),
            border: const OutlineInputBorder(
                borderSide: BorderSide(width: 1.5),
                borderRadius: BorderRadius.all(Radius.circular(20))
            )
        ),),
    );
  }
}

