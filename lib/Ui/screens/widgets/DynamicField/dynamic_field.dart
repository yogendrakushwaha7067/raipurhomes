// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:ebroker/utils/ui_utils.dart';

import '../custom_text_form_field.dart';

/// Note: Here i have used abstract factory pattern and builder pattern
/// You can learn design patterns from internet
/// so don't be confuse
List kDoNotReBuildThese = [];

abstract class AbstractField {
  final BuildContext context;
  static Map fieldsData = {};
  AbstractField(this.context);

  Widget createField(Map parameters);
}

class AbstractTextField extends AbstractField {
  AbstractTextField(BuildContext context)
      : super(
          context,
        );
  // TextEditingController? _controller;

  ///Here Builder pattern to set values,
  /// because when if we get it from constructor it will be messed in Factory class so it

  ///You can uncomment it if you want to use controller out side of the class

  // AbstractTextField setController(TextEditingController controller) {
  //   _controller = controller;
  //   return this;
  // }

  @override
  Widget createField(parameters) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 48.rw(context),
              height: 48.rh(context),
              decoration: BoxDecoration(
                color: context.color.teritoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: UiUtils.imageType(parameters['image'], fit: BoxFit.none),
            ),
            SizedBox(
              width: 10.rw(context),
            ),
            Text(parameters['name'])
                .size(context.font.large)
                .color(context.color.textColorDark)
          ],
        ),
        SizedBox(
          height: 10.rh(context),
        ),

        CustomTextFieldDynamic(
          initController: parameters['value'] != null ? true : false,
          value: parameters['value'].toString(),
          hintText: "00",
          id: parameters['id'],
        )

        // CustomTextFormField(
        //   hintText: "00",
        //   controller: parameters['value'] != null
        //       ? TextEditingController(
        //           text: parameters['value'].toString(),
        //         )
        //       : null,
        //   onChange: (value) {
        //     AbstractField.fieldsData.addAll({parameters['id']: value});
        //   },
        // )
      ],
    );

    // return TextFormField(
    //   onChanged: (value) {
    //     AbstractField.fieldsData.addAll({parameters['id']: value});
    //   },
    //   decoration: InputDecoration(hintText: parameters['name']),
    // );
  }
}

class AbstractTextAreaField extends AbstractField {
  AbstractTextAreaField(BuildContext context)
      : super(
          context,
        );
  // TextEditingController? _controller;

  ///   Here Builder pattern to set values,
  ///   because when if we get it from constructor it will be messed in Factory class so it
  ///   You can uncomment it if you want to use controller out side of class
  //AbstractTextAreaField setController(TextEditingController controller) {
  //  // _controller = controller;
  //  return this;
  //}

  @override
  Widget createField(parameters) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48.rw(context),
                height: 48.rh(context),
                decoration: BoxDecoration(
                  color: context.color.teritoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: UiUtils.imageType(
                  parameters['image'],
                  fit: BoxFit.none,
                ),
              ),
              SizedBox(
                width: 10.rw(context),
              ),
              Text(parameters['name']).size(context.font.large).color(
                    context.color.textColorDark,
                  )
            ],
          ),
          SizedBox(
            height: 10.rh(context),
          ),
          CustomTextFormField(
            hintText: "Write something...",
            minLine: 5,
            maxLine: 100,
            controller: parameters['value'] != null
                ? TextEditingController(text: parameters['value'].toString())
                : null,
            onChange: (value) {
              AbstractField.fieldsData.addAll({parameters['id']: value});
            },
          )
        ],
      ),
    );

    // return TextFormField(
    //   maxLines: null,
    //   minLines: 5,
    //   onChanged: (value) {
    //     AbstractField.fieldsData.addAll({parameters['id']: value});
    //   },
    //   decoration: InputDecoration(hintText: parameters['name']),
    // );
  }
}

class AbstractNumberField extends AbstractField {
  AbstractNumberField(BuildContext context)
      : super(
          context,
        );
  // TextEditingController? _controller;

