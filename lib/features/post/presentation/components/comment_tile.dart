import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social/features/authentication/domain/entities/app_user.dart';
import 'package:social/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:social/features/post/domain/entities/comments.dart';
import 'package:social/features/post/presentation/components/post_tile.dart';
import 'package:social/features/post/presentation/cubit/post_cubit.dart';

class CommentTile extends StatefulWidget {
  final Comments comment;
  const CommentTile({super.key,required this.comment});

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {

  AppUser? currentUser;
  bool isOwnPost =false;

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser(){
    final authCubit = context.read<AuthCubit>();
    currentUser =authCubit.currentUser;
    isOwnPost = (widget.comment.userId == currentUser!.uid);
  }

   void showOptions() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Delete comment?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            
              TextButton(
                onPressed: () {
                  context.read<PostCubit>().deleteComment(widget.comment.postId, widget.comment.id);
                  Navigator.of(context).pop();
                },
                child: const Text("Delete"),
              ),
          ],
        ),
      );
    }

  @override
  Widget build(BuildContext context) {
    return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(children: [
                          Text(widget.comment.userName,style: const TextStyle(fontWeight: FontWeight.bold),),
                          const SizedBox(width: 10,),
                          Text(widget.comment.text),
                          const Spacer(),
                          if(isOwnPost)
                          GestureDetector(
                            onTap: showOptions,
                            child:  Icon(Icons.more_horiz,color: Theme.of(context).colorScheme.primary,),
                          )
                        
                        ],),
                      );
  }
}