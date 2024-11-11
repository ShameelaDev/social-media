import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social/features/profile/domain/entities/profile_user.dart';
import 'package:social/features/profile/domain/repository/profile_repo.dart';

class FirebaseProfileRepo implements ProfileRepo {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<ProfileUser?> fetchUserProfile(String uid) async {
    try {
      final userDoc =
          await firebaseFirestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data();

        if (userData != null) {

          final followers = List<String>.from(userData['followers'] ?? []);
          final following = List<String>.from(userData['following'] ?? []);

          return ProfileUser(
              name: userData['name'],
              uid: userData['uid'],
              email: userData['email'],
              bio: userData['bio'] ?? "",
              profileImageUrl: userData['profileImageUrl'] ?? "",
              followers: followers,
              following: following);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateUserProfile(ProfileUser updatedProfile) async {
   try{
     await firebaseFirestore.collection('users').doc(updatedProfile.uid).update({
      'bio': updatedProfile.bio,
      'profileImageUrl': updatedProfile.profileImageUrl
    });
   }
   catch(e){
    throw Exception(e);
   }
  }

  @override
  Future<void> toggleFollow(String currentUid, String targetUid) async{
    try{
      final currentUserDoc = await firebaseFirestore.collection('users').doc(currentUid).get();
    final targetUserDoc =await firebaseFirestore.collection('users').doc(targetUid).get();

    if(currentUserDoc.exists && targetUserDoc.exists){
      final currentUserData = currentUserDoc.data();
      final tagetUserData = targetUserDoc.data();

      if(currentUserData != null && tagetUserData != null){ 
        final List<String> currentFollowing = List<String>.from(currentUserData['following'] ?? []);

        if(currentFollowing.contains(targetUid)){
          await firebaseFirestore.collection('users').doc(currentUid).update({'following': FieldValue.arrayRemove([targetUid])});
          await firebaseFirestore.collection('users').doc(targetUid).update({'followers': FieldValue.arrayRemove([currentUid])});

        }
        else{
          await firebaseFirestore.collection('users').doc(currentUid).update({'following': FieldValue.arrayUnion([targetUid])});
          await firebaseFirestore.collection('users').doc(targetUid).update({'followers': FieldValue.arrayUnion([currentUid])});

        }

      }

    }
    }
    catch(e){

    }


    
  }
}
