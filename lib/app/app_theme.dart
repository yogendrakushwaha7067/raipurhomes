// ignore_for_file: deprecated_member_use

import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:flutter/material.dart';

enum AppTheme { dark, light }

final appThemeData = {
  AppTheme.light: ThemeData(
    // scaffoldBackgroundColor: pageBackgroundColor,
    brightness: Brightness.light,
    //textTheme
    fontFamily: "Manrope",
    errorColor: errorMessageColor,
    // highlightColor: const Color(0xffffc600),

    textSelectionTheme:
        const TextSelectionThemeData(selectionHandleColor: teritoryColor_),
    switchTheme: SwitchThemeData(
      thumbColor: const MaterialStatePropertyAll(teritoryColor_),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return teritoryColor_.withOpacity(0.3);
        }
        return primaryColorDark;
      }),
    ),
  ),
  AppTheme.dark: ThemeData(
    brightness: Brightness.dark,
    fontFamily: "Manrope",
    errorColor: errorMessageColor.withOpacity(0.7),
    switchTheme: SwitchThemeData(
        thumbColor: const MaterialStatePropertyAll(teritoryColor_),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return teritoryColor_.withOpacity(0.3);
          }
          return primaryColor_.withOpacity(0.2);
        })),
  )
};
