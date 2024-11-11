import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social/features/profile/domain/entities/profile_user.dart';
import 'package:social/features/profile/domain/repository/profile_repo.dart';
import 'package:social/features/profile/presentation/cubit/profile_state.dart';
import 'package:social/features/storage/domain/storage_repo.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  final StorageRepo storageRepo;
  ProfileCubit({required this.profileRepo, required this.storageRepo})
      : super(ProfileInitial());

  Future<void> fetchUserProfile(String uid) async {
    try {
      emit(ProfileLoading());
      final user = await profileRepo.fetchUserProfile(uid);

      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        emit(ProfileError("Profile not found"));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<ProfileUser?> getUserProfile(String uid) async {
    final user =await profileRepo.fetchUserProfile(uid);
    return user;
  }

  Future<void> updateProfile({required String uid, String? newbio, Uint8List? imageWebBytes,String? imageMobilePath}) async {
    emit(ProfileLoading());
    try {
      final currentUser = await profileRepo.fetchUserProfile(uid);
      if (currentUser == null) {
        emit(ProfileError("Profile not found"));
        return;
      }

      String? imageDownloadUrl;

      if(imageWebBytes != null || imageMobilePath !=null){
        if(imageMobilePath !=null){
          imageDownloadUrl =await storageRepo.uploadProfileImagePhone(imageMobilePath, uid);
        }
        else if(imageWebBytes != null){
          imageDownloadUrl = await storageRepo.uploadProfileImageWeb(imageWebBytes, uid);
        }
        if(imageDownloadUrl ==null){
          emit(ProfileError("Failed yo upload image"));
          return; 
        }
      }


      final updatedProfile =
          currentUser.copyWith(newBio: newbio ?? currentUser.bio,newImageUrl: imageDownloadUrl?? currentUser.profileImageUrl);
      await profileRepo.updateUserProfile(updatedProfile);
      await fetchUserProfile(uid);
    } catch (e) {
      emit(ProfileError("Error updating profile :" + e.toString()));
    }
  }


  Future<void> toggleFollow(String currentUserId, String targrtUserId) async{
    try{
      await profileRepo.toggleFollow(currentUserId, targrtUserId);
      
      

    }
    catch(e){
      emit(ProfileError("Error toggling follow :$e"));

    }  
  }
}
