import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social/features/profile/domain/entities/profile_user.dart';
import 'package:social/features/search/domain/search_repo.dart';
import 'package:social/features/search/presentation/cubit/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepo searchRepo;

  SearchCubit({required this.searchRepo}) : super(searchInitial());

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      emit(searchInitial());
      return;
    }

    try {
      emit(SearchLoading());

      // Fetch users from the repository (assuming this returns List<ProfileUser?>)
      final List<ProfileUser?> nullableUsers = await searchRepo.searchUsers(query);

      // Filter out null values and ensure the list contains only non-null ProfileUser objects
      final List<ProfileUser> nonNullableUsers = nullableUsers.whereType<ProfileUser>().toList();

      // Emit loaded state with non-nullable user list
      emit(SearchLoaded(nonNullableUsers));
    } catch (e) {
      // Emit failure state in case of an error
      emit(SearchError("Failed to load search results"));
      print('Error searching users: $e');
    }
  }
}
