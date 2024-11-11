import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social/features/authentication/domain/entities/app_user.dart';
import 'package:social/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:social/features/authentication/presentation/components/my_text_field.dart';
import 'package:social/features/post/domain/entities/comments.dart';
import 'package:social/features/post/domain/entities/post.dart';
import 'package:social/features/post/presentation/components/comment_tile.dart';
import 'package:social/features/post/presentation/cubit/post_cubit.dart';
import 'package:social/features/post/presentation/cubit/post_states.dart';
import 'package:social/features/profile/domain/entities/profile_user.dart';
import 'package:social/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:social/features/profile/presentation/pages/profile_page.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;
  const PostTile({
    super.key,
    required this.post,
    required this.onDeletePressed,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  bool isOwnPost = false;
  AppUser? currentUser;
  ProfileUser? postUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    fetchPostUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    if (currentUser != null) {
      setState(() {
        isOwnPost = (widget.post.userId == currentUser!.uid);
      });
    }
  }

  void fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);
    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  final commentTextController = TextEditingController();

  void openNewCommentBox() {
    showDialog(
        context: context,
        builder: (contect) => AlertDialog(
              content: MyTextField(
                  controller: commentTextController,
                  hintText: "Type a comment ",
                  obscureText: false),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel")),
                TextButton(
                    onPressed: () {
                      addComment();

                      Navigator.of(context).pop();
                    },
                    child: const Text("add"))
              ],
            ));
  }

  void addComment() {
    final newComment = Comments(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        postId: widget.post.id,
        userId: currentUser!.uid,
        userName: currentUser!.name,
        text: commentTextController.text,
        timeStamp: DateTime.now());

        if(commentTextController.text.isNotEmpty){
          postCubit.addComment(widget.post.id, newComment);
        }
  }

  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
  }

  void onTogglelike() {
    final isLiked = widget.post.likes.contains(currentUser!.uid);
    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid);
      } else {
        widget.post.likes.add(currentUser!.uid);
      }
    });
    postCubit
        .toggleLikePost(widget.post.id, currentUser!.uid)
        .catchError((error) {
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid);
        } else {
          widget.post.likes.remove(currentUser!.uid);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    void showOptions() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Delete post?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            if (widget.onDeletePressed != null)
              TextButton(
                onPressed: () {
                  widget.onDeletePressed!();
                  Navigator.of(context).pop();
                },
                child: const Text("Delete"),
              ),
          ],
        ),
      );
    }

    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        children: [
          GestureDetector(
            onTap: (){
              Navigator.push(context,MaterialPageRoute(builder: (context)=>ProfilePage(uid: widget.post.userId)));
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  
                  if (postUser?.profileImageUrl != null)

                    CachedNetworkImage(
                      imageUrl: postUser!.profileImageUrl,
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.person),
                      imageBuilder: (context, imageProvider) => Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  else
                    const Icon(Icons.person),
                  const SizedBox(width: 10),
                  Text(
                    widget.post.userName,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (isOwnPost)
                    GestureDetector(
                        onTap: showOptions,
                        child: Icon(
                          Icons.delete,
                          color: Theme.of(context).colorScheme.primary,
                        ))
                ],
              ),
            ),
          ),
          CachedNetworkImage(
            imageUrl: widget.post.imageUrl,
            height: 430,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => const SizedBox(height: 430),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Row(
                    children: [
                      GestureDetector(
                          onTap: onTogglelike,
                          child: Icon(
                            widget.post.likes.contains(currentUser!.uid)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: widget.post.likes.contains(currentUser!.uid)
                                ? Colors.red
                                : Theme.of(context).colorScheme.primary,
                          )),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        widget.post.likes.length.toString(),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: openNewCommentBox,
                  child:  Icon(Icons.comment,color: Theme.of(context).colorScheme.primary,)),
                  const SizedBox(width: 5,),
                 Text(widget.post.comments.length.toString(),style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12),),
                const Spacer(),
                Text(widget.post.timeStamp.toString(),)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
            child: Row(
              children: [

              Text(widget.post.userName,style: const TextStyle(fontWeight: FontWeight.bold),),
              const SizedBox(width: 10,),
              Text(widget.post.text)
              
            ],),),
            BlocBuilder<PostCubit,PostStates>(builder: (context,state){
              if(state is PostLaoded){
                final post = state.posts.firstWhere((post) =>(post.id == widget.post.id));

                if(post.comments.isNotEmpty){
                  int showCommentCount = post.comments.length;
                  return ListView.builder(
                    itemCount: showCommentCount,
                    shrinkWrap: true,    
                    physics: const NeverScrollableScrollPhysics(), 
                                   itemBuilder: (context,index){
                      final comment = post.comments[index];
                      return CommentTile(comment: comment);

                    });
                }
              }
              if(state is PostLoading){
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              else if(state is PostError){
                return Center(child: Text(state.message));
              }
              else{
                return const Center(child: Text("No comments yet"));
              }
            })
        ], 
      ),
    );
  }
}
