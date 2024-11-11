import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social/features/authentication/presentation/components/my_text_field.dart';
import 'package:social/features/profile/domain/entities/profile_user.dart';
import 'package:social/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:social/features/profile/presentation/cubit/profile_state.dart';
import 'package:social/responsive/constrained_scaffold.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileUser profileUser;
  const EditProfilePage({super.key, required this.profileUser});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController bioTextController = TextEditingController();

  PlatformFile? imagePickedFile;

  Uint8List? webImage;

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

  void updateProfil() async {
    final profileCubit = context.read<ProfileCubit>();
    final String uid = widget.profileUser.uid;
    final iamgeMobilePath = kIsWeb ? null : imagePickedFile?.path;
    final imageWebPath = kIsWeb ? imagePickedFile?.bytes : null;
    final String? newbio =
        bioTextController.text.isNotEmpty ? bioTextController.text : null;

    if (imagePickedFile != null || newbio != null) {
      profileCubit.updateProfile(
          uid: uid,
          newbio: newbio,
          imageMobilePath: iamgeMobilePath,
          imageWebBytes: imageWebPath);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(builder: (context, state) {
      if (state is ProfileLoading) {
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [CircularProgressIndicator(), Text("Loading")],
            ),
          ),
        );
      } else {
        return buildEditPage();
      }
    }, listener: (context, state) {
      if (state is ProfileLoaded) {
        Navigator.pop(context);
      }
    });
  }

  Widget buildEditPage() {
    return ConstrainedScaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
              onPressed: () {
                updateProfil();
              },
              icon: const Icon(Icons.upload))
        ],
      ),
      body: Column(
        children: [
          Center(
            child: Container(
              height: 200,
              width: 200,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  ),
              child: (!kIsWeb && imagePickedFile != null)
                  ? Image.file(
                    fit: BoxFit.cover,
                    File(imagePickedFile!.path!))
                  : (kIsWeb && webImage != null)
                      ? Image.memory(
                        fit: BoxFit.cover,
                        webImage!)
                      : CachedNetworkImage(
                          imageUrl: widget.profileUser.profileImageUrl,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person,
                            size: 72,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          imageBuilder: (context, imageProvider) =>
                              Image(
                                fit: BoxFit.cover,
                                image: imageProvider),
                        ),
            ),
          ),
          const SizedBox(height: 25,),
          Center(
            child: MaterialButton(onPressed: pickImage, color: Colors.blue,child: const Text("pick image"),)),
          const SizedBox(height: 25,),
          const Row(
            
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
            Padding(
              padding: EdgeInsets.only(left: 25),
              
              child: Text("Bio"))

          ] ),
          const SizedBox(
            height: 10,
          ),
          Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 25),
              child: MyTextField(
                  controller: bioTextController,
                  hintText: widget.profileUser.bio,
                  obscureText: false))
        ],
      ),
    );
  }
}
