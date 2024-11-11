import 'package:social/features/post/domain/entities/comments.dart';
import 'package:social/features/post/domain/entities/post.dart';

abstract class PostRepository {
  Future<void> createPost(Post post);
  Future<void> deletePost(String postId);
  Future<List<Post>> fetchallPost();
  Future<List<Post>> fetchallPostByUserId(String userId);
  Future<void> onToggleLikePost(String postId, String userId);
  Future<void> addComment(String postId,Comments comment);
  Future<void> deleteComment(String postId,String commentId);}