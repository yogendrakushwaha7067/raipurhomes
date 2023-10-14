// ignore_for_file: depend_on_referenced_packages

import 'dart:collection';
import 'dart:io';
import 'package:http_parser/http_parser.dart' as h;
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime/mime.dart';
import '../../widgets/AnimatedRoutes/blur_page_route.dart';
import '../../../../data/cubits/property/create_property_cubit.dart';
import '../../../../data/cubits/property/fetch_most_viewed_properties_cubit.dart';
import '../../../../data/cubits/property/fetch_my_properties_cubit.dart';
import '../../../../data/cubits/property/fetch_promoted_properties_cubit.dart';
import '../../../../data/helper/widgets.dart';
import '../../../../utils/Extensions/extensions.dart';
import '../../../../utils/constant.dart';
import '../../../../utils/helper_utils.dart';
import '../../../../utils/responsiveSize.dart';
import '../../../../utils/ui_utils.dart';
import '../../widgets/DynamicField/dynamic_field.dart';
import '../Property tab/sell_rent_screen.dart';

class SetProeprtyParametersScreen extends StatefulWidget {
  final Map propertyDetails;
  final bool isUpdate;
  const SetProeprtyParametersScreen(
      {super.key, required this.propertyDetails, required this.isUpdate});
  static Route route(RouteSettings settings) {
    Map? argument = settings.arguments as Map?;

    return BlurredRouter(
      builder: (context) {
        return SetProeprtyParametersScreen(
          propertyDetails: argument?['details'],
          isUpdate: argument?['isUpdate'],
        );
      },
    );
  }

  @override
  State<SetProeprtyParametersScreen> createState() =>
      _SetProeprtyParametersScreenState();
}

