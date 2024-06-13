import 'package:cloud_firestore/cloud_firestore.dart';
class Todo{
  String idUser;
  String name;
  String description;
  String imgPost;
  String imgUser;
  Timestamp date;
  int numberOfLike;
  int datePostsFor;
  String role;
  int statusPost;
  final List comments;

  Todo({
    required this.idUser,
    required this.name,
    required this.description,
    required this.imgPost,
    required this.imgUser,
    required this.date,
    required this.numberOfLike,
    required this.datePostsFor,
    required this.role,
    required this.statusPost,
    required this.comments,
  });
  Todo.formJson(Map<String,Object>?json):this(
    idUser: json?['idUser']! as String,
    name: json?['name']! as String,
    description: json?['description']! as String,
    imgPost: json?['imgPost']! as String,
    imgUser: json?['imgUser']! as String,
    date: json?['date']! as Timestamp,
    numberOfLike: json?['numberOfLike']! as int,
    datePostsFor: json?['datePostsFor']! as int,
    role: json?['role']! as String,
    statusPost: json?['statusPost']! as int,
    comments: json?['comments']! as List,
  );
  Todo copyWith(
      {
        String? idUser,
        String? name,
        String? description,
        String? imgPost,
        String? imgUser,
        Timestamp? date,
        int? numberOfLike,
        int? datePostsFor,
        String? role,
        int? statusPost,
        List? comments,
      }){
    return Todo(
      idUser: idUser??this.idUser,
      name: name??this.name,
      description: description??this.description,
      imgPost: imgPost??this.imgPost,
      imgUser: imgUser??this.imgUser,
      date: date??this.date,
      numberOfLike: numberOfLike??this.numberOfLike,
      datePostsFor: datePostsFor??this.datePostsFor,
      role: role??this.role,
      statusPost: statusPost??this.statusPost,
      comments: comments??this.comments,
    );
  }
  Map<String,Object?>toJson(){
    return{
      'idUser':idUser,
      'name':name,
      'description':description,
      'imgPost':imgPost,
      'imgUser':imgUser,
      'date':date,
      'numberOfLike':numberOfLike,
      'datePostsFor':datePostsFor,
      'role':role,
      'statusPost':statusPost,
      'comments':comments,
    };
  }
}
class Comment{
  String idPost;
  String idUser;
  String nameUser;
  String imgUser;
  String description;
  String imgComment;
  Timestamp time;

  Comment({
    required this.idPost,
    required this.idUser,
    required this.nameUser,
    required this.imgUser,
    required this.description,
    required this.imgComment,
    required this.time,

  });
  Comment.formJson(Map<String,Object>?json):this(
    idPost: json?['idPost']! as String,
    idUser: json?['idUser']! as String,
    nameUser: json?['nameUser']! as String,
    imgUser: json?['imgUser']! as String,
    description: json?['description']! as String,
    imgComment: json?['imgComment']! as String,
    time: json?['time']! as Timestamp,
  );
  Comment copyWith(
      {
        String? idPost,
        String? idUser,
        String? nameUser,
        String? imgUser,
        String? description,
        String? imgComment,
        Timestamp? time,
      }){
    return Comment(
      idPost: idPost??this.idPost,
      idUser: idUser??this.idUser,
      nameUser: nameUser??this.nameUser,
      imgUser: imgUser??this.imgUser,
      description: description??this.description,
      imgComment: imgComment??this.imgComment,
      time: time??this.time,
    );
  }
  Map<String,Object?>toJson(){
    return{
      'idPost':idPost,
      'idUser':idUser,
      'nameUser':nameUser,
      'imgUser':imgUser,
      'description':description,
      'imgComment':imgComment,
      'time':time,
    };
  }
}
class UserData{
  String displayName;
  String email;
  String password;
  String img;
  String role;


  UserData({
    required this.displayName,
    required this.email,
    required this.password,
    required this.img,
    required this.role,
  });
  UserData.formJson(Map<String,Object>?json):this(
    displayName: json?['displayName']! as String,
    email: json?['email']! as String,
    password: json?['password']! as String,
    img: json?['img']! as String,
    role: json?['role']! as String,
  );
  UserData copyWith(
      {
        String? displayName,
        String? email,
        String?password,
        String?img,
        String?role,
      }){
    return UserData(
      displayName: displayName??this.displayName,
      email: email??this.email,
      password: password??this.password,
      img: img??this.img,
      role: role??this.role,
    );
  }
  Map<String,Object?>toJson(){
    return{
      'displayName':displayName,
      'email':email,
      'password':password,
      'img':img,
      'role':role,
    };
  }
}
class UserStatusLike{
  String idUser;
  String idPost;
  bool isLike;


  UserStatusLike({
    required this.idUser,
    required this.idPost,
    required this.isLike,
  });
  UserStatusLike.formJson(Map<String,Object>?json):this(
    idUser: json?['idUser']! as String,
    idPost: json?['idPost']! as String,
    isLike: json?['isLike']! as bool,
  );
  UserStatusLike copyWith(
      {
        String? idUser,
        String? idPost,
        bool? isLike,
      }){
    return UserStatusLike(
      idUser: idUser??this.idUser,
      idPost: idPost??this.idPost,
      isLike: isLike??this.isLike,
    );
  }
  Map<String,Object?>toJson(){
    return{
      'idUser':idUser,
      'idPost':idPost,
      'isLike':isLike,
    };
  }
}
