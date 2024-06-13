import 'package:blog_idea_app/models/b_idea.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


const String USER_COLLECTION_REF="db_user";


class DatabaseUserService{
  final _fierstore=FirebaseFirestore.instance;
  late final CollectionReference _userdatasRef;

  DatabaseUserService(){
    _userdatasRef=_fierstore.collection(USER_COLLECTION_REF).withConverter<UserData>(
        fromFirestore: (snapshots,_)=>UserData.formJson(
          snapshots.data()?.cast<String, Object>(),
        ) ,
        toFirestore: (userdata,_)=>userdata.toJson());
  }
  Stream<QuerySnapshot> getUserDatas(){
    return _userdatasRef.snapshots();
  }
  Stream<QuerySnapshot> getFind(String nameColumn,String searchName){
    return _userdatasRef.where(nameColumn,isEqualTo: searchName).snapshots();
  }
  Future<void> updateUserData(String userdataId, UserData userdata) async {
    try {
      await _userdatasRef.doc(userdataId).update(userdata.toJson());
      print('UserData updated successfully!'); // Informative success message
    } catch (error) {
      print('Error updating userdata: $error'); // Log the error for debugging
    }
  }
  Future<void> updateOnce(String todoId, String nameRow,String img) async {
    try {
      await _userdatasRef.doc(todoId).update({nameRow: img});
      print('Todo updated successfully!'); // Informative success message
    } catch (error) {
      print('Error updating todo: $error'); // Log the error for debugging
    }
  }
  Future<void> addUserData(UserData userdata) async {
    try {
      await _userdatasRef.add(userdata);
      print('UserData added successfully!'); // Informative success message
    } catch (error) {
      print('Error adding userdata: $error'); // Log the error for debugging
    }
  }

  Future<void> deleteUserData(String userdataId) async {
    try {
      await _userdatasRef.doc(userdataId).delete();
      print('UserData deleted successfully!'); // Informative success message
    } catch (error) {
      print('Error deleting userdata: $error'); // Log the error for debugging
    }
  }
}