import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NoDataFound extends StatelessWidget {
  final VoidCallback? onTap;
  const NoDataFound({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LottieBuilder.asset("assets/lottie/nodatafound.json"),
          Text("nodatafound".translate(context)).size(context.font.larger)
          // Text(UiUtils.getTranslatedLabel(context, "nodatafound")),
          // TextButton(
          //     onPressed: onTap,
          //     style: ButtonStyle(
          //         overlayColor: MaterialStateProperty.all(
          //             context.color.teritoryColor.withOpacity(0.2))),
          //     child: const Text("Retry").color(context.color.teritoryColor))
        ],
      ),
    );
  }
}