  ///Here, Builder pattern to set values,
  /// because when if we get it from constructor it will be messed in Factory class so it

  ///You can uncomment it if you want to use controller out side of class
  // AbstractNumberField setController(TextEditingController controller) {
  //   _controller = controller;
  //   return this;
  // }

  @override
  Widget createField(parameters) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48.rw(context),
                  height: 48.rh(context),
                  decoration: BoxDecoration(
                    color: context.color.teritoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      UiUtils.imageType(parameters['image'], fit: BoxFit.none),
                ),
                SizedBox(
                  width: 10.rw(context),
                ),
                Text(parameters['name'])
                    .size(context.font.large)
                    .color(context.color.textColorDark)
              ],
            ),
            SizedBox(
              height: 10.rh(context),
            ),
            CustomTextFieldDynamic(
              initController: parameters['value'] != null ? true : false,
              value: parameters['value'].toString(),
              hintText: "00",
              keyboardType: TextInputType.number,
              id: parameters['id'],
            ),
          ],
        ));
  }
}

class AbstractDropdown extends AbstractField {
  Function(dynamic onData)? _onChange;
  List? _items;
  dynamic selectedItem;
  AbstractDropdown(
    BuildContext context,
  ) : super(context);

  ///We can say it method chaining
  ///Here this is builder pattern used here it will return it self after assign value so new class has already assigned value
  AbstractDropdown setOnChange(Function(dynamic onChange) onChange) {
    _onChange = onChange;
    return this;
  }

  AbstractDropdown setItems(List items) {
    _items = items;
    return this;
  }

  AbstractDropdown setSelectedItem(dynamic item) {
    selectedItem = item;
    return this;
  }

  late ValueNotifier<String> dropDownItemChange =
      ValueNotifier<String>(_items?.first);

  @override
  Widget createField(parameters) {
    return ValueListenableBuilder(
        valueListenable: dropDownItemChange,
        builder: (context, value, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48.rw(context),
                    height: 48.rh(context),
                    decoration: BoxDecoration(
                      color: context.color.teritoryColor.withOpacity(
                        0.1,
                      ),
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.rw(
                      context,
                    ),
                  ),
                  Text(
                    parameters['name'],
                  )
                      .size(
                        context.font.large,
                      )
                      .color(
                        context.color.textColorDark,
                      )
                ],
              ),
              SizedBox(
                height: 10.rh(context),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 3,
                ),
                child: Container(
                  decoration: BoxDecoration(
                      color: context.color.secondaryColor,
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                      border: Border.all(
                        width: 1.5,
                        color: context.color.borderColor,
                      )),
                  child: Padding(
                    padding: const EdgeInsets.all(
                      8.0,
                    ),
                    child: DropdownButton(
                      value: value,
                      isDense: true,
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                      underline: const SizedBox.shrink(),
                      items: _items
                          ?.map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                ),
                              ))
                          .toList(),
                      onChanged: (dynamic v) {
                        dropDownItemChange.value = v;
                        AbstractField.fieldsData.addAll(
                          {
                            parameters['id']: v,
                          },
                        );

                        _onChange?.call(v);
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10.rh(
                  context,
                ),
              )
            ],
          );
        });
  }
}

class AbstractRadioButton extends AbstractField {
  AbstractRadioButton(BuildContext context) : super(context);
  List? _radioValues;
  // late ValueNotifier selectedRadio;

  AbstractRadioButton setValues(
    List values,
  ) {
    _radioValues = values;
    // selectedRadio = ValueNotifier(_radioValues?.first);
    return this;
  }

