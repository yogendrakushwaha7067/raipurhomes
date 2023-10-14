import '../../utils/Extensions/extensions.dart';
import '../../utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Widgets {
  static void showLoader(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        useSafeArea: true,
        builder: (BuildContext context) {
          return AnnotatedRegion(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.black.withOpacity(0),
            ),
            child: SafeArea(
              child: WillPopScope(
                child: Center(
                  child: UiUtils.progress(
                    normalProgressColor: context.color.teritoryColor,
                  ),
                ),
                onWillPop: () {
                  return Future(
                    () => false,
                  );
                },
              ),
            ),
          );
        });
  }

  static hideLoder(BuildContext context) {
    Navigator.of(context).pop();
  }

  static noDataFound(String errorMsg) {
    return Center(child: Text(errorMsg));
  }
}

//string Extension -- for ₹
extension FormatAmount on String {
  //working with static strings and not textFormField
}
