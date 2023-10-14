import '../../../utils/Extensions/extensions.dart';
import 'package:flutter/material.dart';

import '../../../utils/AppIcon.dart';
import '../../../utils/ui_utils.dart';

enum PromoteCardType { text, icon }

class PromotedCard extends StatelessWidget {
  final PromoteCardType type;
  const PromotedCard({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    if (type == PromoteCardType.icon) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: context.color.teritoryColor),
        child: UiUtils.getSvg(
          AppIcons.promoted,
          fit: BoxFit.none,
        ),
      );
    }

    return Container(
      width: 64,
      height: 24,
      decoration: BoxDecoration(
          color: context.color.teritoryColor,
          borderRadius: BorderRadius.circular(4)),
      child: Center(
        child: Text(UiUtils.getTranslatedLabel(context, "featured"))
            .color(
              context.color.buttonColor,
            )
            .bold()
            .size(context.font.smaller),
      ),
    );
  }
}
