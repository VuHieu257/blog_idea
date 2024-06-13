
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/b_idea.dart';


const String TODO_COLLECTION_REF="db_like";

class DatabaseLikeService{
  final _fierstore=FirebaseFirestore.instance;
  late final CollectionReference _todosRef;
  DatabaseLikeService(){
    _todosRef=_fierstore.collection(TODO_COLLECTION_REF).withConverter<UserStatusLike>(
        fromFirestore: (snapshots,_)=>UserStatusLike.formJson(
          snapshots.data()?.cast<String, Object>(),
        ) ,
        toFirestore: (like,_)=>like.toJson());
  }
  Stream<QuerySnapshot> getLikes(){
    return _todosRef.snapshots();
  }
  Stream<QuerySnapshot> getFind(String nameColumn,String searchName){
    return _todosRef.where(nameColumn,isEqualTo: searchName).snapshots();
  }
  Future<void> updateLikes(String id, UserStatusLike like) async {
    try {
      await _todosRef.doc(id).update(like.toJson());
      print('Like updated successfully!'); // Informative success message
    } catch (error) {
      print('Error updating Like: $error'); // Log the error for debugging
    }
  }
  Future<void> updateOnce(String todoId, String nameRow,bool isLike) async {
    try {
      await _todosRef.doc(todoId).update({nameRow: isLike});
      print('Todo updated successfully!'); // Informative success message
    } catch (error) {
      print('Error updating Like: $error'); // Log the error for debugging
    }
  }
  Future<String?> addLike(UserStatusLike like) async {
    try {
      await _todosRef.add(like);
      print('like added successfully!'); // Informative success message
      return "success"; // Informative success message
    } catch (error) {
      print('Error adding like: $error'); // Log the error for debugging
      return 'error';
    }
  }

  Future<void> deleteLike(String id) async {
    try {
      await _todosRef.doc(id).delete();
      print('Todo deleted successfully!'); // Informative success message
    } catch (error) {
      print('Error deleting todo: $error'); // Log the error for debugging
    }
  }
}


