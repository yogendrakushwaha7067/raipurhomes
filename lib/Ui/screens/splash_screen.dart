// import 'dart:async';

import 'dart:async';
import 'dart:developer';

import 'package:ebroker/Ui/screens/widgets/Erros/no_internet.dart';
import 'package:ebroker/app/routes.dart';
import 'package:ebroker/data/cubits/system/fetch_language_cubit.dart';
import 'package:ebroker/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:ebroker/data/model/system_settings_model.dart';
import 'package:ebroker/utils/AppIcon.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/api.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:ebroker/main.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// import '../app/routes.dart';
import 'package:ebroker/data/cubits/profile_setting_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/app.dart';
import '../../data/cubits/auth/auth_state_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  late AuthenticationState authenticationState;
  bool isTimerCompleted = false;
  bool isSettingsLoaded = false;
  bool isLanguageLoaded = false;
  @override
  void initState() {
    super.initState();

    log("--called initstate of this splash screen");
    getDefaultLanguage(
      () {
        isLanguageLoaded = true;
        setState(() {});
        log("load language true");
      },
    );

    checkIsUserAuthenticated();
    //-- ThemeToggler().addTool(context);
    Connectivity().checkConnectivity().then((value) {
      if (value == ConnectivityResult.none) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NoInternet(
              onRetry: () {
                Navigator.pushReplacementNamed(context, Routes.splash);
              },
            ),
          ),
        );
      }
    });
    startTimer();
    //get Currency Symbol from Admin Panel
    Future.delayed(Duration.zero, () {
      context
          .read<ProfileSettingCubit>()
          .fetchProfileSetting(context, Api.currencySymbol);
    });
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  void checkIsUserAuthenticated() async {
    authenticationState = context.read<AuthenticationCubit>().state;

    if (authenticationState == AuthenticationState.authenticated) {
      ///Only load sensitive details if user is authenticated
      //This call will load sensitive details with settings
      context
          .read<FetchSystemSettingsCubit>()
          .fetchSettings(isAnonymouse: false);
    } else {
//This call will hide sensitive details.
      context
          .read<FetchSystemSettingsCubit>()
          .fetchSettings(isAnonymouse: true);
    }
  }

  startTimer() async {
    Timer(
      const Duration(seconds: 3),
      () {
        isTimerCompleted = true;

        if (mounted) setState(() {});
      },
    );
  }

// @override
//  void setState(){

// }
  navigateCheck() {
    // navigateToScreen();
    if (true) {
      navigateToScreen();
    }
  }

  navigateToScreen() {
    if (context
            .read<FetchSystemSettingsCubit>()
            .getSetting(SystemSetting.maintenanceMode) ==
        "1") {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushReplacementNamed(
          Routes.maintenanceMode,
        );
      });
    } else if (authenticationState == AuthenticationState.authenticated) {
      Future.delayed(Duration.zero, () {
        Navigator.of(context)
            .pushReplacementNamed(Routes.main, arguments: {'from': "main"});
      });
    } else if (authenticationState == AuthenticationState.unAuthenticated) {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushReplacementNamed(Routes.login);
      });
    } else if (authenticationState == AuthenticationState.firstTime) {
      Future.delayed(
        Duration.zero,
        () {
          Navigator.of(context).pushReplacementNamed(Routes.onboarding);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    ); // to re-show bars
    navigateCheck();

    return BlocListener<FetchLanguageCubit, FetchLanguageState>(
      listener: (context, state) {},
      child: BlocListener<FetchSystemSettingsCubit, FetchSystemSettingsState>(
        listener: (context, state) {
          if (state is FetchSystemSettingsSuccess) {
            isSettingsLoaded = true;
            setState(() {});
          }
        },
        child: AnnotatedRegion(
          value:
              SystemUiOverlayStyle(statusBarColor: context.color.teritoryColor),
          child: Scaffold(
            backgroundColor: context.color.teritoryColor,
            body: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                      width: 150,
                      height: 150,
                      child:Image.asset(AppIcons.splashicon,fit: BoxFit.cover,)
                      // UiUtils.getSvg(
                      //   AppIcons.splashicon,
                      // )
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(vertical: 16.0),
                //   child: Align(
                //       alignment: Alignment.bottomCenter,
                //       child: UiUtils.getSvg(AppIcons.companyLogo)),
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
