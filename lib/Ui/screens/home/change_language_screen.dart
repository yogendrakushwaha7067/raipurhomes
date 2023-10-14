// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'dart:developer';

import 'package:ebroker/Ui/screens/widgets/AnimatedRoutes/blur_page_route.dart';
import 'package:ebroker/data/cubits/system/fetch_language_cubit.dart';
import 'package:ebroker/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:ebroker/data/cubits/system/language_cubit.dart';
import 'package:ebroker/data/helper/widgets.dart';
import 'package:ebroker/data/model/system_settings_model.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguagesListScreen extends StatelessWidget {
  const LanguagesListScreen({super.key});
  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) => const LanguagesListScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    log(HiveUtils.getLanguage().toString(), name: "@@@");
    if (context
            .watch<FetchSystemSettingsCubit>()
            .getSetting(SystemSetting.language) ==
        null) {
      return Scaffold(
        backgroundColor: context.color.primaryColor,
        appBar: UiUtils.buildAppBar(context,
            showBackButton: true,
            title: UiUtils.getTranslatedLabel(context, "chooseLanguage")),
        body: Center(child: UiUtils.progress()),
      );
    }

    List setting = context
        .watch<FetchSystemSettingsCubit>()
        .getSetting(SystemSetting.language) as List;

    var language = context.watch<LanguageCubit>().state;
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(context,
          showBackButton: true,
          title: UiUtils.getTranslatedLabel(context, "chooseLanguage")),
      body: BlocListener<FetchLanguageCubit, FetchLanguageState>(
        listener: (context, state) {
          if (state is FetchLanguageInProgress) {
            Widgets.showLoader(context);
          }
          if (state is FetchLanguageSuccess) {
            Widgets.hideLoder(context);
            HiveUtils.storeLanguage(state.toMap());
            context.read<LanguageCubit>().emit(LanguageLoader(state.code));
          }
        },
        child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: setting.length,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemBuilder: (context, index) {
              if (language is LanguageLoadFail) {
                log((language).error.toString(), name: "language load error");
              }
              Color color = (language as LanguageLoader).languageCode ==
                      setting[index]['code']
                  ? context.color.teritoryColor
                  : context.color.textLightColor.withOpacity(0.03);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                      onTap: () {
                        context
                            .read<FetchLanguageCubit>()
                            .getLanguage(setting[index]['code']);
                      },
                      title: Text(setting[index]['name'])
                          .color(
                              (language).languageCode == setting[index]['code']
                                  ? context.color.buttonColor
                                  : context.color.textColorDark)
                          .bold()),
                ),
              );
            }),
      ),
    );
  }
}
