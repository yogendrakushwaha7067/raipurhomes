import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:ebroker/Ui/screens/proprties/Property%20tab/sell_rent_screen.dart';
import 'package:ebroker/Ui/screens/settings/notifications.dart';
import 'package:hexagon/hexagon.dart';

import 'chat/chat_list_screen.dart';
import '../../data/model/system_settings_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/cubits/system/fetch_system_settings_cubit.dart';
import 'widgets/blurred_dialoge_box.dart';
import '../../app/routes.dart';
import '../../data/Repositories/property_repository.dart';
import '../../data/cubits/property/search_property_cubit.dart';
import 'home/home_screen.dart';
import 'proprties/my_properties_screen.dart';
import 'userprofile/profile_screen.dart';
import '../../settings.dart';
import '../../utils/AppIcon.dart';
import '../../utils/Extensions/extensions.dart';
import '../../utils/hive_utils.dart';
import '../../utils/responsiveSize.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';
// import '../cubits/authCubit.dart';
import '../../data/cubits/company_cubit.dart';
// import '../helper/apiParams.dart';
import '../../utils/api.dart';
import '../../utils/constant.dart';
// import '../helper/generalMethods.dart';
import '../../utils/errorFilter.dart';
import '../../utils/helper_utils.dart';
import '../../data/model/property_model.dart';
import '../../utils/ui_utils.dart';
import 'home/search_screen.dart';

// late GlobalKey<HomeScreenState> homeKey;
List<PropertyModel> myPropertylist = [];
Map<String, dynamic> searchbody = {};
String selectedcategoryId = "0";
String selectedcategoryName = "";
dynamic selectedCategory;

//this will set when i will visit in any category
dynamic currentVisitingCategoryId = "";
dynamic currentVisitingCategory = "";

//
class MainActivity extends StatefulWidget {
  final String from;
  const MainActivity({Key? key, required this.from}) : super(key: key);

  @override
  State<MainActivity> createState() => MainActivityState();

  static Route<MainActivity> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => MainActivity(from: arguments['from'] as String));
  }
}

class MainActivityState extends State<MainActivity>
    with TickerProviderStateMixin {
  int currtab = 0;
  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final List _pageHistory = [];
   late PageController pageCntrlr;
  DateTime? currentBackPressTime;

  Artboard? artboard;

  // late Artboard _riveArtBoard;
  SMIBool? isReverse;
  StateMachineController? _controller;
  bool isAddMenuOpen = false;
  int rotateAnimationDurationMs = 2000;
  bool showSellRentButton = false;
  late final AnimationController _forSellAnimationController =
      AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 400),
          reverseDuration: const Duration(milliseconds: 400));
  late final AnimationController _forRentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 300));

  late final Animation<double> _sellTween = Tween<double>(begin: -50, end: 80)
      .animate(CurvedAnimation(
          parent: _forSellAnimationController, curve: Curves.easeIn));
  late final Animation<double> _rentTween = Tween<double>(begin: -50, end: 30)
      .animate(
          CurvedAnimation(parent: _forRentController, curve: Curves.easeIn));
  Map<String, dynamic> riveConfig = AppSettings.riveAnimationConfigurations;
  late var addButtonConfig = riveConfig['add_button'];
  late var artboardName = addButtonConfig['artboard_name'];
  late var stateMachine = addButtonConfig['state_machine'];
  late var booleanName = addButtonConfig['boolean_name'];
  late var booleanInitialValue = addButtonConfig['boolean_initial_value'];
  late var addButtonShapeName = addButtonConfig['add_button_shape_name'];
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    var settings = context.read<FetchSystemSettingsCubit>();

    var numberWithSuffix = settings.getSetting(SystemSetting.numberWithSuffix);
    Constant.isNumberWithSuffix = numberWithSuffix == "1" ? true : false;

    ///this will check if your profile is complete or not if it is incomplete it will redirect you to the edit profile page
    completeProfileCheck();

    ///This will check for update
    versionCheck(settings);

    ///This will check if location is set or not , If it is not set it will show popup dialoge so you can set for better result
    locationSetCheck();

//Initializing rive animations
    initRiveAddButtonAnimation();

