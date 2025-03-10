import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:social/features/home/presentation/components/my_drawer_tile.dart';
import 'package:social/features/profile/presentation/pages/profile_page.dart';
import 'package:social/features/search/presentation/pages/search_page.dart';
import 'package:social/features/settings/settings_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Padding(
                padding: EdgeInsetsDirectional.symmetric(vertical: 50),
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                )),
            Divider(color: Theme.of(context).colorScheme.secondary,),

            MyDrawerTile(title: "H O M E", icon: Icons.home, onTap: () {
              Navigator.of(context).pop();
            }),
            MyDrawerTile(title: "P R O FI L E", icon: Icons.person, onTap: () {
              Navigator.of(context).pop();
              final user =context.read<AuthCubit>().currentUser;
              final String uid =user!.uid;
              Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage(uid: uid,)));


            }),

            MyDrawerTile(title: "S E A R C H", icon: Icons.search, onTap: () {
              Navigator.push(context,MaterialPageRoute(builder: (context) => const SearchPage()));
            }),

            MyDrawerTile(title: "S E T T I N G S", icon: Icons.settings, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
            }),
            const Spacer(),

            MyDrawerTile(title: "L O G O U T", icon: Icons.logout, onTap: () {
              context.read<AuthCubit>().logout();
            }),

            
          ],
        ),
      )),
    );
  }
}
