import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social/features/home/presentation/components/my_drawer.dart';
import 'package:social/features/post/presentation/components/post_tile.dart';
import 'package:social/features/post/presentation/cubit/post_cubit.dart';
import 'package:social/features/post/presentation/cubit/post_states.dart';
import 'package:social/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:social/features/profile/presentation/cubit/profile_state.dart';
import 'package:social/features/post/presentation/pages/upload_post_page.dart';
import 'package:social/responsive/constrained_scaffold.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final postCubit = context.read<PostCubit>();

  @override
  void initState() {
    super.initState();
    fetchAllPost();
  }

  void fetchAllPost(){
    postCubit.fetchAllPosts();
  }

  void deletePost(String postId){
    postCubit.deletePost(postId);
    fetchAllPost();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("Home"),
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => UploadPostPage()));
          }, icon: const Icon(Icons.add))
        ],
      ),
      drawer: MyDrawer(),

      body: MultiBlocListener(
        listeners: [
          BlocListener<ProfileCubit, ProfileState>(
            listener: (context, profileState) {
              if (profileState is ProfileLoaded) {
                // Re-fetch posts to ensure profile image updates if needed
                fetchAllPost();
              }
            },
          ),
          BlocListener<PostCubit, PostStates>(
            listener: (context, postState) {
              // Additional handling if needed for posts
            },
          ),
        ],
        child: BlocBuilder<PostCubit, PostStates>(
          builder: (context, state) {
            if (state is PostLoading || state is PostUpLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is PostLaoded) {
              final allUsers = state.posts;
              if (allUsers.isEmpty) {
                return const Center(
                  child: Text("No post available"),
                );
              }
              return ListView.builder(
                itemCount: allUsers.length,
                itemBuilder: (context, index) {
                  final post = allUsers[index];
                  return PostTile(post: post, onDeletePressed: () {
                    deletePost(post.id);
                  });
                },
              );
            } else if (state is PostError) {
              return Center(
                child: Text(state.message),
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}
