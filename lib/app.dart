import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social/features/authentication/data/firebase_auth_repo.dart';
import 'package:social/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:social/features/authentication/presentation/bloc/auth_state.dart';
import 'package:social/features/authentication/presentation/pages/auth_page.dart';
import 'package:social/features/home/presentation/pages/home_page.dart';
import 'package:social/features/post/data/firebase_post_repository.dart';
import 'package:social/features/post/presentation/cubit/post_cubit.dart';
import 'package:social/features/profile/data/firebase_profile_repo.dart';
import 'package:social/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:social/features/search/data/firebase_search_repo.dart';
import 'package:social/features/search/presentation/cubit/search_cubit.dart';
import 'package:social/features/storage/data/firebase_storage_repo.dart';
import 'package:social/themes/light_theme.dart';
import 'package:social/themes/theme_cubit.dart';

class MyApp extends StatelessWidget {
  final firebaseAuthRepo =FirebaseAuthRepo();
  final firebaseProfileRepo =FirebaseProfileRepo();
  final firebaseStorageRepo = FirebaseStorageRepo();
  final firebasePostRepo =FirebasePostRepository();
  final firebaseSearchRepo = FirebaseSearchRepo();

 MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(create: (context) => AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),),
      BlocProvider(create: (context) => ProfileCubit(profileRepo: firebaseProfileRepo,storageRepo: firebaseStorageRepo)),
      BlocProvider(create: (context) => PostCubit(postRepository: firebasePostRepo, storageRepo: firebaseStorageRepo)),
      BlocProvider(create: (context) => SearchCubit(searchRepo: firebaseSearchRepo)),
      BlocProvider(create: (context) => ThemeCubit()),



    ], 
    child: BlocBuilder<ThemeCubit,ThemeData>(builder: (context,currentTheme) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: currentTheme,
      home: BlocConsumer<AuthCubit,AuthState>(
        builder: (context,authState){
          print(authState);
        if(authState is UnAuthenticated){
          return const AuthPage();
        }
        if(authState is Authenticated){
          return const HomePage();
        }
        else{
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
       listener: (context,state){

        if(state is AuthError){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
        
      }),
    ),));
    
    
  }
}