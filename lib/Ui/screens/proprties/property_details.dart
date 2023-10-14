// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:ebroker/Ui/screens/chat/chat_screen.dart';
import 'package:ebroker/Ui/screens/proprties/Property%20tab/sell_rent_screen.dart';
import 'package:ebroker/data/cubits/chatCubits/load_chat_messages.dart';
import 'package:ebroker/data/cubits/property/update_property_status.dart';
import 'package:ebroker/utils/string_extenstion.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart' as urllauncher;

import 'package:ebroker/Ui/screens/widgets/blurred_dialoge_box.dart';
import 'package:ebroker/Ui/screens/widgets/like_button_widget.dart';
import 'package:ebroker/Ui/screens/widgets/read_more_text.dart';
import 'package:ebroker/app/routes.dart';
import 'package:ebroker/data/cubits/enquiry/send_enquiry_cubit.dart';
import 'package:ebroker/data/cubits/enquiry/store_enqury_id.dart';
import 'package:ebroker/data/cubits/favorite/add_to_favorite_cubit.dart';
import 'package:ebroker/data/cubits/property/Interest/change_interest_in_property_cubit.dart';
import 'package:ebroker/data/cubits/property/delete_property_cubit.dart';
import 'package:ebroker/Ui/screens/widgets/panaroma_image_view.dart';
import 'package:ebroker/data/cubits/property/fetch_my_properties_cubit.dart';
import 'package:ebroker/data/cubits/property/set_property_view_cubit.dart';
import 'package:ebroker/utils/AppIcon.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/api.dart';
import 'package:ebroker/utils/constant.dart';
import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/foundation.dart' as f;
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../data/cubits/chatCubits/send_message.dart';
import '../../../data/model/category.dart';
import '../../../utils/helper_utils.dart';
import '../../../data/helper/widgets.dart';
import '../../../utils/ui_utils.dart';
import '../analytics/analytics_screen.dart';
import '../widgets/AnimatedRoutes/blur_page_route.dart';
import '../widgets/all_gallary_image.dart';
import '../widgets/video_view_screen.dart';

class PropertyDetails extends StatefulWidget {
  final PropertyModel? propertyData;
  final bool? fromMyProperty;
  final bool? fromCompleteEnquiry;
  final bool fromSlider;
  const PropertyDetails(
      {Key? key,
      required this.propertyData,
      this.fromSlider = false,
      this.fromMyProperty,
      this.fromCompleteEnquiry})
      : super(key: key);

  @override
  PropertyDetailsState createState() => PropertyDetailsState();

  static Route route(RouteSettings routeSettings) {
    try {
      Map? arguments = routeSettings.arguments as Map?;
      return BlurredRouter(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => ChangeInterestInPropertyCubit(),
            ),
            BlocProvider(
              create: (context) => UpdatePropertyStatusCubit(),
            ),
            BlocProvider(
              create: (context) => DeletePropertyCubit(),
            ),
          ],
          child: PropertyDetails(
            propertyData: arguments?['propertyData'],
            fromMyProperty: arguments?['fromMyProperty'] ?? false,
            fromSlider: arguments?['fromSlider'] ?? false,
            fromCompleteEnquiry: arguments?['fromCompleteEnquiry'] ?? false,
          ),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}

class PropertyDetailsState extends State<PropertyDetails>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  FlickManager? flickManager;
  // late Property propertyData;
  bool favoriteInProgress = false;
  bool isPlayingYoutubeVideo = false;
  bool fromMyProperty = false; //get its value from Widget
  bool fromCompleteEnquiry = false; //get its value from Widget
  List promotedProeprtiesIds = [];
  bool toggleEnqButton = false;
  PropertyModel? property;
  bool isPromoted = false;
  bool showGoogleMap = false;
  bool isEnquiryFromChat = false;

  @override
  bool get wantKeepAlive => true;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  List<Gallery>? gallary;
  String youtubeVideoThumbnail = "";

  @override
  void initState() {

    super.initState();
    // customListenerForConstant();
    //add title image along with gallary images1
    Future.delayed(
      const Duration(seconds: 3),
      () {
        showGoogleMap = true;
        if (mounted) setState(() {});
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      gallary = List.from(property!.gallery!);
      if (property?.video != "") {
        injectVideoInGallary();
        setState(() {});
      }
    });

    if (widget.fromSlider) {

      getProperty();
    } else {
      property = widget.propertyData;
      setData();
    }

    setViewdProperty();
    if (property?.video != "" &&
        property?.video != null &&
        !HelperUtils.isYoutubeVideo(property?.video ?? "")) {
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.network(
          property!.video!,
        ),
      );
    }

