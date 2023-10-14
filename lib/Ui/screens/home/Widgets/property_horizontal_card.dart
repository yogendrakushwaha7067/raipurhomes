// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ebroker/utils/AppIcon.dart';
import 'package:ebroker/utils/string_extenstion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ebroker/Ui/screens/widgets/like_button_widget.dart';
import 'package:ebroker/Ui/screens/widgets/promoted_widget.dart';
import 'package:ebroker/data/cubits/favorite/add_to_favorite_cubit.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../../../data/model/property_model.dart';
import '../../../../utils/constant.dart';
import '../../../../utils/helper_utils.dart';
import '../../../../utils/ui_utils.dart';

class PropertyHorizontalCard extends StatelessWidget {
  final PropertyModel property;
  final List<Widget>? addBottom;
  final double? additionalHeight;
  final StatusButton? statusButton;
  final Function(FavoriteType type)? onLikeChange;
  final bool? useRow;
  final bool? showDeleteButton;
  final VoidCallback? onDeleteTap;
  const PropertyHorizontalCard(
      {super.key,
      required this.property,
      this.useRow,
      this.addBottom,
      this.additionalHeight,
      this.onLikeChange,
      this.statusButton,
      this.showDeleteButton,
      this.onDeleteTap});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddToFavoriteCubitCubit(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.5),
        child: GestureDetector(
          onLongPress: () {
            HelperUtils.share(context, property.id!);
          },
          child: Container(
            height: addBottom == null ? 124 : (124 + (additionalHeight ?? 0)),
            decoration: BoxDecoration(
                border:
                    Border.all(width: 1.5, color: context.color.borderColor),
                color: context.color.secondaryColor,
                borderRadius: BorderRadius.circular(18)),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Stack(
                                  children: [
                                    UiUtils.getImage(
                                      property.titleImage ?? "",
                                      height: statusButton != null ? 90 : 120,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                    if (property.promoted ?? false)
                                      const PositionedDirectional(
                                          start: 5,
                                          top: 5,
                                          child: PromotedCard(
                                              type: PromoteCardType.icon)),
                                    PositionedDirectional(
                                      bottom: 6,
                                      start: 6,
                                      child: Container(
                                        height: 19,
                                        decoration: BoxDecoration(
                                            color: context.color.secondaryColor
                                                .withOpacity(0.9),
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Center(
                                            child: Text(
                                              property.properyType!,
                                            )
                                                .color(
                                                  context.color.textColorDark,
                                                )
                                                .bold()
                                                .size(context.font.smaller),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (statusButton != null)
                                Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: statusButton!.color,
                                        borderRadius: BorderRadius.circular(6)),
                                    width: 100 - 7,
                                    height: 120 - 90 - 8,
                                    child: Center(
                                        child: Text(statusButton!.lable)
                                            .size(context.font.small)
                                            .bold()
                                            .color(statusButton?.textColor ??
                                                Colors.black)),
                                  ),
                                )
                            ],
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    children: [
                                      UiUtils.imageType(
                                          property.category!.image ?? "",
                                          width: 18,
                                          height: 18,
                                          color: context.color.teritoryColor),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child:
                                            Text(property.category!.category!)
                                                .setMaxLines(lines: 1)
                                                .size(
                                                  context.font.small
                                                      .rf(context),
                                                )
                                                .bold(
                                                  weight: FontWeight.w400,
                                                )
                                                .color(
                                                  context.color.textLightColor,
                                                ),
                                      ),
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: context.color.secondaryColor,
                                          shape: BoxShape.circle,
                                          boxShadow: const [
                                            BoxShadow(
                                                color:
                                                    Color.fromARGB(12, 0, 0, 0),
                                                offset: Offset(0, 2),
                                                blurRadius: 15,
                                                spreadRadius: 0)
                                          ],
                                        ),
                                        child: LikeButtonWidget(
                                          property: property,
                                          onLikeChanged: onLikeChange,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                      NumberFormat.compactCurrency(
                                        decimalDigits: 2,
                                        symbol: '', // if you want to add currency symbol then pass that in this else leave it empty.
                                      ).format(double.parse(property.price!)).toString()
                                  )
                                      .size(context.font.large)
                                      .color(context.color.teritoryColor)
                                      .bold(weight: FontWeight.w700),
                                  Text(
                                    property.title!.firstUpperCase(),
                                  )
                                      .setMaxLines(lines: 1)
                                      .size(context.font.large)
                                      .color(context.color.textColorDark),
                                  if (property.city != "")
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: context.color.textLightColor,
                                        ),
                                        Text(property.city ?? "")
                                            .color(context.color.textLightColor)
                                      ],
                                    )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (useRow == false || useRow == null) ...addBottom ?? [],

                    if (useRow == true) ...{Row(children: addBottom ?? [])}

                    // ...addBottom ?? []
                  ],
                ),
                if (showDeleteButton ?? false)
                  PositionedDirectional(
                    top: 32 * 2,
                    end: 12,
                    child: InkWell(
                      onTap: () {
                        onDeleteTap?.call();
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: context.color.secondaryColor,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                                color: Color.fromARGB(33, 0, 0, 0),
                                offset: Offset(0, 2),
                                blurRadius: 15,
                                spreadRadius: 0)
                          ],
                        ),
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: FittedBox(
                            fit: BoxFit.none,
                            child: SvgPicture.asset(
                              AppIcons.bin,
                              color: context.color.teritoryColor,
                              width: 18,
                              height: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StatusButton {
  final String lable;
  final Color color;
  final Color? textColor;
  StatusButton({
    required this.lable,
    required this.color,
    this.textColor,
  });
}
