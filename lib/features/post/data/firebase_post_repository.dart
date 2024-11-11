import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social/features/post/domain/entities/comments.dart';
import 'package:social/features/post/domain/entities/post.dart';
import 'package:social/features/post/domain/repository/post_repository.dart';

class FirebasePostRepository implements PostRepository {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final CollectionReference postsCollections =
      FirebaseFirestore.instance.collection('posts');

  @override
  Future<void> createPost(Post post) async {
    try {
      await postsCollections.doc(post.id).set(post.toJson());
    } catch (e) {
      throw Exception("Error creating post: $e");
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    await postsCollections.doc(postId).delete();
  }

  @override
  Future<List<Post>> fetchallPost() async {
    try {
      final postSnapshot =
          await postsCollections.orderBy('timeStamp', descending: true).get();

      final List<Post> allPosts = postSnapshot.docs
          .map((doc) => Post.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      return allPosts;
    } catch (e) {
      throw Exception("Error loading posts : $e");
    }
  }

  @override
  Future<List<Post>> fetchallPostByUserId(String userId) async {
    try {
      final postSnapshot =
          await postsCollections.where('userId', isEqualTo: userId).get();
      final userPosts = postSnapshot.docs
          .map((doc) => Post.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      return userPosts;
    } catch (e) {
      throw Exception("Error loading posts :$e");
    }
  }

  @override
  Future<void> onToggleLikePost(String postId, String userId) async {
    try {
      final postDoc = await postsCollections.doc(postId).get();
      if (postDoc.exists) {
        final post = Post.fromMap(postDoc.data() as Map<String, dynamic>);
        final hasLiked = post.likes.contains(userId);
        if (hasLiked) {
          post.likes.remove(userId);
        } else {
          post.likes.add(userId);
        }
        await postsCollections.doc(postId).update({'likes': post.likes});
      } else {
        throw Exception("post not found");
      }
    } catch (e) {
      throw Exception("Error login");
    }
  }

  @override
  Future<void> addComment(String postId, Comments comment) async{
    try{
      final postDoc = await postsCollections.doc(postId).get();
      if(postDoc.exists){
        final post = Post.fromMap(postDoc.data() as Map<String,dynamic>);
        post.comments.add(comment);
        await postsCollections.doc(postId).update({
          'comments':post.comments.map((comment) => comment.toJson()).toList()
        });

      }
      else{
        throw Exception("Post not found");
      }
    }
    catch(e){
      throw Exception("Error adding comment :$e");

    } 
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async{
    try{
      final postDoc = await postsCollections.doc(postId).get();
      if(postDoc.exists){
        final post = Post.fromMap(postDoc.data() as Map<String,dynamic>);
        post.comments.removeWhere((commnt) => commnt.id == commentId);
        await postsCollections.doc(postId).update({
          'comments':post.comments.map((comment) => comment.toJson()).toList()
        });

      }
      else{
        throw Exception("Post not found");
      }
    }
    catch(e){
      throw Exception("Error deleting comment :$e");

    } 
  }
}
