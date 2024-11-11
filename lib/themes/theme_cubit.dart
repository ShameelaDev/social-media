 import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social/themes/dart_theme.dart';
import 'package:social/themes/light_theme.dart';

class ThemeCubit extends Cubit<ThemeData>{
  bool _isdarkMode = false;
    ThemeCubit() : super(lightMode);

    bool get isDarkMode => _isdarkMode;

    void ToogleTheme(){
      _isdarkMode = !_isdarkMode;

      if(isDarkMode){
        emit(darkMode);
      }
      else{
        emit(lightMode);
      }
    }
}