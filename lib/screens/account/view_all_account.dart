import 'package:blog_idea_app/models/b_idea.dart';
import 'package:blog_idea_app/screens/home/home/home.dart';
import 'package:blog_idea_app/service/database/database_user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../service/auth_service.dart';
import '../../service/get_x/get_x.dart';


class ViewAllAcount extends StatefulWidget {
  const ViewAllAcount({super.key});

  @override
  State<ViewAllAcount> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ViewAllAcount> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final UserDataController userDataController = Get.put(UserDataController());

  final TextEditingController   emojiPicker=TextEditingController();
  final TextEditingController textEditingControllerName=TextEditingController();
  final TextEditingController textEditingControllerEmail=TextEditingController();
  final TextEditingController textEditingControllerPassword=TextEditingController();

  bool obscurrentText = false;
  bool statusLike = false;
  String nameSearch= "";
  int _selectedValue = 1;
  @override
  void initState() {
    "${userDataController.role}"=="user"?
    _selectedValue=1: "${userDataController.role}"=="blogger"?_selectedValue=2:_selectedValue=3;
    super.initState();
  }

  final user = FirebaseAuth.instance.currentUser;
  final DatabaseUserService _databaseUserService=DatabaseUserService();

  PanelController panelController=PanelController();
  @override
  Widget build(BuildContext context) {
    return Localizations(
      locale: const Locale('en', 'US'),
      delegates: const <LocalizationsDelegate<dynamic>>[
        DefaultWidgetsLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
      ],
      child: GestureDetector(
        onTap: () => AuthService().hideKeyBoard(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: _appBar(),
          body: SafeArea(
            child: Column(
              children: [
                _messagesListView(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  PreferredSizeWidget _appBar(){
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      leading: InkWell(
        onTap: () => Get.offAll(const HomeScreen()),
        child: const Icon(Icons.arrow_back,color: Colors.white,),
      ),
      title: const Padding(
        padding: EdgeInsets.symmetric(horizontal:8.0),
        child: Center(
          child: Text("View all acount",
            style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
            // textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );
  }
  Widget _messagesListView() {
    return SizedBox(
      height: context.height*0.9,
      width: context.width,
      child: StreamBuilder(
        // stream:_databaseService.getfind('createdAccount', '${user?.email}'),
        stream:_databaseUserService.getUserDatas(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          var docs = snapshot.data?.docs;
          return ListView.builder(
            itemCount: docs?.length,
            itemBuilder: (context, index) {
              var doc = docs?[index];
              String docId = doc!.id;
              return Visibility(
                visible: doc['role']!="admin",
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      doc['img']==""?
                      const Center(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage("assets/images/avatar.png"),
                        ),
                      ): Center(
                          child: CircleAvatar(
                          radius: 40,
                          backgroundImage:NetworkImage(doc['img']),
                          ),
                         ),
                      const SizedBox(width: 20,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(width: 10,),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: "Name: ",
                                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                TextSpan(
                                  text: doc['displayName'],
                                  style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 17),
                                 )
                              ]
                            )
                          ),
                          Text.rich(
                              TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: "email: ",
                                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                    TextSpan(
                                      text: doc['email'],
                                      style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 17),
                                    )
                                  ]
                              )
                          ),
                          Text.rich(
                              TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: "password: ",
                                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                    TextSpan(
                                      text: doc['password'],
                                      style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 17),
                                    )
                                  ]
                              )
                          ),
                          Text.rich(
                              TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: "role: ",
                                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                    TextSpan(
                                      text: doc['role'],
                                      style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 17),
                                    )
                                  ]
                              )
                          ),
                        ],
                      ),
                      const Spacer(),
                      PopupMenuButton(
                        iconColor: Colors.black54,
                        iconSize: 30,
                        itemBuilder: (context) =>
                        [
                          PopupMenuItem(child: InkWell(
                            // onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountPage(),)),
                            onTap: () {
                              showModalBottomSheet(context: context, builder: (context) {
                                return Container(
                                  height: context.height,
                                  width: context.width,
                                  margin: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Edit User",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                      const SizedBox(height: 10,),
                                      TextField(
                                        controller: textEditingControllerName,
                                        decoration: InputDecoration(
                                            hintText: doc['displayName'],
                                            border: const OutlineInputBorder(
                                                borderSide: BorderSide(width: 1),
                                                borderRadius: BorderRadius.all(Radius.circular(20))
                                            )
                                        ),
                                      ),
                                      const SizedBox(height: 10,),
                                      TextField(
                                        controller: textEditingControllerEmail,
                                        decoration: InputDecoration(
                                            hintText: doc['email'],
                                            border: const OutlineInputBorder(
                                                borderSide: BorderSide(width: 1),
                                                borderRadius: BorderRadius.all(Radius.circular(20))
                                            )
                                        ),
                                      ),
                                      const SizedBox(height: 10,),
                                      TextField(
                                        keyboardType: TextInputType.emailAddress,
                                        controller: textEditingControllerPassword,
                                        obscureText: obscurrentText,
                                        decoration: InputDecoration(
                                          alignLabelWithHint: true,
                                          border: const OutlineInputBorder(
                                            borderSide: BorderSide(width: 1),
                                            borderRadius: BorderRadius.all(Radius.circular(15)),
                                          ),
                                          prefixIcon: const Icon(Icons.lock_outline,size: 30,),
                                          hintText: "Enter Password",
                                          labelText: "Password",
                                          suffixIcon: GestureDetector(
                                            onTap: (){
                                              setState(() {
                                                obscurrentText=!obscurrentText;
                                              });
                                            },
                                            child: Icon(obscurrentText?Icons.visibility_off_outlined:Icons.visibility_outlined),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10,),
                                    "${userDataController.role}"=="admin"?Container(
                                        decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(width: 1,color: Colors.blue)
                                        ),
                                        padding: const EdgeInsets.all(5),
                                        child: DropdownButton<int>(
                                          iconEnabledColor: Colors.blue,
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          value: _selectedValue,
                                          onChanged: (int? newValue) {
                                            setState(() {
                                              _selectedValue = newValue!;
                                              // print(_selectedValue);
                                            });
                                          },
                                          underline: Container(),
                                          items: const [
                                            DropdownMenuItem<int>(
                                              value: 1,
                                              child: Text('User'),
                                            ),
                                            DropdownMenuItem<int>(
                                              value: 2,
                                              child: Text('Blogger'),
                                            ),
                                            DropdownMenuItem<int>(
                                              value: 3,
                                              child: Text('Admin'),
                                            ),
                                          ],
                                        ),
                                      ):Container(
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          border: Border.all(width: 1,color: Colors.blue)
                                      ),
                                      padding: const EdgeInsets.all(5),
                                      child: DropdownButton<int>(
                                        iconEnabledColor: Colors.blue,
                                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                                        value: _selectedValue,
                                        onChanged: (int? newValue) {
                                          setState(() {
                                            _selectedValue = newValue!;
                                            // print(_selectedValue);
                                          });
                                        },
                                        underline: Container(),
                                        items: const [
                                          DropdownMenuItem<int>(
                                            value: 1,
                                            child: Text('User'),
                                          ),
                                          DropdownMenuItem<int>(
                                            value: 2,
                                            child: Text('Blogger'),
                                          ),
                                        ],
                                      ),
                                    ),
                                      InkWell(
                                        onTap: () {
                                          Fluttertoast.showToast(msg: 'Update success');
                                          Get.offAll(const ViewAllAcount());
                                          textEditingControllerPassword.clear();
                                          textEditingControllerName.clear();
                                          textEditingControllerEmail.clear();
                                          UserData userdata=UserData(
                                              displayName: textEditingControllerName.text==''?doc['displayName']:textEditingControllerName.text,
                                              email: textEditingControllerEmail.text==''?doc['email']:textEditingControllerEmail.text,
                                              password: textEditingControllerPassword.text==''?doc['password']:textEditingControllerPassword.text,
                                              img: doc['img'],
                                              role: _selectedValue==1?"user":_selectedValue==2?"blogger":"admin",
                                          );
                                          _databaseUserService.updateUserData(docId, userdata);
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          margin: const EdgeInsets.only(top: 20,left: 20,right: 20),
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
                              _databaseUserService.deleteUserData(docId);
                              Fluttertoast.showToast(msg: 'Delete success');
                            },
                            child: const Row(
                              children: [
                                Text("Delete"),
                                SizedBox(width: 5,),
                                Icon(Icons.delete),
                              ],
                            ),)),
                        ],)
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  TextField customeTextField(TextEditingController _controller,TextInputType keyboardType,String texthint){
    return   TextField(
      controller:_controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(hintText: texthint,hintStyle: const TextStyle(fontSize: 18)),
    );
  }
}
