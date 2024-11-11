import 'package:social/features/authentication/domain/entities/app_user.dart';

abstract class AuthRepo {


  Future<AppUser?> loginWithWmailPassword(String email,String password);
  Future<AppUser?> registerWithEmailPassword(String name,String email, String password);
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
}