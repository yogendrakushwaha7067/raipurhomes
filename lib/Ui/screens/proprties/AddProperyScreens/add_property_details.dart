import 'dart:io';
import '../../widgets/panaroma_image_view.dart';
import 'package:flutter/services.dart';
import '../../widgets/blurred_dialoge_box.dart';
import '../../../../app/routes.dart';
import '../../../../utils/AppIcon.dart';
import '../../../../utils/Extensions/extensions.dart';
import '../../../../utils/constant.dart';
import '../../../../utils/helper_utils.dart';
import '../../../../utils/imagePicker.dart';
import '../../../../utils/responsiveSize.dart';
import '../../../../utils/ui_utils.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import '../../../../data/Repositories/property_repository.dart';
import '../../../../data/model/category.dart';
import '../../../../data/model/google_place_model.dart';
import '../../widgets/BottomSheets/choose_location_bottomsheet.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/AnimatedRoutes/blur_page_route.dart';

class AddPropertyDetails extends StatefulWidget {
  final Map? properyDetails;
  const AddPropertyDetails({super.key, this.properyDetails});
  static Route route(RouteSettings routeSettings) {
    Map? arguments = routeSettings.arguments as Map?;
    return BlurredRouter(
      builder: (context) {
        return AddPropertyDetails(
          properyDetails: arguments?['details'],
        );
      },
    );
  }

  @override
  State<AddPropertyDetails> createState() => _AddPropertyDetailsState();
}