    if (property?.video != "" &&
        property?.video != null &&
        HelperUtils.isYoutubeVideo(property?.video ?? "")) {
      String? videoId = YoutubePlayer.convertUrlToId(property!.video!);
      String thumbnail = YoutubePlayer.getThumbnail(videoId: videoId!);
      youtubeVideoThumbnail = thumbnail;
      setState(() {});
    }
  }

  getProperty() async {

    var response = await HelperUtils.sendApiRequest(
        Api.apiGetProprty,
        {
          Api.id: widget.propertyData!.id,
        },
        true,
        context,
        passUserid: false);

    if (response != null) {
      var getdata = json.decode(response);
      if (!getdata[Api.error]) {
        getdata['data'];
        setData();
        setState(() {});
      }
    }
  }

  setData() {
    fromMyProperty = widget.fromMyProperty!;
    fromCompleteEnquiry = widget.fromCompleteEnquiry!;
  }

  void setViewdProperty() {
    if (property!.addedBy.toString() != HiveUtils.getUserId()) {
      context.read<SetPropertyViewCubit>().set(property!.id!.toString());
    }
  }

  late final CameraPosition _kInitialPlace = CameraPosition(
    target: LatLng(
      double.parse(
        (property?.latitude ?? "0"),
      ),
      double.parse(
        (property?.longitude ?? "0"),
      ),
    ),
    zoom: 14.4746,
  );

  @override
  void dispose() {
    flickManager?.dispose();

    super.dispose();
  }

  injectVideoInGallary() {
    ///This will inject video in image list just like another platforms
    ///
    if ((gallary?.length ?? 0) < 2) {
      if (property?.video != null) {
        gallary?.add(Gallery(
            id: 99999999999,
            image: property!.video ?? "",
            imageUrl: "",
            isVideo: true));
      }
    } else {
      gallary?.insert(
          2,
          Gallery(
              id: 99999999999,
              image: property!.video!,
              imageUrl: "",
              isVideo: true));
    }

    setState(() {});
  }

  _statusFilter(String value) {
    if (value == "Sell") {
      return "sold".translate(context);
    }
    if (value == "Rent") {
      return "Rented".translate(context);
    }

    // if (f.kDebugMode) if (value == "Sold") {
    //   return "Sell".translate(context);
    // }
    return null;
  }

  _getStatus(type) {
    int? value;
    if (type == "Sell") {
      value = 2;
    } else if (type == "Rent") {
      value = 3;
    } else if (type == "Rented") {
      value = 1;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {

    super.build(context);
    return WillPopScope(
      onWillPop: () async {
        showGoogleMap = false;
        setState(() {});

        _delayedPop(context);
        return false;
      },
      child: AnnotatedRegion(
        value: UiUtils.getSystemUiOverlayStyle(
          context: context,
        ),
        child: SafeArea(
            child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: const Color(0x00000000),
            leading: GestureDetector(
              onTap: () {
                if (favoriteInProgress) return;

                _delayedPop(context);
              },
              child: SizedBox(
                width: 40,
                height: 50,
                child: UiUtils.getSvg(
                  AppIcons.arrowLeft,
                  color: context.color.teritoryColor,
                  fit: BoxFit.none,
                ),
              ),
            ),
            actions: [
              if (int.parse(HiveUtils.getUserId() ?? "0") == property?.addedBy)
                IconButton(
                    onPressed: () {
                      Navigator.push(context, BlurredRouter(
                        builder: (context) {
                          return AnalyticsScreen(
                            interestUserCount: widget
                                .propertyData!.totalInterestedUsers
                                .toString(),
                          );
                        },
                      ));
                    },
                    icon: Icon(
                      Icons.analytics,
                      color: context.color.teritoryColor,
                    )),
              IconButton(
                onPressed: () {
                  HelperUtils.share(
                    context,
                    property!.id!,
                  );
                },
                icon: Icon(
                  Icons.share,
                  color: context.color.teritoryColor,
                ),
              ),
              if (property?.addedBy.toString() == HiveUtils.getUserId() &&
                  property!.properyType != "Sold")
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    // UiUtils.showBlurredDialoge(context, dialoge: BlurredDialogBox(title: "Change property status", content: Text("status will be updated to Sold")));
                    var action = await UiUtils.showBlurredDialoge(
                      context,
                      dialoge: BlurredDialogBuilderBox(
                          title: "changePropertyStatus".translate(context),
                          acceptButtonName: "change".translate(context),
                          contentBuilder: (context, s) {
                            // log((s.maxWidth / 4).toString(), name: "@SS");
                            return FittedBox(
                              fit: BoxFit.none,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        color: context.color.teritoryColor,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    width: s.maxWidth / 4,
                                    height: 50,
                                    child: Center(
                                        child: Text(property!.properyType!
                                                .translate(context))
                                            .color(context.color.buttonColor)),
                                  ),
                                  Text("toArrow".translate(context)),
                                  Container(
                                    width: s.maxWidth / 4,
                                    decoration: BoxDecoration(
                                        color: context.color.teritoryColor
                                            .withOpacity(0.4),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    height: 50,
                                    child: Center(
                                        child: Text(_statusFilter(
                                                property!.properyType!))
                                            .color(context.color.buttonColor)),
                                  ),
                                ],
                              ),
                            );
                          }),
                    );
                    if (action == true) {
                      Future.delayed(Duration.zero, () {
                        context.read<UpdatePropertyStatusCubit>().update(
                              propertyId: property!.id,
                              status: _getStatus(property!.properyType),
                            );
                      });
                    }
                  },
                  color: context.color.secondaryColor,
                  itemBuilder: (BuildContext context) {
                    return {
                      'changeStatus'.translate(context),
                    }.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        textStyle:
                            TextStyle(color: context.color.textColorDark),
                        child: Text(choice),
                      );
                    }).toList();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Icon(
                      Icons.more_vert_rounded,
                      color: context.color.teritoryColor,
                    ),
                  ),
                ),
              const SizedBox(
                width: 10,
              )
            ],
          ),
          backgroundColor: context.color.backgroundColor,
          floatingActionButton: (property == null ||
                  property!.addedBy.toString() == HiveUtils.getUserId())
              ? const SizedBox.shrink()
              : Container(),
          bottomNavigationBar: isPlayingYoutubeVideo == false
              ? BottomAppBar(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: context.color.secondaryColor,
                  child: bottomNavBar())
              : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          body: BlocListener<DeletePropertyCubit, DeletePropertyState>(
            listener: (context, state) {
              if (state is DeletePropertyInProgress) {
                Widgets.showLoader(context);
              }

              if (state is DeletePropertySuccess) {
                Widgets.hideLoder(context);
                Future.delayed(
                  const Duration(milliseconds: 1000),
                  () {
                    Navigator.pop(context, true);
                  },
                );
              }
              if (state is DeletePropertyFailure) {
                Widgets.showLoader(context);
              }
            },
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: BlocListener<UpdatePropertyStatusCubit,
                    UpdatePropertyStatusState>(
                  listener: (context, state) {
                    if (state is UpdatePropertyStatusInProgress) {
                      Widgets.showLoader(context);
                    }

                    if (state is UpdatePropertyStatusSuccess) {
                      Widgets.hideLoder(context);
                      Fluttertoast.showToast(
                          msg: "statusUpdated".translate(context),
                          backgroundColor: successMessageColor,
                          gravity: ToastGravity.TOP,
                          toastLength: Toast.LENGTH_LONG);

                      (cubitReference as FetchMyPropertiesCubit)
                          .updateStatus(property!.id!, property!.properyType!);
                      setState(() {});
                    }
                    if (state is UpdatePropertyStatusFail) {
                      Widgets.hideLoder(context);
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isPlayingYoutubeVideo == false ? 20.0 : 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isPlayingYoutubeVideo)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: SizedBox(
                                  height: 227.rh(context),
                                  child: Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          // google map doesn't allow blur so we hide it:)
                                          showGoogleMap = false;
                                          setState(() {});
                                          UiUtils.showFullScreenImage(
                                            context,
                                            provider: NetworkImage(
                                              property!.titleImage!,
                                            ),
                                            then: () {
                                              showGoogleMap = true;
                                              setState(() {});
                                            },
                                          );
                                        },
                                        child: UiUtils.getImage(
                                          property!.titleImage!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 227.rh(context),
                                          showFullScreenImage: true,
                                        ),
                                      ),
                                      PositionedDirectional(
                                        top: 20,
                                        end: 20,
                                        child: LikeButtonWidget(
                                          onStateChange:
                                              (AddToFavoriteCubitState state) {
                                            if (state
                                                is AddToFavoriteCubitInProgress) {
                                              favoriteInProgress = true;
                                              setState(
                                                () {},
                                              );
                                            } else {
                                              favoriteInProgress = false;
                                              setState(
                                                () {},
                                              );
                                            }
                                          },
                                          property: property!,
                                        ),
                                      ),
                                      PositionedDirectional(
                                        bottom: 5,
                                        end: 18,
                                        child: Visibility(
                                          visible: property?.threeDImage != "",
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                BlurredRouter(
                                                  builder: (context) =>
                                                      PanaromaImageScreen(
                                                    imageUrl:
                                                        property!.threeDImage!,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: context
                                                    .color.secondaryColor,
                                                shape: BoxShape.circle,
                                              ),
                                              height: 40.rh(context),
                                              width: 40.rw(context),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: UiUtils.getSvg(
                                                    AppIcons.v360Degree,
                                                    color: context
                                                        .color.teritoryColor),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      advertismentLable()
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Row(children: [
                                UiUtils.imageType(
                                    property?.category!.image ?? "",
                                    width: 18,
                                    height: 18,
                                    color: context.color.teritoryColor),
                                const SizedBox(
                                  width: 10,
                                ),
                                SizedBox(
                                  width: 158.rw(context),
                                  child: Text(property!.category!.category!)
                                      .setMaxLines(lines: 1)
                                      .size(
                                        context.font.normal,
                                      )
                                      .bold(
                                        weight: FontWeight.w400,
                                      )
                                      .color(UiUtils.makeColorLight(
                                          context.color.textColorDark)),
                                ),
                                const Spacer(),
                                Container(
                                  width: 50,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3.5),
                                      color: context.color.teritoryColor),
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Center(
                                        child: Text(
                                      property!.properyType.toString(),
                                    )
                                            .size(context.font.small)
                                            .color(context.color.buttonColor)),
                                  ),
                                )
                              ]),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(property!.title!.firstUpperCase())
                                  .color(context.color.textColorDark)
                                  .size(18)
                                  .bold(weight: FontWeight.w600),
                              const SizedBox(height: 13),
                              Row(
                                children: [
                                  Text(property!.price!
                                          .priceFormate(
                                              disabled:
                                                  Constant.isNumberWithSuffix ==
                                                      false)
                                          .formatAmount(prefix: true))
                                      .color(context.color.teritoryColor)
                                      .size(18)
                                      .bold(weight: FontWeight.w700),
                                  if (Constant.isNumberWithSuffix) ...[
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text("(${property!.price!})")
                                        .color(context.color.teritoryColor)
                                        .size(18)
                                        .bold(weight: FontWeight.w500),
                                  ]
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Wrap(
                                direction: Axis.horizontal,
                                crossAxisAlignment: WrapCrossAlignment.start,
                                runAlignment: WrapAlignment.start,
                                alignment: WrapAlignment.start,
                                children: List.generate(
                                    property?.parameters?.length ?? 0, (index) {
                                  Parameter? parameter =
                                      property?.parameters![index];

                                  return ConstrainedBox(
                                    constraints: BoxConstraints(
                                        minWidth: context.screenWidth / 3),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 8, 8, 8),
                                      child: SizedBox(
                                        height: 37,
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 36.rw(context),
                                                height: 36.rh(context),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    color: context
                                                        .color.teritoryColor
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: SizedBox(
                                                  height: 20.rh(context),
                                                  width: 20.rw(context),
                                                  child: FittedBox(
                                                    child: UiUtils.imageType(
                                                      parameter?.image ?? "",
                                                      fit: BoxFit.cover,
                                                      color: context
                                                          .color.teritoryColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10.rw(context),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(parameter?.name ?? "")
                                                      .size(12)
                                                      .color(context
                                                          .color.textColorDark
                                                          .withOpacity(0.8)),
                                                  if (parameter
                                                          ?.typeOfParameter ==
                                                      "file") ...{
                                                    GestureDetector(
                                                      onTap: () async {
                                                        await urllauncher.launchUrl(
                                                            Uri.parse(parameter!
                                                                .value),
                                                            mode: LaunchMode
                                                                .externalApplication);
                                                        // Navigator.push(
                                                        //     context,
                                                        //     BlurredRouter(
                                                        //       builder: (context) =>
                                                        //           FileDownloaderWidget(
                                                        //               url: parameter!
                                                        //                   .value),
                                                        //     ));
                                                      },
                                                      child: Text(
                                                        UiUtils
                                                            .getTranslatedLabel(
                                                                context,
                                                                "viewFile"),
                                                      ).underline().color(
                                                          context.color
                                                              .teritoryColor),
                                                    ),
                                                  } else if (parameter?.value
                                                      is List) ...{
                                                    Text((parameter?.value
                                                            as List)
                                                        .join(","))
                                                  } else ...[
                                                    Text((parameter?.value)
                                                            .toString())
                                                        .size(14)
                                                        .bold(
                                                          weight:
                                                              FontWeight.w600,
                                                        )
                                                  ]
                                                ],
                                              )
                                            ]),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(
                                height: 14,
                              ),
                              UiUtils.getDivider(),
                              const SizedBox(
                                height: 14,
                              ),
                              Text(UiUtils.getTranslatedLabel(
                                      context, "aboutThisPropLbl"))
                                  .color(context.color.textColorDark)
                                  .size(16)
                                  .bold(weight: FontWeight.w600),
                              const SizedBox(
                                height: 15,
                              ),
                              ReadMoreText(
                                  text: property?.description ?? "",
                                  style: TextStyle(
                                      color: context.color.textColorDark
                                          .withOpacity(0.7)),
                                  readMoreButtonStyle: TextStyle(
                                      color: context.color.teritoryColor)),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(UiUtils.getTranslatedLabel(
                                      context, "listedBy"))
                                  .color(context.color.textColorDark)
                                  .size(16)
                                  .bold(weight: FontWeight.w600),
                              const SizedBox(
                                height: 10,
                              ),
                              CusomterProfileWidget(
                                widget: widget,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              if (property?.gallery?.isNotEmpty ?? false) ...[
                                Text(UiUtils.getTranslatedLabel(
                                        context, "gallery"))
                                    .color(context.color.textColorDark)
                                    .size(16)
                                    .bold(weight: FontWeight.w600),
                                SizedBox(
                                  height: 10.rh(context),
                                ),
                              ],
                              if (property?.gallery?.isNotEmpty ?? false) ...[
                                Row(
                                    children: List.generate(
                                  (gallary?.length.clamp(0, 4)) ?? 0,
                                  (index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 3),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(18),
                                        child: Stack(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                if (gallary?[index].isVideo ==
                                                    true) return;

                                                //google map doesn't allow blur so we hide it:)

                                                showGoogleMap = false;
                                                setState(() {});

                                                var images = property?.gallery
                                                    ?.map((e) => e.imageUrl)
                                                    .toList();

                                                UiUtils.imageGallaryView(
                                                  context,
                                                  images: images!,
                                                  initalIndex: index,
                                                  then: () {
                                                    showGoogleMap = true;
                                                    setState(() {});
                                                  },
                                                );
                                              },
                                              child: SizedBox(
                                                width: 76.rw(context),
                                                height: 76.rh(context),
                                                child: gallary?[index]
                                                            .isVideo ==
                                                        true
                                                    ? Container(
                                                        child: UiUtils.getImage(
                                                            youtubeVideoThumbnail,
                                                            fit: BoxFit.cover),
                                                      )
                                                    : UiUtils.getImage(
                                                        property
                                                                ?.gallery?[
                                                                    index]
                                                                .imageUrl ??
                                                            "",
                                                        fit: BoxFit.cover),
                                              ),
                                            ),
                                            if (gallary?[index].isVideo == true)
                                              Positioned.fill(
                                                  child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(context,
                                                      MaterialPageRoute(
                                                    builder: (context) {
                                                      return VideoViewScreen(
                                                        videoUrl:
                                                            gallary?[index]
                                                                    .image ??
                                                                "",
                                                        flickManager:
                                                            flickManager,
                                                      );
                                                    },
                                                  ));
                                                },
                                                child: const Icon(
                                                    Icons.play_arrow),
                                              )),
                                            if (index == 3)
                                              Positioned.fill(
                                                  child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(context,
                                                      BlurredRouter(
                                                    builder: (context) {
                                                      return AllGallaryImages(
                                                          youtubeThumbnail:
                                                              youtubeVideoThumbnail,
                                                          images: property
                                                                  ?.gallery ??
                                                              []);
                                                    },
                                                  ));
                                                },
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                  child: Text(
                                                          "+${(property?.gallery?.length ?? 0) - 3}")
                                                      .color(
                                                        Colors.white,
                                                      )
                                                      .size(context.font.large)
                                                      .bold(),
                                                ),
                                              ))
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ))
                              ],
                              const SizedBox(
                                height: 15,
                              ),
                              Text(UiUtils.getTranslatedLabel(
                                      context, "locationLbl"))
                                  .color(context.color.textColorDark)
                                  .size(context.font.large)
                                  .bold(weight: FontWeight.w600),
                              SizedBox(
                                height: 15.rh(context),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${UiUtils.getTranslatedLabel(context, "addressLbl")} :")
                                      .color(context.color.textColorDark)
                                      .bold(weight: FontWeight.w600),
                                  SizedBox(
                                    height: 5.rh(context),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      UiUtils.getSvg(AppIcons.location,
                                          color: context.color.teritoryColor),
                                      SizedBox(
                                        width: 5.rw(context),
                                      ),
                                      Expanded(
                                        child: Text("${property?.address!}"),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 16.rh(context),
                              ),
                              Visibility(
                                visible: showGoogleMap,
                                child: SizedBox(
                                  height: 300,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Visibility(
                                      visible: showGoogleMap,
                                      child: GoogleMap(
                                        myLocationButtonEnabled: false,
                                        markers: {
                                          Marker(
                                              markerId: const MarkerId("1"),
                                              position: LatLng(
                                                  double.parse(
                                                      (property?.latitude ??
                                                          "0")),
                                                  double.parse(
                                                      (property?.longitude ??
                                                          "0"))))
                                        },
                                        mapType: MapType.normal,
                                        gestureRecognizers: <
                                            f.Factory<
                                                OneSequenceGestureRecognizer>>{
                                          f.Factory<
                                             OneSequenceGestureRecognizer>(
                                            () => EagerGestureRecognizer(),
                                          ),
                                        },
                                        initialCameraPosition: _kInitialPlace,
                                        onMapCreated:
                                            (GoogleMapController controller) {
                                          if (!_controller.isCompleted) {
                                            _controller.complete(controller);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              if (int.parse(HiveUtils.getUserId() ?? "0") !=
                                  property?.addedBy)
                                Row(
                                  children: [
                                    sendEnquiryButtonWithState(),
                                    setInterest(),
                                  ],
                                )
                            ],
                          ),

                        //here
                        SizedBox(
                          height: 20.rh(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        )),
      ),
    );
  }

  Widget advertismentLable() {
    if (property?.promoted == false) {
      return const SizedBox.shrink();
    }

    return PositionedDirectional(
        start: 20,
        top: 20,
        child: Container(
          width: 83,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: context.color.teritoryColor,
              borderRadius: BorderRadius.circular(4)),
          child: Text(UiUtils.getTranslatedLabel(context, 'featured'))
              .color(context.color.buttonColor)
              .size(context.font.small),
        ));
  }

  Future<void> _delayedPop(BuildContext context) async {
    unawaited(
      Navigator.of(context, rootNavigator: true).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: UiUtils.progress(),
              ),
            ),
          ),
          transitionDuration: Duration.zero,
          barrierDismissible: false,
          barrierColor: Colors.black45,
          opaque: false,
        ),
      ),
    );
    await Future.delayed(const Duration(seconds: 1));

    Future.delayed(
      Duration.zero,
      () {},
    );

    Future.delayed(
      Duration.zero,
      () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );
  }

  Widget bottomNavBar() {
    /// IF property is added by current user then it will show promote button
    if (int.parse(HiveUtils.getUserId() ?? "0") == property?.addedBy) {
      return
        SizedBox(
        height: 65.rh(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: BlocBuilder<FetchMyPropertiesCubit, FetchMyPropertiesState>(
            builder: (context, state) {
              PropertyModel? model;

              if (state is FetchMyPropertiesSuccess) {
                model = state.myProperty
                    .where((element) => element.id == property?.id)
                    .first;
              }

              model ??= widget.propertyData;

              var isPromoted = (model?.promoted);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isPromoted == false) ...[
                    Expanded(
                        child: UiUtils.buildButton(
                      context,
                      disabled: (property?.status.toString() == "0"),
                      // padding: const EdgeInsets.symmetric(horizontal: 1),
                      outerPadding: const EdgeInsets.all(
                        1,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          Routes.createAdvertismentScreenRoute,
                          arguments: {
                            "model": property,
                          },
                        ).then(
                          (value) {
                            setState(() {});
                          },
                        );
                      },
                      prefixWidget: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: SvgPicture.asset(
                          AppIcons.promoted,
                          width: 14,
                          height: 14,
                        ),
                      ),

                      fontSize: context.font.normal,
                      width: context.screenWidth / 3,
                      buttonTitle:
                          UiUtils.getTranslatedLabel(context, "feature"),
                    )),
                    const SizedBox(
                      width: 8,
                    ),
                  ],
                  Expanded(
                    child: UiUtils.buildButton(context,
                        // padding: const EdgeInsets.symmetric(horizontal: 1),
                        outerPadding: const EdgeInsets.all(1), onPressed: () {
                      Constant.addProperty.addAll({
                        "category": Category(
                          category: property?.category!.category,
                          id: property?.category?.id!.toString(),
                          image: property?.category?.image,
                          parameterTypes: {
                            "parameters": property?.parameters
                                ?.map((e) => e.toMap())
                                .toList()
                          },
                        )
                      });
                      Navigator.pushNamed(
                          context, Routes.addPropertyDetailsScreen,
                          arguments: {
                            "details": {
                              "id": property?.id,
                              "catId": property?.category?.id,
                              "propType": property?.properyType,
                              "name": property?.title,
                              "desc": property?.description,
                              "city": property?.city,
                              "state": property?.state,
                              "country": property?.country,
                              "latitude": property?.latitude,
                              "longitude": property?.longitude,
                              "address": property?.address,
                              "client": property?.clientAddress,
                              "price": property?.price,
                              'parms': property?.parameters,
                              "images": property?.gallery
                                  ?.map((e) => e.imageUrl)
                                  .toList(),
                              "titleImage": property?.titleImage
                            }
                          });
                    },
                        fontSize: context.font.normal,
                        width: context.screenWidth / 3,
                        prefixWidget: Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: SvgPicture.asset(AppIcons.edit),
                        ),
                        buttonTitle:
                            UiUtils.getTranslatedLabel(context, "edit")),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: UiUtils.buildButton(context,
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        outerPadding: const EdgeInsets.all(1),
                        prefixWidget: Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: SvgPicture.asset(
                            AppIcons.delete,
                            color: context.color.buttonColor,
                            width: 14,
                            height: 14,
                          ),
                        ), onPressed: () async {
                      var delete = await UiUtils.showBlurredDialoge(
                        context,
                        dialoge: BlurredDialogBox(
                          title: UiUtils.getTranslatedLabel(
                            context,
                            "deleteBtnLbl",
                          ),
                          content: Text(
                            UiUtils.getTranslatedLabel(
                                context, "deletepropertywarning"),
                          ),
                        ),
                      );
                      if (delete == true) {
                        Future.delayed(
                          Duration.zero,
                          () {
                            if (Constant.isDemoModeOn) {
                              HelperUtils.showSnackBarMessage(
                                  context,
                                  UiUtils.getTranslatedLabel(
                                      context, "thisActionNotValidDemo"));
                            } else {
                              context
                                  .read<DeletePropertyCubit>()
                                  .delete(property!.id!);
                            }
                          },
                        );
                      }
                    },
                        fontSize: context.font.normal,
                        width: context.screenWidth / 3.2,
                        buttonTitle: UiUtils.getTranslatedLabel(
                            context, "deleteBtnLbl")),
                  ),
                ],
              );
            },
          ),
        ),
      );
    }

    return SizedBox(
      height: 65.rh(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: <Widget>[
            Expanded(child: callButton()),
            const SizedBox(
              width: 8,
            ),
            Expanded(child: messageButton()),
            const SizedBox(
              width: 8,
            ),
            //Expanded(child: chatButton()),
          ],
        ),
      ),
    );
  }

  Widget setInterest() {
    // check if list has this id or not
    bool interestedProperty =
        Constant.interestedPropertyIds.contains(widget.propertyData?.id);

    /// default icon
    IconData icon = Icons.share_location_sharp;

    /// first priority is Constant list .
    if (interestedProperty == true || widget.propertyData?.isInterested == 1) {
      /// If list has id or our property is interested so we are gonna show icon of No Interest
      icon = Icons.not_interested_outlined;
    }

    return BlocConsumer<ChangeInterestInPropertyCubit,
        ChangeInterestInPropertyState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is ChangeInterestInPropertySuccess) {
          if (state.interest == PropertyInterest.interested) {
            //If interested show no interested icon
            icon = Icons.not_interested_outlined;
          } else {
            icon = Icons.share_location_sharp;
          }
        }

        return Expanded(
          flex: 1,
          child: UiUtils.buildButton(
            context,
            height: 42,
            outerPadding: const EdgeInsets.all(1),
            isInProgress: state is ChangeInterestInPropertyInProgress,
            onPressed: () {
              PropertyInterest interest;

              bool contains = Constant.interestedPropertyIds
                  .contains(widget.propertyData!.id!);

              if (contains == true || widget.propertyData!.isInterested == 1) {
                //change to not interested
                interest = PropertyInterest.notInterested;
              } else {
                //change to not unterested
                interest = PropertyInterest.interested;
              }
              context.read<ChangeInterestInPropertyCubit>().changeInterest(
                  propertyId: widget.propertyData!.id!.toString(),
                  interest: interest);
            },
            buttonTitle: (icon == Icons.not_interested_outlined
                ? UiUtils.getTranslatedLabel(context, "interested")
                : UiUtils.getTranslatedLabel(context, "interest")),
            fontSize: context.font.small,
            prefixWidget: Padding(
              padding: const EdgeInsetsDirectional.only(end: 2.0),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.buttonColor,
                size: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget sendEnquiryButtonWithState() {
    return Builder(builder: (context) {
      return BlocConsumer<SendEnquiryCubit, SendEnquiryState>(
        listener: (BuildContext context, state) {
          if (state is SendEnquirySuccess) {
            context.read<EnquiryIdsLocalCubit>().add(state.id);
            if (!isEnquiryFromChat) {
              HelperUtils.showSnackBarMessage(
                  context, UiUtils.getTranslatedLabel(context, "success"),
                  type: MessageType.success);
            }
          } else if (state is SendEnquiryFailure) {
            //we prevent snackbar if it is chat
            if (!isEnquiryFromChat) {
              HelperUtils.showSnackBarMessage(context, state.errorMessage);
            }
          }
        },
        builder: (context, state) {
          return Expanded(
            flex: 1,
            child: UiUtils.buildButton(
              context,
              fontSize: context.font.small,
              showProgressTitle: false,
              height: 42,
              outerPadding: const EdgeInsets.all(1),
              disabled: isDisabledEnquireButton(
                context.watch<EnquiryIdsLocalCubit>().state,
                property?.id,
              ),
              prefixWidget: (showIcon(
                          context.watch<EnquiryIdsLocalCubit>().state,
                          property?.id) ==
                      false)
                  ? null
                  : Padding(
                      padding: const EdgeInsetsDirectional.only(end: 2.0),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: UiUtils.getSvg(AppIcons.enquiry,
                            color: context.color.buttonColor),
                      ),
                    ),
              buttonTitle: setLable(
                  context.watch<EnquiryIdsLocalCubit>().state, property?.id),
              isInProgress: state is SendEnquiryInProgress,
              titleWhenProgress:
                  UiUtils.getTranslatedLabel(context, "sendingEnquiry"),
              onPressed: () {
                sendEnquiry(false);
              },
            ),
          );
        },
      );
    });
  }

  isDisabledEnquireButton(state, id) {
    if (state is EnquiryIdsLocalState) {
      if (state.ids?.contains(id.toString()) ?? false) {
        return true;
      } else {
        return false;
      }
    }
  }

  showIcon(state, id) {
    if (state is EnquiryIdsLocalState) {
      if (state.ids?.contains(id.toString()) ?? false) {
        return false;
      } else {
        return true;
      }
    }
  }

  setLable(state, id) {
    if (state is EnquiryIdsLocalState) {
      if (state.ids?.contains(id.toString()) ?? false) {
        return UiUtils.getTranslatedLabel(
          context,
          "sent",
        );
      } else {
        return UiUtils.getTranslatedLabel(
          context,
          "sendEnqBtnLbl",
        );
      }
    }
  }

  Widget callButton() {
    return UiUtils.buildButton(context,
        fontSize: context.font.large,
        outerPadding: const EdgeInsets.all(1),
        buttonTitle: UiUtils.getTranslatedLabel(context, "call"),
        width: 35,
        onPressed: _onTapCall,
        prefixWidget: Padding(
          padding: const EdgeInsets.only(right: 3.0),
          child: SizedBox(
              width: 16,
              height: 16,
              child: UiUtils.getSvg(AppIcons.call, color: Colors.white)),
        ));
  }

  Widget messageButton() {
    return UiUtils.buildButton(context,
        fontSize: context.font.large,
        outerPadding: const EdgeInsets.all(1),
        buttonTitle: UiUtils.getTranslatedLabel(context, "sms"),
        width: 35,
        onPressed: _onTapMessage,
        prefixWidget: SizedBox(
          width: 16,
          height: 16,
          child: Padding(
            padding: const EdgeInsets.only(right: 3.0),
            child: UiUtils.getSvg(AppIcons.message,
                color: context.color.buttonColor),
          ),
        ));
  }

  Widget chatButton() {
    return UiUtils.buildButton(context,
        fontSize: context.font.large,
        outerPadding: const EdgeInsets.all(1),
        buttonTitle: UiUtils.getTranslatedLabel(context, "chat"),
        width: 35,
        onPressed: _onTapChat,
        prefixWidget: SizedBox(
          width: 16,
          height: 16,
          child: Padding(
            padding: const EdgeInsets.only(right: 3.0),
            child:
                UiUtils.getSvg(AppIcons.chat, color: context.color.buttonColor),
          ),
        ));
  }

  _onTapCall() async {
    var contactNumber = widget.propertyData?.customerNumber;

    var url = Uri.parse("tel: $contactNumber"); //{contactNumber.data}
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _onTapMessage() async {
    var contactNumber = widget.propertyData?.customerNumber;

    var url = Uri.parse("sms:$contactNumber"); //{contactNumber.data}
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _onTapChat() {
    //entering chat
    sendEnquiry(true);
    Navigator.push(context, BlurredRouter(
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => SendMessageCubit(),
            ),
            BlocProvider(
              create: (context) => LoadChatMessagesCubit(),
            ),
          ],
          child: ChatScreen(
              profilePicture: property?.customerProfile ?? "",
              userName: property?.customerName ?? "",
              propertyImage: property?.titleImage ?? "",
              proeprtyTitle: property?.title ?? "",
              userId: (property?.addedBy).toString(),
              from: "property",
              propertyId: (property?.id).toString()),
        );
      },
    ));
  }

  sendEnquiry(bool isFromChat) {
    //call API & send enquiry
    context.read<SendEnquiryCubit>().sendEnquiry(
          propertyId: property!.id!.toString(),
        ); //0 for adding enquiry in type & 0 for pending status by default
    if (isFromChat) {
      isEnquiryFromChat = true;
      setState(() {});
    } else {
      isEnquiryFromChat = false;
      setState(() {});
    }
  }
}

class CusomterProfileWidget extends StatelessWidget {
  const CusomterProfileWidget({
    super.key,
    required this.widget,
  });

  final PropertyDetails widget;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 70,
            height: 70,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10)),
            child: UiUtils.getImage(widget.propertyData?.customerProfile ?? "",
                fit: BoxFit.cover,)

            //  CachedNetworkImage(
            //   imageUrl: widget.propertyData?.customerProfile ?? "",
            //   fit: BoxFit.cover,
            // ),

            ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.propertyData?.customerName ?? ""),
              Text(widget.propertyData?.customerEmail ?? ""),
            ],
          ),
        )
      ],
    );
  }
}
