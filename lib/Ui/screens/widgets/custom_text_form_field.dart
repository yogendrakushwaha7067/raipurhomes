import '../../../app/app_theme.dart';
import '../../../data/cubits/system/app_theme_cubit.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum CustomTextFieldValidator { nullCheck, phoneNumber, email, password }

class CustomTextFormField extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final int? minLine;
  final int? maxLine;
  final bool? isReadOnly;
  final List<TextInputFormatter>? formaters;
  final CustomTextFieldValidator? validator;
  final Color? fillColor;
  final Function(dynamic value)? onChange;
  final Widget? prefix;
  final TextInputAction? action;
  final TextInputType? keyboard;
  const CustomTextFormField({
    Key? key,
    this.hintText,
    this.controller,
    this.minLine,
    this.maxLine,
    this.formaters,
    this.isReadOnly,
    this.validator,
    this.fillColor,
    this.onChange,
    this.prefix,
    this.keyboard,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      inputFormatters: formaters,
      textInputAction: action,
      keyboardAppearance:
          context.watch<AppThemeCubit>().state.appTheme == AppTheme.light
              ? Brightness.light
              : Brightness.dark,
      readOnly: isReadOnly ?? false,
      style: TextStyle(fontSize: context.font.large),
      minLines: minLine ?? 1,
      maxLines: maxLine ?? 1,
      onChanged: onChange,
      validator: (value) {
        if (validator == CustomTextFieldValidator.nullCheck) {
          return Validator.nullCheckValidator(value);
        }
        if (validator == CustomTextFieldValidator.email) {
          return Validator.validateEmail(value);
        }
        if (validator == CustomTextFieldValidator.phoneNumber) {
          return Validator.validatePhoneNumber(value);
        }
        if (validator == CustomTextFieldValidator.password) {
          return Validator.validatePassword(value);
        }
        return null;
      },
      keyboardType: keyboard,
      decoration: InputDecoration(
          prefix: prefix,
          hintText: hintText,
          hintStyle: TextStyle(
              color: context.color.textColorDark.withOpacity(0.7),
              fontSize: context.font.large),
          filled: true,
          fillColor: fillColor ?? context.color.secondaryColor,
          focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(width: 1.5, color: context.color.teritoryColor),
              borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(width: 1.5, color: context.color.borderColor),
              borderRadius: BorderRadius.circular(10)),
          border: OutlineInputBorder(
              borderSide:
                  BorderSide(width: 1.5, color: context.color.borderColor),
              borderRadius: BorderRadius.circular(10))),
    );
  }
}
