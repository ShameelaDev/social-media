import 'package:social/features/post/domain/entities/post.dart';

abstract class PostStates {}

class PostInitial extends PostStates{}

class PostLoading extends PostStates{}

class PostUpLoading extends PostStates{}

class PostError extends PostStates{
  final String message;
  PostError(this.message);
}

class PostLaoded extends PostStates{

  final List<Post> posts;
  PostLaoded(this.posts);
}