class _SetProeprtyParametersScreenState
    extends State<SetProeprtyParametersScreen> {
  List<ValueNotifier> disposableFields = [];
  final GlobalKey<FormState> _formKey = GlobalKey();
  List galleryImage = [];
  File? titleImage;
  File? t360degImage;
  Map<String, dynamic>? apiParameters;
  @override
  void initState() {
    apiParameters = Map.from(widget.propertyDetails);
    galleryImage = apiParameters!['gallary_images'];
    titleImage = apiParameters!['title_image'];
    t360degImage = apiParameters!['threeD_image'];
    super.initState();
  }

  Widget buildDynamicField(Map parameter, int index) {
    ///Initital Container to assign
    Widget dynamicField = Container();

    ///This is factory class it will check type and it will return field class accordingly
    AbstractField field =
        FieldFactory.getField(context, parameter['type_of_parameter']);
    // if (widget.isUpdate) {
    //   AbstractField.fieldsData.addAll(
    //     {
    //       "parameters[$index][parameter_id]": parameter['id'],
    //       "parameters[$index][value]": parameter['value']
    //     },
    //   );
    // }

    ///Same like Bloc State management we check if field is AbstractDropdown, So we can apply additional configuration or add data to it
    if (field is AbstractDropdown) {
      dynamicField = field.setItems(parameter['type_values']).createField(
            parameter,
          );
    } else if (field is AbstractTextField) {
      dynamicField = field.createField(parameter);
    } else if (field is AbstractNumberField) {
      dynamicField = field.createField(parameter);
    } else if (field is AbstractRadioButton) {
      dynamicField =
          field.setValues(parameter['type_values']).createField(parameter);
    } else if (field is AbstractTextAreaField) {
      dynamicField = field.createField(parameter);
    } else if (field is AbstractCheckBoxButton) {
      dynamicField = field
          .setCheckBoxValues(parameter['type_values'])
          .createField(parameter);
      // disposableFields.add(field.checked);
    } else if (field is AbstractPickFileButton) {
      dynamicField = field.createField(parameter);
      // field.filePicked.value
    }

    ///Returning field
    return dynamicField;
  }

  ///This will convert {0:Demo} to it's required format here we have assigned Parameter id : value, before.
  Map<String, dynamic> assembleDynamicFieldsParameters() {
    Map<String, dynamic> parameters = {};

    Map fieldsData = AbstractField.fieldsData;

    for (var i = 0; i < fieldsData.entries.length; i++) {
      MapEntry element = fieldsData.entries.elementAt(i);
      var value = element.value;
      if (value is LinkedHashMap) {
        value = (value).toString();
      }
      parameters.addAll({
        "parameters[$i][parameter_id]": element.key,
        "parameters[$i][value]": value
      });
    }
    return parameters;
  }

  List<Widget> buildFields() {
    if (Constant.addProperty['category'] == null) {
      return [Container()];
    }
    if (widget.isUpdate) {}

    ///Loop parameters
    return (Constant.addProperty['category']?.parameterTypes!['parameters']
            as List)
        .mapIndexed((index, parameter) => buildDynamicField(parameter, index))
        .toList()
        .cast();
  }

  void disposeDynamicFieldsValueControllers() {
    for (var element in disposableFields) {
      element.dispose();
    }
  }

  @override
  void dispose() {
    disposeDynamicFieldsValueControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: widget.isUpdate
            ? UiUtils.getTranslatedLabel(context, "updateProperty")
            : UiUtils.getTranslatedLabel(context, "ddPropertyLbl"),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 7),
        child: UiUtils.buildButton(
          context,
          height: 48.rh(context),
          onPressed: () async {
            // log((cubitReference as FetchMyPropertiesCubit).state.toString(),
            //     name: "2nasd");
            if (_formKey.currentState!.validate() == false) return;

            apiParameters!.addAll(assembleDynamicFieldsParameters());

            /// Multipartimage of gallery images
            List gallery = [];
            await Future.forEach(
              galleryImage,
              (dynamic item) async {
                var multipartFile = await MultipartFile.fromFile(item.path);
                if (!multipartFile.isFinalized) {
                  gallery.add(multipartFile);
                }
              },
            );
            apiParameters!['gallary_images'] = gallery;
            gallery.clear();

            if (titleImage != null) {
              ///Multipart image of title image
              final mimeType = lookupMimeType((titleImage as File).path);
              var extension = mimeType!.split("/");
              apiParameters!['title_image'] = await MultipartFile.fromFile(
                  (titleImage as File).path,
                  contentType: h.MediaType('image', extension[1]),
                  filename: (titleImage as File).path.split("/").last);
            }

//set 360 deg image

            if (t360degImage != null) {
              final mimeType = lookupMimeType(t360degImage!.path);
              var extension = mimeType!.split("/");

              apiParameters!['threeD_image'] = await MultipartFile.fromFile(
                  t360degImage?.path ?? "",
                  contentType: h.MediaType('image', extension[1]),
                  filename: t360degImage?.path.split("/").last);
            }

            Future.delayed(
              Duration.zero,
              () {
                /// if (Constant.isDemoModeOn) {
                ///   HelperUtils.showSnackBarMessage(
                ///       context,
                // UiUtils.getTranslatedLabel(
                // context, "thisActionNotValidDemo"));
                //   return;
                // }
                context
                    .read<CreatePropertyCubit>()
                    .create(parameters: apiParameters!);
              },
            );
          },
          buttonTitle: widget.propertyDetails['action_type'] == "0"
              ? UiUtils.getTranslatedLabel(context, "update")
              : UiUtils.getTranslatedLabel(context, "submitProperty"),
        ),
      ),
      body: Form(
        key: _formKey,
        child: BlocListener<CreatePropertyCubit, CreatePropertyState>(
          listener: (context, state) {
            if (state is CreatePropertyInProgress) {
              Widgets.showLoader(context);
            }

            if (state is CreatePropertyFailure) {
              Widgets.hideLoder(context);
              HelperUtils.showSnackBarMessage(context, state.errorMessage);
            }
            if (state is CreatePropertySuccess) {
              Widgets.hideLoder(context);
              if (widget.isUpdate == false) {
                // context.read<FetchMyPropertiesCubit>().addLocal(
                //       state.propertyModel!,
                //     );

                ref[propertyType ?? "sell"]
                    ?.fetchMyProperties(type: propertyType ?? "sell");

                HelperUtils.showSnackBarMessage(
                  context,
                  UiUtils.getTranslatedLabel(context, "propertyAdded"),
                  type: MessageType.success,
                  onClose: () {
                    Navigator.of(context)
                      ..pop()
                      ..pop()
                      ..pop();
                  },
                );
              } else {
                ///////changing locally
                context
                    .read<FetchMostViewedPropertiesCubit>()
                    .update(state.propertyModel!);
                context
                    .read<FetchPromotedPropertiesCubit>()
                    .update(state.propertyModel!);
                context
                    .read<FetchMyPropertiesCubit>()
                    .update(state.propertyModel!);
                cubitReference?.update(state.propertyModel!);
                HelperUtils.showSnackBarMessage(context,
                    UiUtils.getTranslatedLabel(context, "propertyUpdated"),
                    type: MessageType.success, onClose: () {
                  Navigator.of(context)
                    ..pop()
                    ..pop()
                    ..pop();
                });
              }
            }
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(UiUtils.getTranslatedLabel(context, "addvalues")),
                  ...buildFields(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
