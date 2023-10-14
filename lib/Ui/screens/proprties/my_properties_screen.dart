import 'Property%20tab/sell_rent_screen.dart';
import '../../../data/cubits/property/fetch_my_properties_cubit.dart';
import '../../../utils/Extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/ui_utils.dart';

class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({Key? key}) : super(key: key);

  @override
  State<PropertiesScreen> createState() => _MyPropertyState();
}

class _MyPropertyState extends State<PropertiesScreen>
    with TickerProviderStateMixin {
  int offset = 0, total = 0;
  int selectTab = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: context.color.primaryColor,
        title: Text(UiUtils.getTranslatedLabel(context, "myProperty"))
            .color(context.color.textColorDark),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
              child: Row(
                children: [
                  customTab(
                    context,
                    isSelected: (selectTab == 0),
                    onTap: () {
                      selectTab = 0;
                      setState(() {});
                      _pageController.jumpToPage(0);
                      cubitReference = context.read<FetchMyPropertiesCubit>();
                      propertyType = "sell";
                    },
                    name: UiUtils.getTranslatedLabel(
                      context,
                      "sell",
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  customTab(
                    context,
                    isSelected: selectTab == 1,
                    onTap: () {
                      _pageController.jumpToPage(1);
                      selectTab = 1;
                      cubitReference = context.read<FetchMyPropertiesCubit>();
                      propertyType = "rent";

                      setState(() {});
                    },
                    name: UiUtils.getTranslatedLabel(
                      context,
                      "rent",
                    ),
                  ),
                ],
              ),
            )),
      ),
      body: ScrollConfiguration(
        behavior: RemoveGlow(),
        child: PageView(
          // physics: const BouncingScrollPhysics(),
          onPageChanged: (value) {
            selectTab = value;
            setState(() {});
          },
          controller: _pageController,
          children: [
            BlocProvider(
              create: (context) => FetchMyPropertiesCubit(),
              child: const SellRentScreen(
                type: "sell",
                key: Key("0"),
              ),
            ),
            BlocProvider(
              create: (context) => FetchMyPropertiesCubit(),
              child: const SellRentScreen(
                type: "rent",
                key: Key("1"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget customTab(
    BuildContext context, {
    required bool isSelected,
    required String name,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 110,
        ),
        height: 40,
        decoration: BoxDecoration(
            color: (isSelected
                    ? (context.color.teritoryColor)
                    : context.color.textColorDark)
                .withOpacity(0.04),
            border: Border.all(
              color: isSelected
                  ? context.color.teritoryColor
                  : context.color.textLightColor,
            ),
            borderRadius: BorderRadius.circular(11)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(name).size(context.font.large),
          ),
        ),
      ),
    );
  }
}
