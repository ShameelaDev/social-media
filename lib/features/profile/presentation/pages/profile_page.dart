import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social/features/authentication/domain/entities/app_user.dart';
import 'package:social/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:social/features/post/presentation/components/post_tile.dart';
import 'package:social/features/post/presentation/cubit/post_cubit.dart';
import 'package:social/features/post/presentation/cubit/post_states.dart';
import 'package:social/features/profile/presentation/components/bio_box.dart';
import 'package:social/features/profile/presentation/components/follow_button.dart';
import 'package:social/features/profile/presentation/components/profile_status.dart';
import 'package:social/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:social/features/profile/presentation/cubit/profile_state.dart';
import 'package:social/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:social/features/profile/presentation/pages/followers_page.dart';
import 'package:social/responsive/constrained_scaffold.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();
  late final postCubit = context.read<PostCubit>();

  late AppUser? currentUser = authCubit.currentUser;
  int postCount = 0;


  @override
  void initState() {
    super.initState();
    profileCubit.fetchUserProfile(widget.uid);
    postCubit.fetchAllUserPosts(widget.uid);
    
  }

  void followButtonPressed() {
    final profileState = profileCubit.state;
    if (profileState is! ProfileLoaded) {
      return;
    }
    final profileUser = profileState.profileUser;
    final isFollowing = profileUser.followers.contains(currentUser!.uid);

    setState(() {
      if (isFollowing) {
        profileUser.followers.remove(currentUser!.uid);
      } else {
        profileUser.followers.add(currentUser!.uid);
      }
    });

    profileCubit.toggleFollow(currentUser!.uid, widget.uid).catchError((error) {
      setState(() {
        if (isFollowing) {
          profileUser.followers.add(currentUser!.uid);
        } else {
          profileUser.followers.remove(currentUser!.uid);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isOwnPost = (widget.uid == currentUser!.uid);

    return BlocBuilder<ProfileCubit, ProfileState>(builder: (context, state) {
      if (state is ProfileLoaded) {
        final user = state.profileUser;
        return ConstrainedScaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(user.name),
            foregroundColor: Theme.of(context).colorScheme.primary,
            actions: [
              if (isOwnPost)
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProfilePage(
                                    profileUser: user,
                                  )));
                    },
                    icon: const Icon(Icons.settings))
            ],
          ),
          body: ListView(children: [
            Column(
              children: [
                Center(
                  child: Text(
                    user.email,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                CachedNetworkImage(
                  imageUrl: user.profileImageUrl,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(
                    Icons.person,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  imageBuilder: (context, imageProvider) => Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover)),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                BlocBuilder<PostCubit,PostStates>(builder: (context, state) => ProfileStatus(
                    postCount: postCubit.postCount,
                    followersCount: user.followers.length,
                    followingCount: user.following.length,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                FollowersPage(followers: user.followers, following: user.following))),
                  ),
                  
                ),
                const SizedBox(
                  height: 25,
                ),
                if (!isOwnPost)
                  FollowButton(
                      isFollow: user.followers.contains(currentUser!.uid),
                      onPressed: followButtonPressed),
                Padding(
                  padding: const EdgeInsets.only(left: 25, top: 25),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bio",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                BioBox(text: user.bio),
                Padding(
                  padding: const EdgeInsets.only(left: 25, top: 25),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Post",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),
                BlocBuilder<PostCubit, PostStates>(builder: (context, state) {
                  if (state is PostLaoded) {
                    final userPost = state.posts
                        .where((post) => post.userId == widget.uid)
                        .toList();
                    return ListView.builder(
                        itemCount: postCubit.postCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final post = userPost[index];
                          return PostTile(
                              post: post,
                              onDeletePressed: () => context
                                  .read<PostCubit>()
                                  .deletePost(post.id));
                        });
                  } else if (state is PostLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return const Center(
                      child: Text("No posts yet"),
                    );
                  }
                })
              ],
            ),
          ]),
        );
      } else if (state is ProfileLoading) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else {
        return const Center(
          child: Text("No profile found"),
        );
      }
    });
  }
}
