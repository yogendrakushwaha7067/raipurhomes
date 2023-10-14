import '../../model/system_settings_model.dart';
import '../../../utils/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Repositories/system_repository.dart';

abstract class FetchSystemSettingsState {}

class FetchSystemSettingsInitial extends FetchSystemSettingsState {}

class FetchSystemSettingsInProgress extends FetchSystemSettingsState {}

class FetchSystemSettingsSuccess extends FetchSystemSettingsState {
  final Map settings;
  FetchSystemSettingsSuccess({
    required this.settings,
  });
}

class FetchSystemSettingsFailure extends FetchSystemSettingsState {
  final String errorMessage;

  FetchSystemSettingsFailure(this.errorMessage);
}

class FetchSystemSettingsCubit extends Cubit<FetchSystemSettingsState> {
  FetchSystemSettingsCubit() : super(FetchSystemSettingsInitial());
  final SystemRepository _systemRepository = SystemRepository();
  fetchSettings({required bool isAnonymouse}) async {
    try {
      emit(FetchSystemSettingsInProgress());
      Map settings = await _systemRepository.fetchSystemSettings(
          isAnonymouse: isAnonymouse);
      // print(settings.toString()+"jdjdjjdkdkdkfr");
      Constant.currencySymbol =
          _getSetting(settings, SystemSetting.currencySymball);

      emit(FetchSystemSettingsSuccess(settings: settings));
    } catch (e) {
      emit(FetchSystemSettingsFailure(e.toString()));
    }
  }

  getSetting(SystemSetting selected) {
    if (state is FetchSystemSettingsSuccess) {
      Map settings = (state as FetchSystemSettingsSuccess).settings;
      if (selected == SystemSetting.subscription) {
        //check if we have subscribed to any package if true then return this data otherwise return empty list
        if (settings['subscription'] == true) {
          return settings['package']['user_purchased_package'] as List;
        } else {
          return [];
        }
      }

      if (selected == SystemSetting.language) {
        return settings['languages'];
      }

      /// where selected is equals to type
      var selectedSettingData = "";
      // (settings['data'] as List).where(
      //   (element) {
      //     return element['type'] == Constant.systemSettingKey[selected];
      //   },
      // ).toList()[0]['data'];

      return selectedSettingData;
    }
  }

  _getSetting(Map settings, SystemSetting selected) {
    var selectedSettingData = (settings['data'] as List)
        .where(
          (element) => element['type'] == Constant.systemSettingKey[selected],
        )
        .toList()[0]['data'];
    return selectedSettingData;
  }
}
