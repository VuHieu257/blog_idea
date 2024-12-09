import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import '../models/b_idea.dart';
import 'database/database_user_service.dart';
class AuthService {
  Future<String?> registration({
    required String email,
    required String userName,
    required String password,
  }) async {
    try {
      final DatabaseUserService _databaseService=DatabaseUserService();

      final methods =
      await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        // Email đã được sử dụng cho việc đăng ký
        return 'The account already exists for that email.';
      } else {
        // Email chưa được sử dụng, tiến hành tạo tài khoản mới
        UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        UserData user = UserData(
            displayName: userName,
            email: email,
            password: password,
            role: "blogger", img: '');
        _databaseService.addUserData(user, userCredential.user?.uid ?? "");
        return 'Success';
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else {
        return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'Success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else {
        return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }
  Future<void> changePassword({required String email, required String oldPassword, required String newPassword}) async {
    try {
      // Xác thực lại người dùng với mật khẩu cũ
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: oldPassword);
      await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(credential);

      // Nếu xác thực thành công, cập nhật mật khẩu mới cho người dùng
      await FirebaseAuth.instance.currentUser?.updatePassword(newPassword);
      print("Success");
    } catch (error) {
      // Xử lý các lỗi xác thực hoặc cập nhật mật khẩu
      print("Lỗi thay đổi mật khẩu: $error");
    }
  }
  hideKeyBoard() async {
    FocusManager.instance.primaryFocus?.unfocus();
  }
  Future<String> uploadImage(String imagePath) async {
    Reference ref = FirebaseStorage.instance.ref().child('images/${DateTime.now().toString()}.jpg');
    UploadTask uploadTask = ref.putFile(File(imagePath));
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }
  Future<void>signInUserAnon()async{
    try{
      final userCredential=await FirebaseAuth.instance.signInAnonymously();
      print(("object---UID:${userCredential.user?.uid}"));
    }catch(e){
      print(e);
    }
  }
}
