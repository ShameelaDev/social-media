import 'package:flutter/material.dart';
import 'package:social/app.dart';
import 'package:social/features/authentication/presentation/pages/auth_page.dart';
import 'package:social/features/authentication/presentation/pages/signin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:social/themes/light_theme.dart';
import 'config/firebase_options.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp( MyApp());
}

