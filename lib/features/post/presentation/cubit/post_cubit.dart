import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social/features/post/domain/entities/comments.dart';
import 'package:social/features/post/domain/entities/post.dart';
import 'package:social/features/post/domain/repository/post_repository.dart';
import 'package:social/features/post/presentation/cubit/post_states.dart';
import 'package:social/features/storage/domain/storage_repo.dart';

class PostCubit extends Cubit<PostStates> {
  final PostRepository postRepository;
  final StorageRepo storageRepo;
   int postCount =0;

  PostCubit({required this.postRepository, required this.storageRepo})
      : super(PostInitial());

  Future<void> createPost(Post post,
      {String? imagePath, Uint8List? imageBytes}) async {
    try {
      String? imageUrl;

      if (imagePath != null) {
        emit(PostLoading());
        imageUrl = await storageRepo.uploadPostImagePhone(imagePath, post.id);
      } else if (imageBytes != null) {
        emit(PostLoading());
        imageUrl = await storageRepo.uploadPostImageWeb(imageBytes, post.id);
      }

      final newPost = post.copyWith(imageUrl: imageUrl);
      postRepository.createPost(newPost);

      fetchAllPosts();
    } catch (e) {
      emit(PostError("Failed to create posts: $e"));
    }
  }

  Future<void> fetchAllPosts() async {
    try {
      emit(PostLoading());
      final posts = await postRepository.fetchallPost();
      emit(PostLaoded(posts));
    } catch (e) {
      emit(PostError("Failed to fetch posts: $e"));
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await postRepository.deletePost(postId);
    } catch (e) {}
  }

  Future<void> toggleLikePost(String postId, String userId) async{
    try{
      await postRepository.onToggleLikePost(postId, userId);
    
    }
    catch(e){
      emit(PostError("Failed to like post: $e"));
    }

  }

  Future<void> addComment(String postId, Comments comment) async{
    try{
      await postRepository.addComment(postId, comment);
      await fetchAllPosts();

    }
    catch(e){
      emit(PostError("Failed to add comment: $e"));

    }

  }

  Future<void> deleteComment(String postId,String commentId) async{
    try{
      await postRepository.deleteComment(postId, commentId);
      await fetchAllPosts();
    }
    catch(e){
      emit(PostError("failed deleting comments:$e"));
    }

  }
    void fetchAllUserPosts(String userId) async {
    emit(PostLoading());
    try {
      final posts = await postRepository.fetchallPostByUserId(userId);
      final userPosts = posts.where((post) => post.userId == userId).toList();
      postCount = userPosts.length; // Update the postCount for the user
      emit(PostLaoded( posts));
    } catch (e) {
      emit(PostError( e.toString()));
    }
  }
}
