import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social/features/profile/presentation/components/user_tile.dart';
import 'package:social/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:social/features/profile/presentation/pages/profile_page.dart';
import 'package:social/responsive/constrained_scaffold.dart';

class FollowersPage extends StatelessWidget {
  final List<String> followers;
  final List<String> following;
  const FollowersPage(
      {super.key, required this.followers, required this.following});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: ConstrainedScaffold(
          appBar: AppBar(

            bottom:  TabBar(
              dividerColor: Colors.transparent,
              labelColor: Theme.of(context).colorScheme.inversePrimary,
              unselectedLabelColor: Theme.of(context).colorScheme.primary,
              tabs: const[
              Tab(
                text: "Followers",
              ),
              Tab(
                text: "Following",
              )
            ]),
          ),
          body: TabBarView(children: [
            _buildUserList(followers, "No followers", context), 
            _buildUserList(following, "No following", context)]),
        ));
  }

  Widget _buildUserList(List<String> uids, String emptyMsg,BuildContext context)
{
  return uids.isEmpty? Center(child: Text(emptyMsg),):ListView.builder(
    itemCount: uids.length,
    itemBuilder: (context,index){
      final uid =uids[index];
      return FutureBuilder(
        future: context.read<ProfileCubit>().getUserProfile(uid),
         builder: (context,snapsht){
          if(snapsht.hasData){
            final user =snapsht.data;
            return UserTile(user: user!);
          }
          else if(snapsht.connectionState == ConnectionState.waiting){
            return const ListTile(title: Text("Loading...."),);
          }
          else{
            return const ListTile(title: Text("No user found"),);

          }

         });
    });
}}
