import 'dart:developer';

import '../../utils/constant.dart';
import '../helper/custom_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/api.dart';

abstract class ProfileSettingState {}

//String? profileSettingData = '';

class ProfileSettingInitial extends ProfileSettingState {}

class ProfileSettingFetchProgress extends ProfileSettingState {}

class ProfileSettingFetchSuccess extends ProfileSettingState {
  String data;
  ProfileSettingFetchSuccess(this.data);
}

class ProfileSettingFetchFailure extends ProfileSettingState {
  final String errmsg;
  ProfileSettingFetchFailure(this.errmsg);
}

class ProfileSettingCubit extends Cubit<ProfileSettingState> {
  ProfileSettingCubit() : super(ProfileSettingInitial());

  fetchProfileSetting(BuildContext context, String title) {
    emit(ProfileSettingFetchProgress());

    log("title @#$title");
    fetchProfileSettingFromDb(context, title).then((value) {
      emit(ProfileSettingFetchSuccess(value ?? ""));
    }).catchError((e, st) {
      log("@API ERROR $st");
      emit(ProfileSettingFetchFailure(st.toString()));
    });
  }

  Future<String?> fetchProfileSettingFromDb(
      BuildContext context, String title) async {
    String? profileSettingData;
    Map<String, String> body = {
      Api.type: title,
    };

    // var response = await HelperUtils.sendApiRequest(
    //     Api.apiGetSystemSettings, body, true, context,
    //     passUserid: false);
    var response = await Api.post(
        url: Api.apiGetSystemSettings, parameter: body, useAuthToken: false);

    // var getdata = json.decode(response);
    if (!response[Api.error]) {
      if (title == Api.currencySymbol) {
        // Constant.currencySymbol = getdata['data'].toString();
      } else if (title == Api.maintenanceMode) {
        Constant.maintenanceMode = response['data'].toString();
      } else {
        List data = (response['data'] as List<dynamic>);

        if (title == Api.termsAndConditions) {
          profileSettingData = data
              .where((element) => element['type'] == "terms_conditions")
              .first['data'];
        }

        if (title == Api.privacyPolicy) {
          profileSettingData = data
              .where((element) => element['type'] == "privacy_policy")
              .first['data'];
        }

        if (title == Api.aboutApp) {
          profileSettingData = data
              .where((element) => element['type'] == "about_us")
              .first['data'];
        }
        // profileSettingData = getdata['data'].toString();
      }
    } else {
      throw CustomException(response[Api.message]);
    }

    return profileSettingData;
  }
}
