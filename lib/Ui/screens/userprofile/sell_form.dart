

import 'dart:io';

import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/helper_utils.dart';
import '../../../utils/ui_utils.dart';
import '../widgets/custom_text_form_field.dart';

class SellFormField extends StatefulWidget {
  const SellFormField({Key? key}) : super(key: key);

  @override
  State<SellFormField> createState() => _SellFormFieldState();
}

class _SellFormFieldState extends State<SellFormField> {
  Widget buildTextField(BuildContext context,
      {required String title,
        required TextEditingController controller,
        CustomTextFieldValidator? validator,
        bool? readOnly}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10.rh(context),
        ),
        Text("${title}"),
        SizedBox(
          height: 10.rh(context),
        ),
        CustomTextFormField(
          controller: controller,
          isReadOnly: readOnly,
          validator: validator,
          // formaters: [FilteringTextInputFormatter.deny(RegExp(","))],
          fillColor: context.color.textLightColor.withOpacity(00.01),
        ),
      ],
    );
  }
 TextEditingController nameController=TextEditingController();
  TextEditingController mobileController=TextEditingController();
  TextEditingController facilityController=TextEditingController();
  TextEditingController propertytypeController=TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(context, showBackButton: true,title: "SELL YOUR PROPERTIES",),
      body: Padding(
        padding: const EdgeInsets.all(20.0),  
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 10.rh(context),
                ),
                buildTextField(context,
                    title: "FullName",
                    controller: nameController,
                    validator: CustomTextFieldValidator.nullCheck),
                SizedBox(
                  height: 10.rh(context),
                ),
                buildTextField(context,
                    title: "Mobile Number",
                    controller: mobileController,
                    validator: CustomTextFieldValidator.nullCheck),
                SizedBox(
                  height: 10.rh(context),
                ),
                buildTextField(context,
                    title: "Property Type",
                    controller: propertytypeController,
                    validator: CustomTextFieldValidator.nullCheck),
                SizedBox(
                  height: 10.rh(context),
                ),
                buildTextField(context,
                    title: "Facility",
                    controller: facilityController,
                    validator: CustomTextFieldValidator.nullCheck),
                SizedBox(
                  height: 40.rh(context),
                ),
                UiUtils.buildButton(
                  context,
                  onPressed: () {
                    validateData();
                  },
                  height: 48.rh(context),
                  buttonTitle: "Send",
                )
              ],
            ),
          ),
        ),
      ),
    );

  }
  validateData() async {
    if (_formKey.currentState!.validate()) {
      bool checkinternet = await HelperUtils.checkInternet();
      if (!checkinternet) {
        Future.delayed(
          Duration.zero,
              () {
            HelperUtils.showSnackBarMessage(context,
                UiUtils.getTranslatedLabel(context, "lblchecknetwork"));
          },
        );

        return;
      }
      var contact = "+919844444497";
      var androidUrl = "whatsapp://send?phone=$contact&text= Hi,\n Name:${nameController.text} \n Mobile Number:${mobileController.text}\n Property Type:${propertytypeController.text}\n Facility:${facilityController.text}";
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
  }
}
