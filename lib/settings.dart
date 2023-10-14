///eBroker configuration file
/// Configure your app from here
/// Most of basic configuration will be from here
/// For theme colors go to [lib/Ui/Theme/theme.dart]
class AppSettings {
  /// Basic Settings
  static const String applicationName = 'Raipur Homes';
  static const String andoidPackageName = 'com.raipur.home';
  static const String iOSAppId = '12345678';
  static const String playstoreURLAndroid =
      "https://play.google.com/store/apps/details?id=$andoidPackageName";
  static const String appstoreURLios = "https://apps.apple.com/";
  static const String shareAppText = "Share this App";

  ///API Setting
  static const String hostUrl =
      "http://raipurhomes.site/"; //prod-> https://dev-ebroker.thewrteam.in/
  static const String baseUrl = "${hostUrl}api/";
  static int apiDataLoadLimit = 20;
  static const int maxCategoryShowLengthInHomeScreen = 5;

  ///You will find this prefix from firebase console in dynamic link section
  static const String deepLinkPrefix =
      "https://raipurhome.page.link"; //demo.page.link
  //set anything you want
  static const String deepLinkName = "raipurhome"; //deeplink demo.com

  //////////////////
  // Add your Own API key here
  //////////////////
  //AIzaSyDMXZ-xTPm64DijUZqtVWEo_I6HDA8eviw
  static String googlePlaceAPIkey = "AIzaSyDZiDCmwSZrqgD-cFz9LEMoIotAiZm7fE4";

  ///Firebase authentication OTP timer.
  static int otpResendSecond = 60;
  static int otpTimeOutSecond = 60;

  ///This code will show on login screen [Note: don't add  + symball]
  static const String defaultCountryCode = "91";

  ///Lottie animation
  // /Put your loading json file in lib/assets/lottie/ folder
  static const String progressLottieFile = "loading.json";
  static const String progressLottieFileWhite =
      "loading_white.json"; //When there is dark background and you want to show progress so it will be used
  static const String maintenanceModeLottieFile = "maintenancemode.json";

  static const bool useLottieProgress =
      true; //if you don't want to use lottie progress then set it to false'

  ///

  ///Other settings
  static const String notificationChannel = "basic_channel"; //
  static int uploadImageQuality = 50; //0 to 100 th
  static const Set additionalRTLlanguages =
      {}; //Add language code in brackat  {"ab","bc"}

/////Advance settings
//This file is located in assets/riveAnimations
  static const String riveAnimationFile = "rive_animation.riv";

  static const Map<String, dynamic> riveAnimationConfigurations = {
    "add_button": {
      "artboard_name": "Add",
      "state_machine": "click",
      "boolean_name": "isReverse",
      "boolean_initial_value": true,
      "add_button_shape_name": "shape",
    },
    "introduction_screen": [
      {
        "artboard_name": "onbo_a",
        "state_machine": "State Machine 1",
        "boolean_name": "start",
      },
      {
        "artboard_name": "onbo_b",
        "state_machine": "State Machine 1",
        "boolean_name": "start",
      },
      {
        "artboard_name": "onbo_c",
        "state_machine": "State Machine 1",
        "boolean_name": "start",
      }
    ]
  };

  //// Don't change these
  //// Payment gatway API keys
  ///Here is for only reference you have to change it from panel
  static String enabledPaymentGatway = "";
  static String razorpayKey = "";
  static String paystackKey = ""; // public key
  static String paystackCurrency = "";
  static String paypalClientId = "";
  static String paypalServerKey = ""; //secrate
  static bool isSandBoxMode = true; //testing mode
  static String paypalCancelURL = "";
  static String paypalReturnURL = "";
}
