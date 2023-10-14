import 'dart:developer';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../data/Repositories/system_repository.dart';
import '../firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../utils/Notification/notification_service.dart';
import '../utils/api.dart';
import '../utils/hive_keys.dart';
import '../utils/hive_utils.dart';

void initApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      name: 'raipur-home',
      options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(
      NotificationService.onBackgroundMessageHandler);
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  await Hive.initFlutter();
  await Hive.openBox(HiveKeys.userDetailsBox);
  await Hive.openBox(HiveKeys.authBox);
  await Hive.openBox(HiveKeys.languageBox);
  await Hive.openBox(HiveKeys.themeBox);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    SharedPreferences prefr = await SharedPreferences.getInstance();
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    runApp(EntryPoint(prefr: prefr));
  });
}

// code: fr, name: French, file_name:
Future getDefaultLanguage(VoidCallback onSuccess) async {
  log("called this");
  try {
    log("--#loading default language ${HiveUtils.getLanguage()?['data']}");
    if (HiveUtils.getLanguage() == null ||
        HiveUtils.getLanguage()?['data'] == null) {
      Map result =
          await SystemRepository().fetchSystemSettings(isAnonymouse: true);
      var code = (result['data'] as List)
          .where((element) => element['type'] == "default_language")
          .toList()[0]['data'];

      await Api.post(
        url: Api.getLanguagae,
        parameter: {Api.languageCode: code},
        useAuthToken: false,
      ).then((value) {
        HiveUtils.storeLanguage({
          "code": value['data'][0]['code'],
          "data": value['data'][0]['file_name'],
          "name": value['data'][0]['name']
        });
        onSuccess.call();
      });
    } else {
      onSuccess.call();
      // log("yaaayy");
    }
  } catch (e) {
    log("Error while load default langeuage $e");
  }
}
