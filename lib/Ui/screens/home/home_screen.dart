import 'dart:developer';

import 'package:flutter_svg/svg.dart';

import '../userprofile/profile_screen.dart';
import '../userprofile/sell_form.dart';
import 'Widgets/property_card_big.dart';
import '../main_activity.dart';
import '../widgets/Erros/no_data_found.dart';
import '../widgets/Erros/no_internet.dart';
import '../widgets/Erros/something_went_wrong.dart';
import '../../../data/cubits/favorite/add_to_favorite_cubit.dart';
import '../../../data/cubits/property/fetch_most_viewed_properties_cubit.dart';
import '../../../data/cubits/property/fetch_promoted_properties_cubit.dart';
import '../../../data/cubits/system/fetch_system_settings_cubit.dart';
import '../../../utils/api.dart';
import '../../../utils/constant.dart';
import '../../../utils/hive_utils.dart';
import '../../../utils/responsiveSize.dart';
import '../../../utils/sliver_grid_delegate_with_fixed_cross_axis_count_and_fixed_height.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../data/cubits/favorite/fetch_favorites_cubit.dart';
import '../../../data/cubits/system/get_api_keys_cubit.dart';
import '../../../data/cubits/system/user_details.dart';
import '../../../data/model/system_settings_model.dart';
import '../../../utils/AppIcon.dart';
import 'slider_widget.dart';
import '../../../app/routes.dart';
import '../../../utils/ui_utils.dart';
import 'package:flutter/material.dart';
import '../../../data/model/category.dart';
import '../../../utils/helper_utils.dart';
import '../../../data/cubits/slider_cubit.dart';
import '../../../data/model/property_model.dart';
import '../../../data/helper/design_configs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../utils/Extensions/extensions.dart';
import '../widgets/shimmerLoadingContainer.dart';
import '../../../data/cubits/category/fetch_category_cubit.dart';
import '../../../data/cubits/property/fetch_home_properties_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<HomeScreen> {
  @override
  bool get wantKeepAlive => true;
  List<PropertyModel> propertyLocalList = [];
  late ScrollController controller;
  bool isCategoryEmpty = false;
  bool isSliderEmpty = false;
  bool isNetworkAvailable = true;
  @override
  void initState() {
    super.initState();
    context.read<GetApiKeysCubit>().fetch();
    Connectivity().onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.none) {
        isNetworkAvailable = false;
        if (mounted) setState(() {});
      } else {
        loadInitial();
        isNetworkAvailable = true;
        setState(() {});
      }
    });

    controller = ScrollController()..addListener(pageScrollListener);
    loadInitial();
  }

  loadInitial() {
    context.read<SliderCubit>().fetchSlider(context);
    context.read<FetchCategoryCubit>().fetchCategories();
    context.read<FetchMostViewedPropertiesCubit>().fetchMostViewedProperties();
    context.read<FetchPromotedPropertiesCubit>().fetchPromotedProperties();
    context.read<FetchHomePropertiesCubit>().fetchProperty();
    var setting = context
        .read<FetchSystemSettingsCubit>()
        .getSetting(SystemSetting.subscription);
    if (setting == null) {
      context
          .read<FetchSystemSettingsCubit>()
          .fetchSettings(isAnonymouse: false);
    }
    if (setting != null) {
      if (setting.length != 0) {
        String packageId = setting[0]['package_id'].toString();
        Constant.subscriptionPackageId = packageId;
      }
    }
  }
  String properyType1="Rent";
  setPropertyType(String val) {


    setState(() {
      properyType1 = val;
    });
  }
  void pageScrollListener() {
    if (controller.isEndReached()) {
      if (context.read<FetchHomePropertiesCubit>().hasMoreData()) {
        context.read<FetchHomePropertiesCubit>().fetchMoreProperty();
      }
    }
  }

  void _onTapPromotedSeeAll() {
    Navigator.pushNamed(context, Routes.promotedPropertiesScreen);
  }

  void _onTapMostViewedSeelAll() {
    Navigator.pushNamed(context, Routes.mostViewedPropertiesScreen);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    log(HiveUtils.getUserId().toString(), name: "userid");

    // HelperUtils.showSnackBarMessage(context, "Error demo",
    //     type: MessageType.error);
    // log("##");
    // HiveUtils.setUserIsNew();
    log(HiveUtils.getJWT().toString(), name: "JWT");
    bool isPromotedPropertyEmpty = false;
    bool isMostViewdPropertyEmpty = false;
    bool hasPromotedPropertyError = false;
    bool hasMostViewdPropertyError = false;
    bool hasCategoryError = false;

    bool categorySuccess = false,
        promotedSuccess = false,
        mostVSuccess = false,
        sliderSuccess = false;

    ///Watching if data is available or not
    if ((context.watch<FetchPromotedPropertiesCubit>().state
        is FetchPromotedPropertiesSuccess)) {
      promotedSuccess = true;
      isPromotedPropertyEmpty = (context
              .watch<FetchPromotedPropertiesCubit>()
              .state as FetchPromotedPropertiesSuccess)
          .propertymodel
          .isEmpty;
    }
    if ((context.watch<FetchMostViewedPropertiesCubit>().state
        is FetchMostViewedPropertiesSuccess)) {
      mostVSuccess = true;
      isMostViewdPropertyEmpty = (context
              .watch<FetchMostViewedPropertiesCubit>()
              .state as FetchMostViewedPropertiesSuccess)
          .properties
          .isEmpty;
    }

    if ((context.watch<FetchCategoryCubit>().state is FetchCategorySuccess)) {
      categorySuccess = true;
    }
    if ((context.watch<SliderCubit>().state is SliderFetchSuccess)) {
      sliderSuccess = true;
    }

    if ((context.watch<FetchPromotedPropertiesCubit>().state
        is FetchPromotedPropertiesFailure)) {
      hasPromotedPropertyError = true;
    }
    if ((context.watch<FetchMostViewedPropertiesCubit>().state
        is FetchMostViewedPropertiesFailure)) {
      hasMostViewdPropertyError = true;
    }
    if ((context.watch<FetchCategoryCubit>().state is FetchCategoryFailure)) {
      log("category error is ${(context.watch<FetchCategoryCubit>().state as FetchCategoryFailure).errorMessage}");
      hasCategoryError = true;
    }
    Widget setSearchIcon() {
      return Padding(
          padding: const EdgeInsets.all(8.0),
          child: UiUtils.getSvg(AppIcons.search,
              color: context.color.teritoryColor));
    }

    Widget searchTextField() {
      return Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Navigator.pushNamed(context, Routes.searchScreenRoute,
                  arguments: {"autoFocus": true, "openFilterScreen": false});
            },
            child: AbsorbPointer(
              absorbing: true,
              child: Container(
                  width: 270.rw(context),
                  height: 50.rh(context),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 1.5, color: context.color.borderColor),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: context.color.secondaryColor),
                  child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        border: InputBorder.none, //OutlineInputBorder()
                        fillColor: Theme.of(context).colorScheme.secondaryColor,
                        hintText: UiUtils.getTranslatedLabel(
                            context, "searchHintLbl"),
                        prefixIcon: setSearchIcon(),
                        prefixIconConstraints:
                            const BoxConstraints(minHeight: 5, minWidth: 5),
                      ),
                      enableSuggestions: true,
                      onEditingComplete: () {
                        // setState(
                        //   () {
                        //     // isFocused = false;
                        //   },
                        // );
                        FocusScope.of(context).unfocus();
                      },
                      onTap: () {
                        //change prefix icon color to primary
                      })),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, Routes.searchScreenRoute,
                  arguments: {"autoFocus": false, "openFilterScreen": true});
              // Navigator.pushNamed(
              //   context,
              //   Routes.filterScreen,
              // ).then((value) {
              //   if (value == true) {

              //   }
              // });
            },
            child: Container(
              width: 50.rw(context),
              height: 50.rh(context),
              decoration: BoxDecoration(
                border:
                    Border.all(width: 1.5, color: context.color.borderColor),
                color: context.color.secondaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: UiUtils.getSvg(AppIcons.filter,
                    color: context.color.teritoryColor),
              ),
            ),
          ),
        ],
      );
    }

    Container buildDefaultPersonSVG(BuildContext context) {
      return Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
            color: context.color.teritoryColor.withOpacity(0.1),
            shape: BoxShape.circle),
        child: Center(
          child: UiUtils.getSvg(
            AppIcons.defaultPersonLogo,
            color: context.color.teritoryColor,
            width: 20,
            height: 20,
          ),
        ),
      );
    }

    profileImgWidget() {
      return GestureDetector(
        onTap: () {
         Navigator.push(context, MaterialPageRoute(builder: (context){
           return ProfileScreen();
         }));
       //   MainActivityState.pageCntrlr.jumpToPage(4);
        },
        child: (context.watch<UserDetailsCubit>().state.user.profile ?? "")
                .trim()
                .isEmpty
            ? FittedBox(
                fit: BoxFit.none,
                child: buildDefaultPersonSVG(
                  context,
                ),
              )
            : Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                width: 50,
                height: 50,
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  context.watch<UserDetailsCubit>().state.user.profile ?? "",
                  fit: BoxFit.cover,
                  width: 50,
                  height: 50,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return FittedBox(
                      fit: BoxFit.none,
                      child: buildDefaultPersonSVG(context),
                    );
                  },
                  loadingBuilder: (BuildContext context, Widget? child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child!;
                    return FittedBox(
                      fit: BoxFit.none,
                      child: buildDefaultPersonSVG(context),
                    );
                  },
                ),
              ),
      );
    }

    return SafeArea(
      child: RefreshIndicator(
        color: context.color.teritoryColor,
        triggerMode: RefreshIndicatorTriggerMode.onEdge,
        onRefresh: () async {
          context
              .read<FetchMostViewedPropertiesCubit>()
              .fetchMostViewedProperties(forceRefresh: true);
          context.read<SliderCubit>().fetchSlider(context, forceRefresh: true);
          context
              .read<FetchCategoryCubit>()
              .fetchCategories(forceRefresh: true);
          context
              .read<FetchPromotedPropertiesCubit>()
              .fetchPromotedProperties(forceRefresh: true);
          // context.read<FetchHomePropertiesCubit>().fetchProperty(forceRefresh: true);
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            leadingWidth:
                HiveUtils.getCityName() != null ? 200.rw(context) : 80,
            leading: Padding(
              padding:HiveUtils.getCityName() != null? EdgeInsetsDirectional.only(start: 20.rw(context)):EdgeInsetsDirectional.only(start: 10.rw(context)),
              child: HiveUtils.getCityName() != null
                  ?
              FittedBox(
                      fit: BoxFit.none,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16.rw(context),
                          ),
                          Container(
                            width: 40.rw(context),
                            height: 40.rh(context),
                            decoration: BoxDecoration(
                                color: context.color.secondaryColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: UiUtils.getSvg(AppIcons.location,
                                fit: BoxFit.none,
                                color: context.color.teritoryColor),
                          ),
                          SizedBox(
                            width: 10.rw(context),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(UiUtils.getTranslatedLabel(
                                      context, "locationLbl"))
                                  .color(context.color.textColorDark)
                                  .size(context.font.small),
                              SizedBox(
                                width: 150,
                                child: Text(
                                  (HiveUtils.getCityName() +
                                          "," +
                                          HiveUtils.getStateName() +
                                          "," +
                                          HiveUtils.getCountryName()) +
                                      "",
                                  maxLines: 1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                )
                                    .color(context.color.textColorDark)
                                    .size(context.font.small)
                                    .bold(weight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : SizedBox(

                      child:Container(


                        child: SvgPicture.asset(
                            AppIcons.homeLogo,
                         // color: color,
                          fit:  BoxFit.cover,

                        ),
                      )
                      // UiUtils.getSvg(
                      //   AppIcons.homeLogo,
                      //   width: 50,height: 50
                      //
                      // ),
                    ),
            ),
            backgroundColor: const Color.fromARGB(0, 0, 0, 0),
            actions: [
              GestureDetector(
                onTap: () {
                  UiUtils.showFullScreenImage(
                    context,
                    provider: NetworkImage(
                      context.read<UserDetailsCubit>().state.user.profile!,
                    ),
                  );
                },
                child: Container(
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  margin: const EdgeInsetsDirectional.only(end: 10),
                  padding: const EdgeInsets.only(bottom: 5),
                  child:
                      FittedBox(fit: BoxFit.cover, child: profileImgWidget()),
                ),
              ),
            ],
          ),
          backgroundColor: context.color.primaryColor,
          body: Builder(builder: (context) {
            if ((hasCategoryError ||
                    hasMostViewdPropertyError ||
                    hasPromotedPropertyError) &&
                isNetworkAvailable) {
              return const SomethingWentWrong();
            }

            return BlocConsumer<FetchSystemSettingsCubit,
                FetchSystemSettingsState>(
              listener: (context, state) {
                // if (state is FetchSystemSettingsFailure) {}
                if (state is FetchCategoryInProgress) {
                  isNetworkAvailable = true;
                  setState(() {});
                }
                if (state is FetchSystemSettingsSuccess) {
                  isNetworkAvailable = true;
                  setState(() {});
                  var setting = context
                      .read<FetchSystemSettingsCubit>()
                      .getSetting(SystemSetting.subscription);
                  if (setting.length != 0) {
                    String packageId = setting[0]['package_id'].toString();
                    Constant.subscriptionPackageId = packageId;
                  }
                }
              },
              builder: (context, state) {
                if (!isNetworkAvailable) {
                  if (sliderSuccess &&
                      categorySuccess &&
                      promotedSuccess &&
                      mostVSuccess) {
                  } else {
                    return NoInternet(
                      onRetry: () {
                        context.read<SliderCubit>().fetchSlider(context);
                        context.read<FetchCategoryCubit>().fetchCategories();

                        context
                            .read<FetchMostViewedPropertiesCubit>()
                            .fetchMostViewedProperties();
                        context
                            .read<FetchPromotedPropertiesCubit>()
                            .fetchPromotedProperties();
                        context
                            .read<FetchHomePropertiesCubit>()
                            .fetchProperty();
                      },
                    );
                  }
                }
                // if (state is FetchSystemSettingsInProgress) {}

                if (isCategoryEmpty == true &&
                    isMostViewdPropertyEmpty == true &&
                    isSliderEmpty == true &&
                    isPromotedPropertyEmpty == true) {
                  return Center(
                    child: NoDataFound(
                      onTap: () {
                        context.read<SliderCubit>().fetchSlider(context);
                        context.read<FetchCategoryCubit>().fetchCategories();

                        context
                            .read<FetchMostViewedPropertiesCubit>()
                            .fetchMostViewedProperties();
                        context
                            .read<FetchPromotedPropertiesCubit>()
                            .fetchPromotedProperties();
                        context
                            .read<FetchHomePropertiesCubit>()
                            .fetchProperty();
                      },
                    ),
                  );
                }

                return SingleChildScrollView(
                    controller: controller,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).padding.top,
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: searchTextField(),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          BlocConsumer<SliderCubit, SliderState>(
                            listener: (context, state) {
                              if (state is SliderFetchSuccess) {
                                isSliderEmpty = state.sliderlist.isEmpty;
                                isNetworkAvailable = true;
                                setState(() {});
                              }
                            },
                            builder: (context, state) {
                              if (state is SliderFetchInProgress) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      CustomShimmer(
                                        height: 130.rh(context),
                                        width: context.screenWidth,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ),
                                );
                              }
                              if (state is SliderFetchFailure) {
                                return Container();
                              }
                              if (state is SliderFetchSuccess) {
                                if (state.sliderlist.isNotEmpty) {
                                  return const SliderWidget();
                                }
                              }
                              return Container();
                            },
                          ),
                          categoryWidget(),
                          if (!isPromotedPropertyEmpty)
                            buildTitleHeader(
                              onSeeAll: _onTapPromotedSeeAll,
                              title: UiUtils.getTranslatedLabel(
                                context,
                                "promotedProperties",
                              ),
                            ),
                          SizedBox(height: 10,),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              decoration: BoxDecoration(
                color: context.color.teritoryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                              ),
                              width: MediaQuery.of(context).size.width - 50.rw(context),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  //buttonSale
                                  Expanded(
                                    child: SizedBox(
                                      height: 35.rh(context),
                                      child: UiUtils.buildButton(context, onPressed: () {
                                        if (properyType1 == "Sell") {
                                          searchbody[Api.propertyType] = "";
                                          properyType1 = "";
                                          setState(() {});
                                        } else {
                                          //setPropertyType("Sell");
                                        }
                                        Navigator.push(context, MaterialPageRoute(builder: (context){
                                          return SellFormField();
                                        }));
                                      },
                                          showElevation: false,
                                          textColor: properyType1 == "Sell"
                                              ? context.color.buttonColor
                                              : context.color.textColorDark,
                                          buttonColor: properyType1 == "Sell"
                                              ? Theme.of(context).colorScheme.teritoryColor
                                              : Theme.of(context)
                                              .colorScheme
                                              .teritoryColor
                                              .withOpacity(0.0),
                                          fontSize: context.font.normal,
                                          buttonTitle: UiUtils.getTranslatedLabel(context,
                                              UiUtils.getTranslatedLabel(context, "forSaleLbl"))),
                                    ),
                                  ),
                                  //buttonRent
                                  Expanded(
                                    child: SizedBox(
                                        height: 35.rh(context),
                                        child: UiUtils.buildButton(context, onPressed: () {
                                          if (properyType1 == "Rent") {

                                            properyType1 = "";
                                            setState(() {});
                                          } else {
                                            setPropertyType("Rent");
                                          }
                                        },
                                            showElevation: false,
                                            textColor: properyType1 == "Rent"
                                                ? context.color.buttonColor
                                                : context.color.textColorDark,
                                            buttonColor: properyType1 == "Rent"
                                                ? Theme.of(context).colorScheme.teritoryColor
                                                : Theme.of(context)
                                                .colorScheme
                                                .teritoryColor
                                                .withOpacity(0.0),
                                            fontSize: context.font.normal,
                                            buttonTitle: UiUtils.getTranslatedLabel(
                                                context,
                                                UiUtils.getTranslatedLabel(
                                                    context, "forRentLbl")))),
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      height: 35.rh(context),
                                      child: UiUtils.buildButton(context, onPressed: () {
                                        if (properyType1 == "Buy") {

                                          setState(() {});
                                        } else {
                                          setPropertyType("Buy");
                                        }
                                      },
                                          showElevation: false,
                                          textColor: properyType1 == "Buy"
                                              ? context.color.buttonColor
                                              : context.color.textColorDark,
                                          buttonColor: properyType1 == "Buy"
                                              ? Theme.of(context).colorScheme.teritoryColor
                                              : Theme.of(context)
                                              .colorScheme
                                              .teritoryColor
                                              .withOpacity(0.0),
                                          fontSize: context.font.normal,
                                          buttonTitle: UiUtils.getTranslatedLabel(context,
                                              UiUtils.getTranslatedLabel(context, "forBuyLbl"))),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20,),
                          if (!isPromotedPropertyEmpty)
                            buildPromotedProperites(),
                          if (!isMostViewdPropertyEmpty)
                            // buildTitleHeader(
                            //     onSeeAll: _onTapMostViewedSeelAll,
                            //     title: UiUtils.getTranslatedLabel(
                            //         context, "mostViewed")),
                          if (!isMostViewdPropertyEmpty)
                            buildMostViewedProperties()
                        ]));
              },
            );
          }),
        ),
      ),
    );
  }

  Widget buildTitleHeader({
    required String title,
    VoidCallback? onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          top: 20.0, bottom: 16, start: 20, end: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title)
              .bold(weight: FontWeight.w700)
              .color(context.color.textColorDark)
              .size(context.font.large),
          GestureDetector(
            onTap: () {
              onSeeAll?.call();
            },
            child: Text(UiUtils.getTranslatedLabel(context, "seeAll"))
                .size(context.font.small)
                .color(context.color.textLightColor)
                .bold(weight: FontWeight.w700),
          )
        ],
      ),
    );
  }

  Widget buildPromotedProperites() {
    return BlocBuilder<FetchPromotedPropertiesCubit,
        FetchPromotedPropertiesState>(
      builder: (context, state) {
        log(state.toString(), name: "@promoted property");
        if (state is FetchPromotedPropertiesInProgress) {
          return SizedBox(
              height: 272,
              child: ListView.builder(
                  itemCount: 5,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomShimmer(
                        height: 272.rh(context),
                        width: 250.rw(context),
                      ),
                    );
                  }));
        }
        if (state is FetchPromotedPropertiesFailure) {
          return Text(state.errorMessage);
        }

        if (state is FetchPromotedPropertiesSuccess) {
          return SizedBox(
            height: 272 + 4,
            child: ListView.builder(
              itemCount: state.propertymodel.length,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                ///Model
                PropertyModel propertymodel = state.propertymodel[index];
                //print(propertymodel.properyType.toString()+"propertytype");
                return GestureDetector(
                    onTap: () {
                      HelperUtils.goToNextPage(
                        Routes.propertyDetails,
                        context,
                        false,
                        args: {
                          'propertyData': propertymodel,
                          'propertiesList': state.propertymodel,
                          'fromMyProperty': false,
                        },
                      );
                    },
                    child: BlocProvider(
                      create: (context) {
                        return AddToFavoriteCubitCubit();
                      },
                      child:

                      PropertyCardBig(
                        isFirst: index == 0,
                        property: propertymodel,
                        onLikeChange: (type) {
                          if (type == FavoriteType.add) {
                            context
                                .read<FetchFavoritesCubit>()
                                .add(state.propertymodel[index]);
                          } else {
                            context
                                .read<FetchFavoritesCubit>()
                                .remove(state.propertymodel[index].id);
                          }
                        },
                      ),
                    ));
              },
            ),
          );
        }

        return Container();
      },
    );
  }
 List<PropertyModel> listOfBuy=[];
  List<PropertyModel> listOfRent=[];

  buildMostViewedProperties() {
    return BlocConsumer<FetchMostViewedPropertiesCubit,
        FetchMostViewedPropertiesState>(
      listener: (context, state) {

        if (state is FetchMostViewedPropertiesFailure) {
          if (state.errorMessage is ApiException) {
            isNetworkAvailable =
                !(state.errorMessage.errorMessage == "no-internet");
          }

          setState(() {});
        }
        if (state is FetchMostViewedPropertiesSuccess) {
          isNetworkAvailable = true;
          setState(() {});
        }
      },
      builder: (context, state) {
        if (state is FetchMostViewedPropertiesInProgress) {
          return GridView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 162.rw(context) / 274.rh(context),
                  mainAxisSpacing: 15,
                  crossAxisCount: 2),
              itemCount: 5,
              itemBuilder: (context, index) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CustomShimmer(),
                );
              });
        }

        if (state is FetchMostViewedPropertiesFailure) {
          return Text(state.errorMessage.errorMessage.toString());
        }
        if (state is FetchMostViewedPropertiesSuccess) {

          Iterable<PropertyModel> e =   state.properties.where((element) => element.properyType.toString() == properyType1);


          print("Prash"+e.length.toString());


          return GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            physics: const NeverScrollableScrollPhysics(),

            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                    mainAxisSpacing: 15, crossAxisCount: 2, height: 274),
            itemCount: e.length ,
            itemBuilder: (context, index) {
              return
              GestureDetector(
                onTap: () {
                  PropertyModel property = e.elementAt(index);

                  HelperUtils.goToNextPage(
                      Routes.propertyDetails, context, false,
                      args: {
                        'propertyData': property,
                        'propertiesList': state.properties,
                        'fromMyProperty': false,
                      });
                },
                child: BlocProvider(
                  create: (context) => AddToFavoriteCubitCubit(),
                  child:
                  PropertyCardBig(
                    showEndPadding: false,
                    isFirst: index == 0,
                    onLikeChange: (type) {
                      if (type == FavoriteType.add) {
                        context
                            .read<FetchFavoritesCubit>()
                            .add(e.elementAt(index));
                      } else {
                        context
                            .read<FetchFavoritesCubit>()
                            .remove(e.elementAt(index).id);
                      }
                    },
                    property: e.elementAt(index),
                  ),
                ),
              ) ;
            },
          );
        }

        return Container();
      },
    );
  }

  categoryWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 44.rh(context),
          child: BlocConsumer<FetchCategoryCubit, FetchCategoryState>(
            listener: (context, state) {
              if (state is FetchCategoryFailure) {
                if (state.errorMessage == "auth-expired") {
                  HelperUtils.showSnackBarMessage(context,
                      UiUtils.getTranslatedLabel(context, "authExpired"));

                  HiveUtils.logoutUser(
                    context,
                    onLogout: () {},
                  );
                }
              }

              if (state is FetchCategorySuccess) {
                isCategoryEmpty = state.categories.isEmpty;
                setState(() {});
              }
            },
            builder: (context, state) {
              if (state is FetchCategoryInProgress) {
                return buildCategoriesShimmer();
              }
              if (state is FetchCategoryFailure) {
                return Center(
                  child: Text(state.errorMessage.toString()),
                );
              }
              if (state is FetchCategorySuccess) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: state.categories.length
                      .clamp(0, Constant.maxCategoryLength),
                  itemBuilder: (context, index) {
                    Category category = state.categories[index];
                    Constant.propertyFilter = null;
                    if (index == (Constant.maxCategoryLength - 1)) {
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(start: 5.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, Routes.categories);
                          },
                          child: Container(
                            constraints: BoxConstraints(
                              minWidth: 100.rw(context),
                            ),
                            height: 44.rh(context),
                            alignment: Alignment.center,
                            decoration: DesignConfig.boxDecorationBorder(
                              color: context.color.secondaryColor,
                              radius: 10,
                              borderWidth: 1.5,
                              borderColor: context.color.borderColor,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                  UiUtils.getTranslatedLabel(context, "more")),
                            ),
                          ),
                        ),
                      );
                    }

                    return buildCategoryCard(context, category, index != 0);
                  },
                );
              }
              return Container();
            },
          ),
        ),
      ],
    );
  }

  Widget buildCategoryCard(
      BuildContext context, Category category, bool? frontSpacing) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
          start: frontSpacing == true ? 5.0 : 0, end: .0),
      child: GestureDetector(
        onTap: (() {
          //this currentVisitingCategoryId will be usefull in filter screen, to reset when we hit clear filter button:)
          currentVisitingCategoryId = category.id;
          currentVisitingCategory = category;
          Navigator.of(context).pushNamed(Routes.propertiesList,
              arguments: {'catID': category.id, 'catName': category.category});
        }),
        child: Row(
          children: <Widget>[
            Container(
              constraints: BoxConstraints(
                minWidth: 100.rw(context),
              ),
              height: 44.rh(context),
              alignment: Alignment.center,
              decoration: DesignConfig.boxDecorationBorder(
                color: context.color.secondaryColor,
                radius: 10,
                borderWidth: 1.5,
                borderColor: context.color.borderColor,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image.network(
                    //   category.image!,
                    //   width: 20,
                    //   height: 20,
                    // ),

                    UiUtils.imageType(category.image!,
                        width: 20,
                        height: 20,
                        color: context.color.teritoryColor),

                    SizedBox(width: 12.rw(context)),
                    SizedBox(
                      child: Text(category.category!,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis)
                          .size(context.font.small),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategoriesShimmer() {
    return ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        itemBuilder: (context, index) {
          return CustomShimmer(
            width: 100.rw(context),
            height: 44.rh(context),
            margin: const EdgeInsetsDirectional.only(end: 10, bottom: 5),
          );
        });
  }

  // Widget buildAllPropertiesShimmer() {
  //   return ListView.separated(
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     padding: const EdgeInsets.symmetric(
  //       horizontal: 20,
  //     ),
  //     itemCount: 5,
  //     separatorBuilder: (context, index) {
  //       return const SizedBox(
  //         height: 12,
  //       );
  //     },
  //     itemBuilder: (context, index) {
  //       return Container(
  //         width: double.maxFinite,
  //         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(15),
  //         ),
  //         child: Row(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: <Widget>[
  //               const ClipRRect(
  //                 clipBehavior: Clip.antiAliasWithSaveLayer,
  //                 borderRadius: BorderRadius.all(Radius.circular(15)),
  //                 child: CustomShimmer(height: 90, width: 90),
  //               ),
  //               const SizedBox(
  //                 width: 10,
  //               ),
  //               Expanded(
  //                 child: LayoutBuilder(builder: (context, c) {
  //                   return Column(
  //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: <Widget>[
  //                       const SizedBox(
  //                         height: 10,
  //                       ),
  //                       CustomShimmer(
  //                         height: 10,
  //                         width: c.maxWidth - 50,
  //                       ),
  //                       const SizedBox(
  //                         height: 10,
  //                       ),
  //                       const CustomShimmer(
  //                         height: 10,
  //                       ),
  //                       const SizedBox(
  //                         height: 10,
  //                       ),
  //                       CustomShimmer(
  //                         height: 10,
  //                         width: c.maxWidth / 1.2,
  //                       ),
  //                       const SizedBox(
  //                         height: 10,
  //                       ),
  //                       CustomShimmer(
  //                         height: 12,
  //                         width: c.maxWidth / 4,
  //                       ),
  //                     ],
  //                   );
  //                 }),
  //               )
  //             ]),
  //       );
  //     },
  //   );
  // }
}
