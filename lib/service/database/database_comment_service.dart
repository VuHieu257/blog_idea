
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/b_idea.dart';


const String TODO_COLLECTION_REF="db_comment";

class DatabaseCommentService{
  final _fierstore=FirebaseFirestore.instance;
  late final CollectionReference _todosRef;
  DatabaseCommentService(){
    _todosRef=_fierstore.collection(TODO_COLLECTION_REF).withConverter<Comment>(
        fromFirestore: (snapshots,_)=>Comment.formJson(
          snapshots.data()?.cast<String, Object>(),
        ) ,
        toFirestore: (comment,_)=>comment.toJson());
  }
  Stream<QuerySnapshot> getComments(){
    return _todosRef.snapshots();
  }
  Stream<QuerySnapshot> getFind(String nameColumn,String searchName){
    return _todosRef.where(nameColumn,isEqualTo: searchName).snapshots();
  }
  Stream<QuerySnapshot> getFindId(String nameColumn,String idPosts){
    return _todosRef.where(nameColumn,isEqualTo: idPosts).snapshots();
  }
  Future<void> updateComments(String id, Comment comment) async {
    try {
      await _todosRef.doc(id).update(comment.toJson());
      print('Todo updated successfully!'); // Informative success message
    } catch (error) {
      print('Error updating todo: $error'); // Log the error for debugging
    }
  }
  Future<void> updateComment(String id, String description,String img) async {
    try {
      await _todosRef.doc(id).update({"descripton": description,"imgComment":img});
      print('Todo updated successfully!'); // Informative success message
    } catch (error) {
      print('Error updating todo: $error'); // Log the error for debugging
    }
  }
  Future<String?> addComment(Comment comment) async {
    try {
      await _todosRef.add(comment);
      print('comment added successfully!'); // Informative success message
      return "success"; // Informative success message
    } catch (error) {
      print('Error adding comment: $error'); // Log the error for debugging
      return 'error';
    }
  }

  Future<void> deleteComment(String id) async {
    try {
      await _todosRef.doc(id).delete();
      print('Todo deleted successfully!'); // Informative success message
    } catch (error) {
      print('Error deleting todo: $error'); // Log the error for debugging
    }
  }
}