  @override
  Widget createField(parameters) {
    return CustomRadioButtonWidget(
      parameters: parameters,
      radioValues: _radioValues,
    );
    // return ValueListenableBuilder(
    //     valueListenable: selectedRadio,
    //     builder: (context, value, child) {
    //       return Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           Row(
    //             children: [
    //               Container(
    //                 width: 48.rw(context),
    //                 height: 48.rh(context),
    //                 decoration: BoxDecoration(
    //                   color: context.color.teritoryColor.withOpacity(0.1),
    //                   borderRadius: BorderRadius.circular(10),
    //                 ),
    //                 child: UiUtils.imageType(parameters['image'],
    //                     fit: BoxFit.none),
    //               ),
    //               SizedBox(
    //                 width: 10.rw(context),
    //               ),
    //               Text(parameters['name'])
    //                   .size(context.font.large)
    //                   .color(context.color.textColorDark)
    //             ],
    //           ),
    //           SizedBox(
    //             height: 10.rh(context),
    //           ),
    //           Wrap(
    //               alignment: WrapAlignment.start,
    //               runAlignment: WrapAlignment.start,
    //               crossAxisAlignment: WrapCrossAlignment.start,
    //               children: List.generate(
    //                   _radioValues?.length ?? 0,
    //                   (index) => Row(
    //                         mainAxisSize: MainAxisSize.min,
    //                         children: [
    //                           Radio(
    //                             value: _radioValues?[index],
    //                             groupValue: value,
    //                             fillColor: MaterialStatePropertyAll(
    //                                 context.color.teritoryColor),
    //                             onChanged: (dynamic e) {
    //                               selectedRadio.value = e;
    //                               AbstractField.fieldsData
    //                                   .addAll({parameters['id']: e});
    //                             },
    //                           ),
    //                           Text(_radioValues?[index])
    //                         ],
    //                       )))
    //         ],
    //       );

    //       // return Column(
    //       //   crossAxisAlignment: CrossAxisAlignment.start,
    //       //   children: [
    //       //     Text(parameters['name']),
    //       //     Wrap(
    //       //       children: _radioValues
    //       //               ?.map((item) {
    //       //                 return Row(
    //       //                   mainAxisSize: MainAxisSize.min,
    //       //                   children: [
    //       //                     Text(item),
    //       //                     Radio(
    //       //                         value: item,
    //       //                         groupValue: value,
    //       //                         onChanged: (dynamic e) {
    //       //                           selectedRadio.value = e;
    //       //                           AbstractField.fieldsData
    //       //                               .addAll({parameters['id']: e});
    //       //                         }),
    //       //                   ],
    //       //                 );
    //       //               })
    //       //               .toList()
    //       //               .cast() ??
    //       //           [],
    //       //     ),
    //       //   ],
    //       // );
    //     });
  }
}

class AbstractCheckBoxButton extends AbstractField {
  AbstractCheckBoxButton(BuildContext context) : super(context);

  List? _checkValues;

  bool initComplete = false;
  AbstractCheckBoxButton setCheckBoxValues(List values) {
    _checkValues = values;
    return this;
  }

  @override
  Widget createField(parameters) {
    return CustomCheckBox(
      parameters: parameters,
      checkValues: _checkValues,
      index: 0,
      initComplete: true,
    );
  }

  void dispose() {
    // checked.dispose();
  }
}

class AbstractPickFileButton extends AbstractField {
  AbstractPickFileButton(BuildContext context) : super(context);
  ValueNotifier filePicked = ValueNotifier(false);
  Future<File?> pickFile() async {
    FilePickerResult? picker = await FilePicker.platform.pickFiles();
    if (picker != null) {
      filePicked.value = true;
      File file = File(
        picker.files.single.path!,
      );
      return file;
    }
    filePicked.value = false;

    return null;
  }