//This will init page controller
    initPageController();

    //get maintenance mode from Admin Panel
    // Future.delayed(Duration.zero, () {
    //   // checkForMaintenanceMode();
    // });
    context.read<CompanyCubit>().fetchCompany(
        context); //getCompanyData @ Start [specially for contact number]
  }

  void initPageController() {
    pageCntrlr = PageController(initialPage: 0)
      ..addListener(() {
        _pageHistory.insert(0, pageCntrlr.page);
      });
  }

  void initRiveAddButtonAnimation() {
    ///Open file
    rootBundle
        .load("assets/riveAnimations/${Constant.riveAnimation}")
        .then((value) {
      ///Import that data to this method below
      RiveFile riveFile = RiveFile.import(value);

      ///artboard by name you can check https://rive.app and learn it for more information
      /// Here Add is artboard name from that workspace
      artboard = riveFile.artboardByName(artboardName);
      artboard?.forEachComponent((child) {
        if (child is Shape && child.name == addButtonShapeName) {
          final Shape shape = child;
          shape.fills.first.paint.color = context.color.teritoryColor;
        }
      });

      ///in rive there is state machine to control states of animation, like. walking,running, and more
      ///click is state machine name
      _controller =
          StateMachineController.fromArtboard(artboard!, stateMachine);
      // _controller.
      if (_controller != null) {
        artboard?.addController(_controller!);

        //this SMI means State machine input, we can create conditions in rive , so isReverse is boolean value name from there
        isReverse = _controller?.findSMI(booleanName);

        ///this is optional it depends on your conditions you can change this whole conditions and values,
        ///for this animation isReverse =true means it will play its idle animation
        isReverse?.value = booleanInitialValue;

        ///here we can change color of any shape, here 'shape' is name in rive.app file
      }
      setState(() {});
    });
  }

  void completeProfileCheck() {
    if (HiveUtils.getUserDetails().name == "" ||
        HiveUtils.getUserDetails().email == "") {
      Future.delayed(
        const Duration(milliseconds: 100),
        () {
          Navigator.pushReplacementNamed(context, Routes.completeProfile,
              arguments: {"from": "login"});
        },
      );
    }
  }

  void versionCheck(settings) async {
    var remoteVersion = settings.getSetting(Platform.isIOS
        ? SystemSetting.iosVersion
        : SystemSetting.androidVersion);
    var remote = remoteVersion;

    var forceUpdate = settings.getSetting(SystemSetting.forceUpdate);

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    var current = packageInfo.version;

    int currentVersion = HelperUtils.comparableVersion(packageInfo.version);
    if (remoteVersion == null) {
      return;
    }
    remoteVersion = HelperUtils.comparableVersion(
      remoteVersion,
    );

    log("AA$remoteVersion > $currentVersion");
    if (remoteVersion > currentVersion) {
      Constant.isUpdateAvailable = true;
      Constant.newVersionNumber = settings.getSetting(
        Platform.isIOS
            ? SystemSetting.iosVersion
            : SystemSetting.androidVersion,
      );

      Future.delayed(
        Duration.zero,
        () {
          if (forceUpdate == "1") {
            ///This is force update
            UiUtils.showBlurredDialoge(context,
                dialoge: BlurredDialogBox(
                    onAccept: () async {
                      await launchUrl(Uri.parse(
                        Constant.playstoreURLAndroid,
                      ));
                    },
                    backAllowedButton: false,
                    svgImagePath: AppIcons.update,
                    isAcceptContainesPush: true,
                    svgImageColor: context.color.teritoryColor,
                    showCancleButton: false,
                    title: "updateAvailable".translate(context),
                    acceptTextColor: context.color.buttonColor,
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("$current>$remote"),
                        Text("newVersionAvailableForce".translate(context),
                            textAlign: TextAlign.center),
                      ],
                    )));
          } else {
            UiUtils.showBlurredDialoge(
              context,
              dialoge: BlurredDialogBox(
                onAccept: () async {
                  await launchUrl(Uri.parse(Constant.playstoreURLAndroid));
                },
                svgImagePath: AppIcons.update,
                svgImageColor: context.color.teritoryColor,
                showCancleButton: true,
                title: "updateAvailable".translate(context),
                content: Text(
                  "newVersionAvailable".translate(context),
                ),
              ),
            );
          }
        },
      );
    }
  }

  void locationSetCheck() {
    if (HiveUtils.isShowChooseLocationDialoge() &&
        !HiveUtils.isLocationFilled()) {
      Future.delayed(
        Duration.zero,
        () {
          UiUtils.showBlurredDialoge(
            context,
            dialoge: BlurredDialogBox(
              title: UiUtils.getTranslatedLabel(context, "setLocation"),
              content: StatefulBuilder(builder: (context, update) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      UiUtils.getTranslatedLabel(
                        context,
                        "setLocationforBetter",
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          fillColor: MaterialStatePropertyAll(
                              context.color.teritoryColor),
                          value: isChecked,
                          onChanged: (value) {
                            isChecked = value ?? false;
                            update(() {});
                          },
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(UiUtils.getTranslatedLabel(
                            context, "dontshowagain"))
                      ],
                    ),
                  ],
                );
              }),
              isAcceptContainesPush: true,
              onCancel: () {
                if (isChecked == true) {
                  HiveUtils.dontShowChooseLocationDialoge();
                }
              },
              onAccept: () async {
                if (isChecked == true) {
                  HiveUtils.dontShowChooseLocationDialoge();
                }
                Navigator.pop(context);

                Navigator.pushNamed(context, Routes.completeProfile,
                    arguments: {
                      "from": "chooseLocation",
                      "navigateToHome": true
                    });
              },
            ),
          );
        },
      );
    }
  }

  @override
  void didChangeDependencies() {
    ErrorFilter.setContext(context);

    artboard?.forEachComponent((child) {
      if (child is Shape && child.name == addButtonShapeName) {
        final Shape shape = child;

        shape.fills.first.paint.color = context.color.teritoryColor;
      }
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    pageCntrlr.dispose();
    super.dispose();
  }

  checkForMaintenanceMode() async {
    Map<String, String> body = {
      Api.type: Api.maintenanceMode,
    };

    var response = await HelperUtils.sendApiRequest(
      Api.apiGetSystemSettings,
      body,
      true,
      context,
    );
    var getdata = json.decode(response);
    if (getdata != null) {
      if (!getdata[Api.error]) {
        Constant.maintenanceMode = getdata['data'].toString();
        if (Constant.maintenanceMode == "1") {
          setState(() {});
          // Widgets.showMaintainanceDialog(context);
        }
      }
    }
  }

  List<Widget> pages = [
    const HomeScreen(),
    const ChatListScreen(),
    const Text(""),
    const Notifications(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: WillPopScope(
        onWillPop: () async {
          DateTime now = DateTime.now();
          if (currentBackPressTime == null ||
              now.difference(currentBackPressTime!) >
                  const Duration(seconds: 2)) {
            currentBackPressTime = now;
            Fluttertoast.showToast(
              msg: "pressAgainToExit".translate(context),
            );
            return Future.value(false);
          }

          return Future.value(true);
        },
        child: Scaffold(
          backgroundColor: context.color.primaryColor,
          bottomNavigationBar:
              Constant.maintenanceMode == "1" ? null : bottomBar(),
          body: Stack(
            children: <Widget>[
              PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: pageCntrlr,
                onPageChanged: onItemTapped,
                children: pages,

              ),
              if (Constant.maintenanceMode == "1")
                Container(
                  color: Theme.of(context).colorScheme.primaryColor,
                ),
              // if (showSellRentButton == true)
              SizedBox(
                width: double.infinity,
                height: context.screenHeight,
                child: Stack(
                  children: [
                    AnimatedBuilder(
                        animation: _forRentController,
                        builder: (context, c) {
                          return Positioned(
                            bottom: _rentTween.value,
                            left: (context.screenWidth / 2) - (181 / 2),
                            child: GestureDetector(
                              onTap: () {
                                Constant.addProperty.addAll(
                                    {"propertyType": PropertyType.rent});
                                log("c$ref");
                                Navigator.pushNamed(
                                  context,
                                  Routes.selectPropertyTypeScreen,
                                );
                              },
                              child: Container(
                                  width: 181,
                                  height: 44,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: context.color.borderColor,
                                          width: 1.5),
                                      boxShadow: [
                                        BoxShadow(
                                            color: context.color.teritoryColor
                                                .withOpacity(0.4),
                                            offset: const Offset(0, 3),
                                            blurRadius: 10,
                                            spreadRadius: 0)
                                      ],
                                      color: context.color.teritoryColor,
                                      borderRadius: BorderRadius.circular(22)),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      UiUtils.getSvg(AppIcons.forRent),
                                      SizedBox(
                                        width: 7.rw(context),
                                      ),
                                      Text(UiUtils.getTranslatedLabel(
                                              context, "forRent"))
                                          .color(context.color.buttonColor),
                                    ],
                                  )),
                            ),
                          );
                        }),
                    AnimatedBuilder(
                        animation: _forSellAnimationController,
                        builder: (context, c) {
                          return Positioned(
                            bottom: _sellTween.value,
                            left: (context.screenWidth / 2) - 128 / 2,
                            child: GestureDetector(
                              onTap: () {
                                Constant.addProperty.addAll(
                                  {
                                    "propertyType": PropertyType.sell,
                                  },
                                );

                                Navigator.pushNamed(
                                  context,
                                  Routes.selectPropertyTypeScreen,
                                );
                              },
                              child: Container(
                                width: 128,
                                height: 44,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: context.color.borderColor,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: context.color.teritoryColor
                                            .withOpacity(0.4),
                                        offset: const Offset(0, 3),
                                        blurRadius: 10,
                                        spreadRadius: 0,
                                      )
                                    ],
                                    color: context.color.teritoryColor,
                                    borderRadius: BorderRadius.circular(22)),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    UiUtils.getSvg(AppIcons.forSale),
                                    SizedBox(
                                      width: 7.rw(context),
                                    ),
                                    Text(UiUtils.getTranslatedLabel(
                                            context, "forSell"))
                                        .color(context.color.buttonColor),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                  ],
                ),
              )
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.teritoryColor,
            onPressed: (){
            Constant.addProperty.addAll(
                {"propertyType": PropertyType.rent});
            log("c$ref");
            Navigator.pushNamed(
              context,
              Routes.selectPropertyTypeScreen,
            );
          },
          child: Center(child: Text("Add\nRent Property",style: TextStyle(fontSize: 8),textAlign: TextAlign.center,),),
          ),
        ),
      ),
    );
  }

  void onItemTapped(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    isReverse?.value = true;
    _forSellAnimationController.reverse();
    _forRentController.reverse();

    if (index != 1) {
      context.read<SearchPropertyCubit>().clearSearch();
      SearchScreenState.searchController.text = "";
    }

    if (index == 2) {
      Navigator.of(context).pushNamed(Routes.addPropertyScreenRoute);
    } else {
      searchbody = {};
      setState(() {
        currtab = index;
      });
      pageCntrlr.jumpToPage(currtab);
    }
  }

  bottomBar() {
    return BottomAppBar(
      // notchMargin: 10.0,

      color: context.color.secondaryColor,
      shape: const CircularNotchedRectangle(),
      child: Container(
        color: context.color.secondaryColor,
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              buildBottomNavigationbarItem(0, AppIcons.home,
                  UiUtils.getTranslatedLabel(context, "homeTab")),
              buildBottomNavigationbarItem(1, AppIcons.chat,
                  UiUtils.getTranslatedLabel(context, "chat")),
              // const SizedBox(
              //   width: 100,
              //   height: 100,
              //   child: RiveAnimation.asset(
              //     "",
              //     artboard: "Add",
              //   ),
              // ),

              Transform(
                transform: Matrix4.identity()..translate(0.toDouble(), -20),
                child: GestureDetector(
                  onTap: () async {
                    if (isReverse?.value == true) {
                      isReverse?.value = true;
                      showSellRentButton = true;
                      // _forRentController.forward();
                      // _forSellAnimationController.forward();
                      Navigator.pushNamed(context, Routes.favoritesScreen);
                    }
                    else {
                      showSellRentButton = false;
                      isReverse?.value = true;
                      _forRentController.reverse();
                      _forSellAnimationController.reverse();
                    }
                    // setState(() {});
                  },
                  child: SizedBox(
                      width: 55.rw(context),
                      height: 66,
                      child: artboard == null
                          ? Container()
                          : HexagonWidget.pointy(
                           width: 50.rw(context),
                           color: Theme.of(context).colorScheme.teritoryColor,
                           elevation: 2,
                           child: Icon(Icons.favorite_border,color: Colors.white,),
                      ),

                  ),
                ),
              ),

              buildBottomNavigationbarItem(3, AppIcons.notification,"Notification"
                  // UiUtils.getTranslatedLabel(context, "properties")
              ),
              buildBottomNavigationbarItem(4, AppIcons.profile,
                  UiUtils.getTranslatedLabel(context, "profileTab"))
            ]),
      ),
    );
  }

  Widget buildBottomNavigationbarItem(
    int index,
    String svgImage,
    String title,
  ) {
    return Expanded(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () async {
            if(index==1){

                var contact = "+917599999957";
                var androidUrl = "whatsapp://send?phone=$contact&text=Hi, I need some help";
                var iosUrl = "https://wa.me/$contact?text=${Uri.parse('Hi, I need some help')}";

                try{
                  if(Platform.isIOS){
                    await launchUrl(Uri.parse(iosUrl));
                  }
                  else{
                    await launchUrl(Uri.parse(androidUrl));
                  }
                } on Exception{
               //   EasyLoading.showError('WhatsApp is not installed.');
                }
              }
            // else if(index==3){
            //   Navigator.pushNamed(context, Routes.notificationPage);
            // }

            else{
              onItemTapped(index);
            }

          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (currtab == index) ...{
                UiUtils.getSvg(svgImage, color: context.color.teritoryColor),
              } else ...{
                UiUtils.getSvg(svgImage, color: context.color.textLightColor),
              },
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
              ).color(currtab == index
                  ? context.color.teritoryColor
                  : context.color.textLightColor),
            ],
          ),
        ),
      ),
    );
  }
}
