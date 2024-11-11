import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social/features/post/domain/entities/comments.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final String imageUrl;
  final DateTime timeStamp;
  final List<String> likes;
  final List<Comments> comments;

  Post(
      {required this.id,
      required this.userId,
      required this.userName,
      required this.text,
      required this.imageUrl,
      required this.timeStamp,
      required this.likes,
      required this.comments});

  Post copyWith({String? imageUrl}) {
    return Post(
        id: id,
        userId: userId,
        userName: userName,
        text: text,
        imageUrl: imageUrl ?? this.imageUrl,
        timeStamp: timeStamp,
        likes: likes,
        comments: comments);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'text': text,
      'imageUrl': imageUrl,
      'timeStamp': Timestamp.fromDate(timeStamp), 
      'likes' : likes,
      'comments':comments.map((comment) => comment.toJson()  ).toList()
    };
  }

  factory Post.fromMap(Map<String, dynamic> json) {
    final List<Comments> comments =(json['comments'] as List<dynamic>?)?.map((commentJson) =>Comments.fromJson(commentJson)).toList()??[];
    return Post(
        id: json['id'],
        userId: json['userId'],
        userName: json['userName'],
        text: json['text'],
        imageUrl: json['imageUrl'],
        timeStamp: (json['timeStamp'] as Timestamp).toDate(),
        likes: List<String>.from(json['likes'] ?? []),
        comments: comments);
        
  }
}
