import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social/responsive/constrained_scaffold.dart';
import 'package:social/themes/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {

    final themeCubit =context.watch<ThemeCubit>();

bool isDarkMode =themeCubit.isDarkMode;

    return ConstrainedScaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text("Dark Mode"),
            trailing: CupertinoSwitch(value: isDarkMode, onChanged: (value){
              themeCubit.ToogleTheme();
            }),
          )
        ],
      ),
    );
  }
}