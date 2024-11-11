import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social/features/authentication/domain/entities/app_user.dart';
import 'package:social/features/authentication/presentation/bloc/auth_cubit.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:social/features/authentication/presentation/components/my_text_field.dart';
import 'package:social/features/post/domain/entities/post.dart';
import 'package:social/features/post/presentation/cubit/post_cubit.dart';
import 'package:social/features/post/presentation/cubit/post_states.dart';
import 'package:social/responsive/constrained_scaffold.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  PlatformFile? imagePickedFile;
  Uint8List? webImage;
  final textController = TextEditingController();
  AppUser? currentUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.image, withData: kIsWeb);
    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;
        if (kIsWeb) {
          webImage = imagePickedFile!.bytes;
        }
      });
    }
  }

  void uploadPost() {
    if (imagePickedFile == null || textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Both image and captions are required")));
      return;
    }

    final newPost = Post(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        userId: currentUser!.uid,
        userName: currentUser!.name,
        text: textController.text,
        imageUrl: "",
        timeStamp: DateTime.now(),
        likes: [],
        comments: []);

        final postCubit = context.read<PostCubit>();

        if(kIsWeb){
          postCubit.createPost(newPost,imageBytes: imagePickedFile?.bytes);
        }
        else{
          postCubit.createPost(newPost,imagePath: imagePickedFile?.path);
        }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit,PostStates>(
      builder: (context,state){
        print(state);
        if(state is PostLoading || state is PostUpLoading)
        {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return buildUploadPage();

      }, 
      listener: (context,state){
        if(state is PostLaoded){
          Navigator.pop(context);

        }
      });
  }

  Widget buildUploadPage(){
    return  ConstrainedScaffold(
      appBar: AppBar(
        title: const Text("Create posts"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(onPressed: (){
            uploadPost();

          }, icon:Icon(Icons.upload,color: Theme.of(context).colorScheme.primary,))
        ],
      ),
      body: Center(
        child: Column(
          children: [
            if(kIsWeb && webImage!=null) Image.memory(webImage!),

            if(!kIsWeb && imagePickedFile!=null) Image.file(File(imagePickedFile!.path!)),

            MaterialButton(onPressed: pickImage,color: Colors.blue,child: const Text("Pick image"),),
            MyTextField(controller: textController, hintText: "Caption", obscureText: false)
          ],
        ),
      ),
    );
  }
}
