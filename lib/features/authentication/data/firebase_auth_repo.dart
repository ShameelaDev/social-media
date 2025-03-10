import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social/features/authentication/domain/entities/app_user.dart';
import 'package:social/features/authentication/domain/repository/auth_repo.dart';

class FirebaseAuthRepo implements AuthRepo{

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firebaseFirestore =FirebaseFirestore.instance;
  @override
  Future<AppUser?> loginWithWmailPassword(String email, String password) async{
   try{
    UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    DocumentSnapshot userDoc =await firebaseFirestore.collection('users').doc(userCredential.user!.uid).get();
     AppUser user = AppUser(uid: userCredential.user!.uid, email: email, name: userDoc['name']);
     return user;

   }
   catch(e){
    throw Exception('Login failed :$e');

   }
  }
  @override
  Future<AppUser?> registerWithEmailPassword(String name, String email, String password) async{
   try{
    UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
     AppUser user = AppUser(uid: userCredential.user!.uid, email: email, name:name);
     await firebaseFirestore.collection('users').doc(user.uid).set(user.toJson());
     return user;

   }
   catch(e){
    throw Exception('Login failed :$e');

   }
  }
  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();

  }
  @override
  Future<AppUser?> getCurrentUser()async {
final firebaseUser = firebaseAuth.currentUser;
if(firebaseUser == null){
  return null;
}
DocumentSnapshot userDoc = await firebaseFirestore.collection('users').doc(firebaseUser.uid).get();
return AppUser(uid: firebaseUser.uid, email: firebaseUser.email!, name: userDoc['name']);

  }
}