import '../../../../utils/AppIcon.dart';
import '../../../../utils/Extensions/extensions.dart';
import '../../../../utils/ui_utils.dart';
import 'package:flutter/material.dart';

class NoInternet extends StatelessWidget {
  final VoidCallback? onRetry;
  const NoInternet({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        body: SizedBox(
          height: context.screenHeight,
          width: context.screenWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: 100,
                  height: 150,
                  child: UiUtils.getSvg(AppIcons.noInternet)),
              SizedBox(
                  width: context.screenWidth * 0.8,
                  child: Text(
                    UiUtils.getTranslatedLabel(context, "noInternetErrorMsg"),
                    textAlign: TextAlign.center,
                  )),
              TextButton(
                  onPressed: onRetry,
                  style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(
                          context.color.teritoryColor.withOpacity(0.2))),
                  child: Text(UiUtils.getTranslatedLabel(context, "retry"))
                      .color(context.color.teritoryColor))
            ],
          ),
        ),
      ),
    );
  }
}