  @override
  Widget createField(parameters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48.rw(context),
              height: 48.rh(context),
              decoration: BoxDecoration(
                color: context.color.teritoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(
              width: 10.rw(context),
            ),
            Text(parameters['name'])
                .size(context.font.large)
                .color(context.color.textColorDark),
            const Spacer(),
            IconButton(
                onPressed: () async {
                  File? file = await pickFile();
                  if (file != null) {
                    MultipartFile multipartFile =
                        await MultipartFile.fromFile(file.path);

                    /// Add data to static Map
                    AbstractField.fieldsData
                        .addAll({parameters['id']: multipartFile});
                  }
                },
                icon: ValueListenableBuilder(
                    valueListenable: filePicked,
                    builder: (context, dynamic v, c) {
                      return Icon(
                        v ? Icons.replay_circle_filled_outlined : Icons.upload,
                        color: context.color.teritoryColor,
                      );
                    }))
          ],
        ),
      ],
    );

    // return MaterialButton(
    //   onPressed: () async {
    //     File? file = await pickFile();
    //     if (file != null) {
    //       MultipartFile multipartFile = await MultipartFile.fromFile(file.path);

    //       /// Add data to static Map
    //       AbstractField.fieldsData.addAll({parameters['id']: multipartFile});
    //     }
    //   },
    //   color: Colors.grey.shade200,
    //   child: const Text("Pick"),
    // );
  }
}

///Factory class which will return class according to type
class FieldFactory {
  static AbstractField getField(BuildContext context, String fieldType) {
    if (fieldType == 'textbox') {
      return AbstractTextField(context);
    } else if (fieldType == 'dropdown') {
      return AbstractDropdown(context);
    } else if (fieldType == 'radiobutton') {
      return AbstractRadioButton(context);
    } else if (fieldType == 'number') {
      return AbstractNumberField(
        context,
      );
    } else if (fieldType == "checkbox") {
      return AbstractCheckBoxButton(context);
    } else if (fieldType == "textarea") {
      return AbstractTextAreaField(context);
    } else if (fieldType == "file") {
      return AbstractPickFileButton(context);
    }
    throw Exception('Invalid field type: $fieldType');
  }
}

class CustomRadioButtonWidget extends StatefulWidget {
  final dynamic parameters;
  final dynamic radioValues;
  const CustomRadioButtonWidget({super.key, this.parameters, this.radioValues});

  @override
  State<CustomRadioButtonWidget> createState() =>
      _CustomRadioButtonWidgetState();
}

class _CustomRadioButtonWidgetState extends State<CustomRadioButtonWidget> {
  late ValueNotifier selectedRadio;
  bool isInitialized = false;
  @override
  void initState() {
    selectedRadio = ValueNotifier(widget.radioValues?.first);

    if (widget.parameters['value'] != null && isInitialized == false) {
      selectedRadio.value = widget.parameters['value'];
      isInitialized = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: selectedRadio,
        builder: (context, value, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48.rw(context),
                    height: 48.rh(context),
                    decoration: BoxDecoration(
                      color: context.color.teritoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: UiUtils.imageType(widget.parameters['image'],
                        fit: BoxFit.none),
                  ),
                  SizedBox(
                    width: 10.rw(context),
                  ),
                  Text(widget.parameters['name'])
                      .size(context.font.large)
                      .color(context.color.textColorDark)
                ],
              ),
              SizedBox(
                height: 10.rh(context),
              ),
              Wrap(
                  alignment: WrapAlignment.start,
                  runAlignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: List.generate(
                      widget.radioValues?.length ?? 0,
                      (index) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio(
                                value: widget.radioValues?[index],
                                groupValue: value,
                                fillColor: MaterialStatePropertyAll(
                                    context.color.teritoryColor),
                                onChanged: (dynamic e) {
                                  selectedRadio.value = e;
                                  AbstractField.fieldsData
                                      .addAll({widget.parameters['id']: e});
                                },
                              ),
                              Text(widget.radioValues?[index])
                            ],
                          )))
            ],
          );

          // return Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Text(parameters['name']),
          //     Wrap(
          //       children: _radioValues
          //               ?.map((item) {
          //                 return Row(
          //                   mainAxisSize: MainAxisSize.min,
          //                   children: [
          //                     Text(item),
          //                     Radio(
          //                         value: item,
          //                         groupValue: value,
          //                         onChanged: (dynamic e) {
          //                           selectedRadio.value = e;
          //                           AbstractField.fieldsData
          //                               .addAll({parameters['id']: e});
          //                         }),
          //                   ],
          //                 );
          //               })
          //               .toList()
          //               .cast() ??
          //           [],
          //     ),
          //   ],
          // );
        });
  }
}

