import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social/features/authentication/domain/entities/app_user.dart';
import 'package:social/features/authentication/domain/repository/auth_repo.dart';
import 'package:social/features/authentication/presentation/bloc/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  AppUser? _currentUSer;
  AuthCubit({required this.authRepo}) : super(AuthInitial());

  void checkAuth() async {
    final AppUser? user = await authRepo.getCurrentUser();
    if (user != null) {
      _currentUSer = user;
      emit(Authenticated(user));
    } else {
      emit(UnAuthenticated());
    }
  }

  AppUser? get currentUser => _currentUSer;

  Future<void> login(String email, String password) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.loginWithWmailPassword(email, password);
      if (user != null) {
        _currentUSer = user;
        emit(Authenticated(user));
      } else {
        emit(UnAuthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(UnAuthenticated());
    }
  }

  Future<void> register(String name,String email,String password) async{
     try {
      emit(AuthLoading());
      final user = await authRepo.registerWithEmailPassword(name,email, password);
      if (user != null) {
        _currentUSer = user;
        emit(Authenticated(user));
      } else {
        emit(UnAuthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(UnAuthenticated());
    }

  }

  Future<void> logout() async{
    authRepo.logout();
    emit(UnAuthenticated());
  }
}
