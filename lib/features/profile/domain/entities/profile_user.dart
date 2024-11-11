import 'package:social/features/authentication/domain/entities/app_user.dart';

class ProfileUser extends AppUser {
  final String bio;
  final String profileImageUrl;
  final List<String> followers;
  final List<String> following;

  ProfileUser({
    required super.name,
    required super.uid,
    required super.email,
    required this.bio,
    required this.profileImageUrl,
    required this.followers,
    required this.following
  });

  ProfileUser copyWith({String? newBio, String? newImageUrl,List<String>? newFollowers,List<String>? newFollowing}) {
    return ProfileUser(
        name: name,
        uid: uid,
        email: email,
        bio: newBio ?? bio,
        profileImageUrl: newImageUrl ?? profileImageUrl,
        followers: newFollowers?? followers,
        following: newFollowing?? following);
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'followers' : followers,
      'following' : following
    };
  }

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
        name: json['name'],
        uid: json['uid'],
        email: json['email'],
        bio: json['bio'] ?? "",
        profileImageUrl: json['profileImageUrl'] ?? "",
        followers: List<String>.from(json['followers'] ?? []),
        following: List<String>.from(json['following'] ?? []));
  }
}
