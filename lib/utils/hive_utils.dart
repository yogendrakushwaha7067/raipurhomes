import '../data/model/user_model.dart';
import 'helper_utils.dart';
import 'hive_keys.dart';
import 'package:flutter/foundation.dart';

import 'package:hive/hive.dart';

import '../app/app_theme.dart';
import '../app/routes.dart';

class HiveUtils {
  ///private constructor
  HiveUtils._();

  static String? getJWT() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.jwtToken);
  }

  static void dontShowChooseLocationDialoge() {
    Hive.box(HiveKeys.userDetailsBox).put("showChooseLocationDialoge", false);
  }

  static isShowChooseLocationDialoge() {
    var value = Hive.box(HiveKeys.userDetailsBox).get(
      "showChooseLocationDialoge",
    );

    if (value == null) {
      return true;
    }
    return false;
  }

  static String? getUserId() {
    return Hive.box(HiveKeys.userDetailsBox).get("id").toString();
  }

  static AppTheme getCurrentTheme() {
    var current = Hive.box(HiveKeys.themeBox).get(HiveKeys.currentTheme);

    if (current == null) {
      return AppTheme.light;
    }
    if (current == "light") {
      return AppTheme.light;
    }
    if (current == "dark") {
      return AppTheme.dark;
    }
    return AppTheme.light;
  }

  static dynamic getCountryCode() {
    return Hive.box(HiveKeys.userDetailsBox).toMap()['countryCode'];
  }

  static void setProfileNotCompleted() async {
    await Hive.box(HiveKeys.userDetailsBox)
        .put(HiveKeys.isProfileCompleted, false);
  }

  static setCurrentTheme(AppTheme theme) {
    String newTheme;
    if (theme == AppTheme.light) {
      newTheme = "light";
    } else {
      newTheme = "dark";
    }
    Hive.box(HiveKeys.themeBox).put(HiveKeys.currentTheme, newTheme);
  }

  static void setUserData(Map data) async {
    await Hive.box(HiveKeys.userDetailsBox).putAll(data);
  }

  static dynamic getCityName() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.city);
  }

  static dynamic getStateName() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.stateKey);
  }

  static dynamic getCountryName() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.countryKey);
  }

  static void setJWT(String token) async {
    await Hive.box(HiveKeys.userDetailsBox).put(HiveKeys.jwtToken, token);
  }

  static UserModel getUserDetails() {
    return UserModel.fromJson(
        Map.from(Hive.box(HiveKeys.userDetailsBox).toMap()));
  }

  static setUserIsAuthenticated() {
    Hive.box(HiveKeys.authBox).put(HiveKeys.isAuthenticated, true);
  }

  static setUserIsNotAuthenticated() async {
    await Hive.box(HiveKeys.authBox).put(HiveKeys.isAuthenticated, false);
  }

  static setUserIsNotNew() {
    Hive.box(HiveKeys.authBox).put(HiveKeys.isAuthenticated, true);
    return Hive.box(HiveKeys.authBox).put(HiveKeys.isUserFirstTime, false);
  }

  static bool isLocationFilled() {
    var city = Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.city);
    var state = Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.stateKey);
    var country = Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.countryKey);

    if (city == null && state == null && country == null) {
      return false;
    } else {
      return true;
    }
  }

  static void setLocation(
      {required String city,
      required String state,
      required String country}) async {
    await Hive.box(HiveKeys.userDetailsBox).putAll({
      HiveKeys.city: city,
      HiveKeys.stateKey: state,
      HiveKeys.countryKey: country,
    });
  }

  static void clearLocation() async {
    await Hive.box(HiveKeys.userDetailsBox).putAll({
      HiveKeys.city: null,
      HiveKeys.stateKey: null,
      HiveKeys.countryKey: null,
    });
  }

  static storeLanguage(
    dynamic data,
  ) async {
    Hive.box(HiveKeys.languageBox).put(HiveKeys.currentLanguageKey, data);
    // ..put("language", data);
    return true;
  }

  static getLanguage() {
    return Hive.box(HiveKeys.languageBox).get(HiveKeys.currentLanguageKey);
  }

  // static s(context) {
  //   HiveUtils.setUserIsNotAuthenticated();
  //   HiveUtils.clear();

  //   Future.delayed(
  //     Duration.zero,
  //     () {
  //       HelperUtils.killPreviousPages(context, Routes.login, {});
  //     },
  //   );
  // }

  @visibleForTesting
  static setUserIsNew() {
    //Only testing purpose // not in production
    Hive.box(HiveKeys.authBox).put(HiveKeys.isAuthenticated, false);
    return Hive.box(HiveKeys.authBox).put(HiveKeys.isUserFirstTime, true);
  }

  static bool isUserAuthenticated() {
    //log(Hive.box(HiveKeys.authBox).toMap().toString());
    return Hive.box(HiveKeys.authBox).get(HiveKeys.isAuthenticated) ?? false;
  }

  static bool isUserFirstTime() {
    return Hive.box(HiveKeys.authBox).get(HiveKeys.isUserFirstTime) ?? true;
  }

  static logoutUser(context,
      {required VoidCallback onLogout, bool? isRedirect}) async {
    await setUserIsNotAuthenticated();
    await Hive.box(HiveKeys.userDetailsBox).clear();
    onLogout.call();
    HiveUtils.setUserIsNotAuthenticated();
    HiveUtils.clear();

    Future.delayed(
      Duration.zero,
      () {
        if (isRedirect ?? true) {
          HelperUtils.killPreviousPages(context, Routes.login, {});
        }
      },
    );
  }

  static clear() async {
    await Hive.box(HiveKeys.userDetailsBox).clear();
  }
}