class CustomCheckBox extends StatefulWidget {
  final dynamic parameters;
  final dynamic checkValues;
  final dynamic initComplete;
  final dynamic index;
  const CustomCheckBox(
      {super.key,
      this.parameters,
      this.checkValues,
      this.initComplete,
      this.index});

  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  final ValueNotifier<List> checked = ValueNotifier([]);
  @override
  void initState() {
    if (widget.parameters.containsKey("value")) {
      List<String> valueList = widget.parameters['value'].toString().split(",");
      if (valueList.isNotEmpty) {
        checked.value.add(widget.checkValues?[widget.index]);
        var entries = checked.value.asMap().entries;
        Map<int, dynamic> data = Map.fromEntries(entries);
        Map<String, dynamic> stringedData = data.map((key, value) {
          return MapEntry(key.toString(), value);
        });
        AbstractField.fieldsData
            .addAll({widget.parameters['id']: json.encode(stringedData)});
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: checked,
      builder: (context, List value, Widget? c) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48.rw(context),
                  height: 48.rh(context),
                  decoration: BoxDecoration(
                    color: context.color.teritoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: UiUtils.imageType(widget.parameters['image'],
                      fit: BoxFit.none),
                ),
                SizedBox(
                  width: 10.rw(context),
                ),
                Text(widget.parameters['name'])
                    .size(context.font.large)
                    .color(context.color.textColorDark)
              ],
            ),
            SizedBox(
              height: 10.rh(context),
            ),
            Wrap(
              alignment: WrapAlignment.start,
              runAlignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: List.generate(
                widget.checkValues?.length ?? 0,
                (index) {
                  //this variable will prevent adding when state change
                  ///this will work like init state text
                  if (widget.initComplete == false &&
                      (!kDoNotReBuildThese.contains(widget.parameters['id']))) {
                    kDoNotReBuildThese.add(widget.parameters['id']);

                    // widget.initComplete = true;
                  }

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        fillColor: MaterialStatePropertyAll(
                            context.color.teritoryColor),
                        value: value.contains(widget.checkValues?[index]),
                        onChanged: (v) {
                          if (checked.value
                              .contains(widget.checkValues?[index])) {
                            checked.value.remove(widget.checkValues?[index]);
                            // ignore: invalid_use_of_protected_member
                            checked.notifyListeners();
                          } else {
                            checked.value.add(widget.checkValues?[index]);
                            // ignore: invalid_use_of_protected_member
                            checked.notifyListeners();
                          }

                          var entries = checked.value.asMap().entries;
                          Map<int, dynamic> data = Map.fromEntries(entries);
                          Map<String, dynamic> temp = {};
                          data.forEach((key, value) {
                            temp[key.toString()] = value;
                          });

                          AbstractField.fieldsData.addAll(
                              {widget.parameters['id']: json.encode(temp)});
                        },
                      ),
                      Text(widget.checkValues?[index])
                    ],
                  );
                },
              ),
            )
          ],
        );
      },
    );
  }
}

class CustomTextFieldDynamic extends StatefulWidget {
  final String? value;
  final bool initController;
  final dynamic id;
  final String hintText;
  final TextInputType? keyboardType;
  const CustomTextFieldDynamic({
    Key? key,
    required this.initController,
    required this.value,
    this.id,
    required this.hintText,
    this.keyboardType,
  }) : super(key: key);

  @override
  State<CustomTextFieldDynamic> createState() => CustomTextFieldDynamicState();
}

class CustomTextFieldDynamicState extends State<CustomTextFieldDynamic> {
  TextEditingController? _controller;

  @override
  void initState() {
    if (widget.initController) {
      _controller = TextEditingController(text: widget.value);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      hintText: widget.hintText,
      validator: CustomTextFieldValidator.nullCheck,
      keyboard: widget.keyboardType,
      controller: _controller,
      onChange: (value) {
        AbstractField.fieldsData.addAll({widget.id: value});
      },
    );
  }
}
