
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/b_idea.dart';


const String TODO_COLLECTION_REF="db_posts";

class DatabaseService{
  final _fierstore=FirebaseFirestore.instance;
  late final CollectionReference _todosRef;
  DatabaseService(){
    _todosRef=_fierstore.collection(TODO_COLLECTION_REF).withConverter<Todo>(
        fromFirestore: (snapshots,_)=>Todo.formJson(
          snapshots.data()?.cast<String, Object>(),
        ) ,
        toFirestore: (todo,_)=>todo.toJson());
  }
  Stream<QuerySnapshot> getTodos(){
    return _todosRef.snapshots();
  }
  Stream<QuerySnapshot> getfind(String nameColumn,String searchName){
    return _todosRef.where(nameColumn,isEqualTo: searchName).snapshots();
  }
  Stream<QuerySnapshot> getfindId(String nameColumn,String idPosts){
    return _todosRef.where(nameColumn,isEqualTo: idPosts).snapshots();
  }
  Future<void> updateTodo(String todoId, Todo todo) async {
    try {
      await _todosRef.doc(todoId).update(todo.toJson());
      print('Todo updated successfully!'); // Informative success message
    } catch (error) {
      print('Error updating todo: $error'); // Log the error for debugging
    }
  }
  Future<void> updateOnce(String todoId, String nameRow,int numberLike) async {
    try {
      await _todosRef.doc(todoId).update({nameRow: numberLike});
      print('Todo updated successfully!'); // Informative success message
    } catch (error) {
      print('Error updating todo: $error'); // Log the error for debugging
    }
  }
  Future<String?> addComment(String todoId, String id, String description,String img) async {
    try {
      // Tạo một Map để lưu trữ thông tin của comment mới
      Map<String, dynamic> newComment = {
        'id':id,
        'text':description,
        'imageUrl':img,
        'time':Timestamp.now()
      };

      // Lấy danh sách comment hiện tại từ Firestore
      var currentTodoData = await _todosRef.doc(todoId).get();

      // Kiểm tra xem tài liệu todo đã tồn tại trong Firestore hay chưa
      if (currentTodoData.exists) {
        // Lấy danh sách các comment hiện tại từ tài liệu
        List<dynamic> currentComments = currentTodoData.get('comments') ?? [];

        // Thêm comment mới vào danh sách
        currentComments.add(newComment);

        // Cập nhật lại tài liệu trong Firestore với danh sách comment mới
        await _todosRef.doc(todoId).update({'comments': currentComments});

        print('Comment added to todo successfully!'); // Thông báo thành công
        return 'success';
      } else {
        print('Todo with ID $todoId does not exist!'); // Thông báo lỗi nếu todo không tồn tại
        return 'does not exist'; // Thông báo lỗi nếu todo không tồn tại
      }
    } catch (error) {
      print('Error adding comment to todo: $error'); // Ghi log lỗi nếu có
    }
  }
  Future<void> updateComment(String postId, String commentId,String description,String img) async {
    try {
      Map<String, dynamic> newComment = {
        'id':commentId,
        'text':description,
        'imageUrl':img,
        'time':Timestamp.now()
      };

      await _todosRef.doc(postId).collection('comments').doc(commentId).update(newComment);
      print('Comment updated successfully!');
    } catch (e) {
      print('Error updating comment: $e');
    }
  }
  Future<void> addTodo(Todo todo) async {
    try {
      await _todosRef.add(todo);
      print('Todo added successfully!'); // Informative success message
    } catch (error) {
      print('Error adding todo: $error'); // Log the error for debugging
    }
  }

  Future<void> deleteTodo(String todoId) async {
    try {
      await _todosRef.doc(todoId).delete();
      print('Todo deleted successfully!'); // Informative success message
    } catch (error) {
      print('Error deleting todo: $error'); // Log the error for debugging
    }
  }
}