class _AddPropertyDetailsState extends State<AddPropertyDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  late final TextEditingController _propertyNameController =
      TextEditingController(text: widget.properyDetails?['name']);
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.properyDetails?['desc']);
  late final TextEditingController _cityNameController =
      TextEditingController(text: widget.properyDetails?['city']);
  late final TextEditingController _stateNameController =
      TextEditingController(text: widget.properyDetails?['state']);
  late final TextEditingController _countryNameController =
      TextEditingController(text: widget.properyDetails?['country']);
  late final TextEditingController _latitudeController =
      TextEditingController(text: widget.properyDetails?['latitude']);
  late final TextEditingController _longitudeController =
      TextEditingController(text: widget.properyDetails?['longitude']);
  late final TextEditingController _addressController =
      TextEditingController(text: widget.properyDetails?['address']);
  late final TextEditingController _priceController =
      TextEditingController(text: widget.properyDetails?['price']);
  late final TextEditingController _clientAddressController =
      TextEditingController(text: widget.properyDetails?['client']);

  late final TextEditingController _videoLinkController =
      TextEditingController();

  Map propertyData = {};
  final PickImage _pickTitleImage = PickImage();
  final PickImage _propertisImagePicker = PickImage();
  final PickImage _pick360deg = PickImage();
  List propertyImageList = [];
  List editPropertyImageList = [];
  String titleImageStr = "";
  @override
  void initState() {
    titleImageStr = widget.properyDetails?['titleImage'] ?? "";
    editPropertyImageList = widget.properyDetails?['images'] ?? [];
    _propertisImagePicker.listener((images) {
      if (editPropertyImageList.isNotEmpty) {
        editPropertyImageList.clear();
      }

      if (images is List<File>) {
        propertyImageList.addAll(List.from(images));
      }
      setState(() {});
    });
    _pickTitleImage.listener((p0) {
      titleImageStr = "";
      WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
        if (mounted) setState(() {});
      });
    });
    super.initState();
  }

  void _onTapChooseLocation() async {
    FocusManager.instance.primaryFocus?.unfocus();
    var result = await showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      context: context,
      builder: (context) {
        return const ChooseLocatonBottomSheet();
      },
    );
    if (result != null) {
      GooglePlaceModel place = (result as GooglePlaceModel);

      _latitudeController.text = place.latitude;
      _longitudeController.text = place.longitude;
      _cityNameController.text = place.city;
      _countryNameController.text = place.country;
      _stateNameController.text = place.state;
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  void _onTapContinue() async {
    File? titleImage;
    File? v360Image;

    if (_pickTitleImage.pickedFile != null) {
      // final mimeType = lookupMimeType(_pickTitleImage.pickedFile!.path);
      // var extension = mimeType!.split("/");

      titleImage = _pickTitleImage.pickedFile;
    }

    if (_pick360deg.pickedFile != null) {
      // final mimeType = lookupMimeType(_pick360deg.pickedFile!.path);
      // var extension = mimeType!.split("/");

      v360Image = _pick360deg.pickedFile;
    }

    if (_formKey.currentState!.validate()) {
      bool check = _checkIfLocationIsChosen();
      if (check == false) {
        Future.delayed(
          Duration.zero,
          () {
            UiUtils.showBlurredDialoge(
              context,
              sigmaX: 5,
              sigmaY: 5,
              dialoge: BlurredDialogBox(
                svgImagePath: AppIcons.warning,
                title: UiUtils.getTranslatedLabel(context, "incomplete"),
                showCancleButton: false,
                onAccept: () async {},
                content: Text(
                  UiUtils.getTranslatedLabel(context, "addressError"),
                ),
              ),
            );
          },
        );

        return;
      } else if (titleImage == null && titleImageStr == "") {
        Future.delayed(
          Duration.zero,
          () {
            UiUtils.showBlurredDialoge(context,
                sigmaX: 5,
                sigmaY: 5,
                dialoge: BlurredDialogBox(
                    svgImagePath: AppIcons.warning,
                    title: UiUtils.getTranslatedLabel(context, "incomplete"),
                    showCancleButton: false,
                    onAccept: () async {
                      // Navigator.pop(context);
                    },
                    content: Text(UiUtils.getTranslatedLabel(
                        context, "uploadImgMsgLbl"))));
          },
        );
        return;
      }

      propertyData.addAll({
        "title": _propertyNameController.text,
        "description": _descriptionController.text,
        "city": _cityNameController.text,
        "state": _stateNameController.text,
        "country": _countryNameController.text,
        "latitude": _latitudeController.text,
        "longitude": _longitudeController.text,
        "address": _addressController.text,
        "client_address": _clientAddressController.text,
        "price": _priceController.text,
        "title_image": titleImage,
        "gallary_images": propertyImageList,
        // "category_id": 1,
        "category_id": widget.properyDetails == null
            ? (Constant.addProperty['category'] as Category).id
            : widget.properyDetails?['catId'],
        // "property_type": 1,
        "property_type": widget.properyDetails == null
            ? (Constant.addProperty['propertyType'] as PropertyType).value
            : widget.properyDetails?['propType'],
        "package_id": Constant.subscriptionPackageId,
        "threeD_image": v360Image,
        "video_link": _videoLinkController.text
      });

      if (widget.properyDetails != null) {
        propertyData['id'] = widget.properyDetails?['id'];
        propertyData['action_type'] = "0";
      }

      Future.delayed(
        Duration.zero,
        () {
          Navigator.pushNamed(
            context,
            Routes.setPropertyParametersScreen,
            arguments: {
              "details": propertyData,
              "isUpdate": (widget.properyDetails != null)
            },
          );
        },
      );
    }
  }

  bool _checkIfLocationIsChosen() {
    if (_cityNameController.text == "" ||
        _stateNameController.text == "" ||
        _countryNameController.text == "" ||
        _latitudeController.text == "" ||
        _longitudeController.text == "") {
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _propertyNameController.dispose();
    _descriptionController.dispose();
    _cityNameController.dispose();
    _stateNameController.dispose();
    _countryNameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _clientAddressController.dispose();
    _videoLinkController.dispose();
    _pick360deg.dispose();
    _pickTitleImage.dispose();
    _propertisImagePicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      bottomNavigationBar: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: UiUtils.buildButton(context,
              onPressed: _onTapContinue,
              height: 48.rh(context),
              fontSize: context.font.large,
              buttonTitle: UiUtils.getTranslatedLabel(context, "continue")),
        ),
      ),
      appBar: UiUtils.buildAppBar(
        context,
        title: widget.properyDetails == null
            ? UiUtils.getTranslatedLabel(context, "ddPropertyLbl")
            : UiUtils.getTranslatedLabel(context, "updateProperty"),
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(UiUtils.getTranslatedLabel(context, "propertyNameLbl")),
                SizedBox(
                  height: 15.rh(context),
                ),
                CustomTextFormField(
                  controller: _propertyNameController,
                  validator: CustomTextFieldValidator.nullCheck,
                  hintText:
                      UiUtils.getTranslatedLabel(context, "propertyNameLbl"),
                ),
                SizedBox(
                  height: 15.rh(context),
                ),
                Text(UiUtils.getTranslatedLabel(context, "descriptionLbl")),
                SizedBox(
                  height: 15.rh(context),
                ),
                CustomTextFormField(
                  controller: _descriptionController,
                  validator: CustomTextFieldValidator.nullCheck,
                  hintText:
                      UiUtils.getTranslatedLabel(context, "writeSomething"),
                  maxLine: 100,
                  minLine: 6,
                ),
                SizedBox(
                  height: 15.rh(context),
                ),
                SizedBox(
                  height: 35.rh(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 3,
                          child: Text(UiUtils.getTranslatedLabel(
                              context, "addressLbl"))),
                      // const Spacer(),
                      Expanded(
                        flex: 2,
                        child: Container(
                          child: UiUtils.buildButton(context,
                              height: 30,
                              radius: 010,
                              padding: const EdgeInsets.all(8),
                              prefixWidget: Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  end: 3.0,
                                ),
                                child: UiUtils.getSvg(AppIcons.location,
                                    color: context.color.buttonColor),
                              ),
                              fontSize: context.font.small,
                              onPressed: _onTapChooseLocation,
                              buttonTitle: UiUtils.getTranslatedLabel(
                                  context, "chooseLocation")),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 15.rh(context),
                ),
                CustomTextFormField(
                  controller: _cityNameController,
                  isReadOnly: false,
                  hintText: UiUtils.getTranslatedLabel(context, "city"),
                ),
                SizedBox(
                  height: 10.rh(context),
                ),
                CustomTextFormField(
                  controller: _stateNameController,
                  isReadOnly: false,
                  hintText: UiUtils.getTranslatedLabel(context, "state"),
                ),
                SizedBox(
                  height: 10.rh(context),
                ),
                CustomTextFormField(
                  controller: _countryNameController,
                  isReadOnly: false,
                  hintText: UiUtils.getTranslatedLabel(context, "country"),
                ),
                SizedBox(
                  height: 10.rh(context),
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextFormField(
                        controller: _latitudeController,
                        formaters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                        ],
                        validator: CustomTextFieldValidator.nullCheck,
                        hintText:
                            UiUtils.getTranslatedLabel(context, "lattitude"),
                      ),
                    ),
                    SizedBox(
                      width: 5.rh(context),
                    ),
                    Expanded(
                      child: CustomTextFormField(
                        controller: _longitudeController,
                        formaters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                        ],
                        validator: CustomTextFieldValidator.nullCheck,
                        hintText:
                            UiUtils.getTranslatedLabel(context, "longitude"),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.rh(context),
                ),
                CustomTextFormField(
                  controller: _addressController,
                  hintText: UiUtils.getTranslatedLabel(context, "addressLbl"),
                  maxLine: 100,
                  validator: CustomTextFieldValidator.nullCheck,
                  minLine: 4,
                ),
                SizedBox(
                  height: 10.rh(context),
                ),
                CustomTextFormField(
                  controller: _clientAddressController,
                  validator: CustomTextFieldValidator.nullCheck,
                  hintText:
                      UiUtils.getTranslatedLabel(context, "clientaddressLbl"),
                  maxLine: 100,
                  minLine: 4,
                ),
                SizedBox(
                  height: 10.rh(context),
                ),
                Text(UiUtils.getTranslatedLabel(context, "price")),
                SizedBox(
                  height: 10.rh(context),
                ),
                CustomTextFormField(
                  prefix: Text("${Constant.currencySymbol} "),
                  controller: _priceController,
                  formaters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                  ],
                  isReadOnly: widget.properyDetails != null,
                  keyboard: TextInputType.number,
                  validator: CustomTextFieldValidator.nullCheck,
                  hintText: "00",
                ),
                SizedBox(
                  height: 10.rh(context),
                ),
                Row(
                  children: [
                    Text(UiUtils.getTranslatedLabel(context, "uploadPictures")),
                    const SizedBox(
                      width: 3,
                    ),
                    Text("maxSize".translate(context))
                        .italic()
                        .size(context.font.small),
                  ],
                ),
                SizedBox(
                  height: 10.rh(context),
                ),
                DottedBorder(
                  color: context.color.textLightColor,
                  borderType: BorderType.Rect,
                  radius: const Radius.circular(10),
                  child: GestureDetector(
                    onTap: () {
                      _pickTitleImage.pick(pickMultiple: false);
                    },
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      height: 48.rh(context),
                      child: Text(UiUtils.getTranslatedLabel(
                          context, "addMainPicture")),
                    ),
                  ),
                ),
                titleImageListener(),
                SizedBox(
                  height: 10.rh(context),
                ),
                DottedBorder(
                  color: context.color.textLightColor,
                  borderType: BorderType.Rect,
                  radius: const Radius.circular(10),
                  child: GestureDetector(
                    onTap: () {
                      _propertisImagePicker.pick(pickMultiple: true);
                    },
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      height: 48.rh(context),
                      child: Text(UiUtils.getTranslatedLabel(
                          context, "addOtherPicture")),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.rh(context),
                ),
                if (propertyImageList.isEmpty &&
                    editPropertyImageList.isNotEmpty) ...[
                  Wrap(
                      children: editPropertyImageList
                          .map((image) {
                            return Stack(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    HelperUtils.unfocus();
                                    UiUtils.showFullScreenImage(context,
                                        provider: FileImage(image));
                                  },
                                  child: Container(
                                      width: 100,
                                      height: 100,
                                      margin: const EdgeInsets.all(5),
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Image.network(
                                        image,
                                        fit: BoxFit.cover,
                                      )),
                                ),
                                Positioned(
                                  right: 5,
                                  top: 5,
                                  child: GestureDetector(
                                    onTap: () {
                                      editPropertyImageList.remove(image);
                                      setState(() {});
                                    },
                                    child: Icon(
                                      Icons.close,
                                      color: context.color.secondaryColor,
                                    ),
                                  ),
                                )
                              ],
                            );
                          })
                          .toList()
                          .cast<Widget>())
                ],
                propertyImagesListener(),
                SizedBox(
                  height: 10.rh(context),
                ),
                Text(UiUtils.getTranslatedLabel(context, "additionals")),
                SizedBox(
                  height: 10.rh(context),
                ),
                CustomTextFormField(
                  // prefix: Text("${Constant.currencySymbol} "),
                  controller: _videoLinkController,
                  // isReadOnly: widget.properyDetails != null,
                  hintText: "http://example.com/video.mp4",
                ),
                SizedBox(
                  height: 10.rh(context),
                ),
                DottedBorder(
                  color: context.color.textLightColor,
                  borderType: BorderType.Rect,
                  radius: const Radius.circular(10),
                  child: GestureDetector(
                    onTap: () {
                      _pick360deg.pick(pickMultiple: false);
                    },
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      height: 48.rh(context),
                      child: Text(UiUtils.getTranslatedLabel(
                          context, "add360degPicture")),
                    ),
                  ),
                ),
                _pick360deg.listenChangesInUI((context, image) {
                  if (image != null) {
                    return Stack(
                      children: [
                        Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.all(5),
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)),
                            child: Image.file(
                              image,
                              fit: BoxFit.cover,
                            )),
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(context, BlurredRouter(
                                builder: (context) {
                                  return PanaromaImageScreen(
                                    imageUrl: image.path,
                                    isFileImage: true,
                                  );
                                },
                              ));
                            },
                            child: Container(
                              width: 100,
                              margin: const EdgeInsets.all(5),
                              height: 100,
                              decoration: BoxDecoration(
                                  color:
                                      context.color.teritoryColor.withOpacity(
                                    0.68,
                                  ),
                                  borderRadius: BorderRadius.circular(10)),
                              child: FittedBox(
                                fit: BoxFit.none,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: context.color.secondaryColor,
                                  ),
                                  width: 60.rw(context),
                                  height: 60.rh(context),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                            height: 30.rh(context),
                                            width: 40.rw(context),
                                            child: UiUtils.getSvg(
                                              AppIcons.v360Degree,
                                            )),
                                        Text(UiUtils.getTranslatedLabel(
                                                context, "view"))
                                            .color(context.color.textColorDark)
                                            .size(context.font.small)
                                            .bold()
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return Container();
                }),
                SizedBox(
                  height: 15.rh(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget propertyImagesListener() {
    return _propertisImagePicker.listenChangesInUI((context, file) {
      if (file is List<File>) {
        return Wrap(
            children: propertyImageList
                .map((image) {
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HelperUtils.unfocus();
                          UiUtils.showFullScreenImage(context,
                              provider: FileImage(image));
                        },
                        child: Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.all(5),
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)),
                            child: Image.file(
                              image,
                              fit: BoxFit.cover,
                            )),
                      ),
                      Positioned(
                        right: 5,
                        top: 5,
                        child: GestureDetector(
                          onTap: () {
                            propertyImageList.remove(image);
                            setState(() {});
                          },
                          child: Icon(
                            Icons.close,
                            color: context.color.secondaryColor,
                          ),
                        ),
                      )
                    ],
                  );
                })
                .toList()
                .cast<Widget>());
      }

      return Container();
    });
  }

  Widget titleImageListener() {
    return _pickTitleImage.listenChangesInUI((context, file) {
      if (titleImageStr != "") {
        return GestureDetector(
          onTap: () {
            UiUtils.showFullScreenImage(context,
                provider: NetworkImage(titleImageStr));
          },
          child: Container(
            width: 100,
            height: 100,
            margin: const EdgeInsets.all(5),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Image.network(
              titleImageStr,
              fit: BoxFit.cover,
            ),
          ),
        );
      }
      if (file is File) {
        return GestureDetector(
          onTap: () {
            UiUtils.showFullScreenImage(context, provider: FileImage(file));
          },
          child: Column(
            children: [
              Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.all(5),
                  clipBehavior: Clip.antiAlias,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: Image.file(
                    file,
                    fit: BoxFit.cover,
                  )),
            ],
          ),
        );
      }

      return Container();
    });
  }
}
