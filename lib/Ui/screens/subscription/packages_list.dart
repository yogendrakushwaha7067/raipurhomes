import 'dart:developer';

import '../../../settings.dart';
import 'payment_gatways.dart';
import '../widgets/Erros/no_data_found.dart';
import '../widgets/Erros/something_went_wrong.dart';
import '../widgets/blurred_dialoge_box.dart';
import '../../../data/cubits/subscription/fetch_subscription_packages_cubit.dart';
import '../../../data/cubits/subscription/get_subsctiption_package_limits_cubit.dart';
import '../../../data/cubits/system/fetch_system_settings_cubit.dart';
import '../../../data/model/subscription_pacakage_model.dart';
import '../../../data/model/subscription_package_limit.dart';
import '../../../data/model/system_settings_model.dart';
import '../widgets/shimmerLoadingContainer.dart';
import '../../../utils/AppIcon.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/constant.dart';
import '../../../utils/responsiveSize.dart';
import '../../../utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/AnimatedRoutes/blur_page_route.dart';
import '../widgets/Erros/no_internet.dart';

class SubsctiptionPackageListScreen extends StatefulWidget {
  const SubsctiptionPackageListScreen({super.key});
  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return const SubsctiptionPackageListScreen();
      },
    );
  }

  @override
  State<SubsctiptionPackageListScreen> createState() =>
      _SubsctiptionPackageListScreenState();
}

class _SubsctiptionPackageListScreenState
    extends State<SubsctiptionPackageListScreen> {
  List mySubscriptions = [];
  bool isLifeTimeSubscription = false;
  bool hasAlreadyPackage = false;
  // late final ScrollController _pageController = ScrollController()
  //   ..addListener(pageScrollListen);

  @override
  void initState() {
    context.read<FetchSubscriptionPackagesCubit>().fetchPackages();
    PaymentGatways.initPaystack();
    mySubscriptions = context
            .read<FetchSystemSettingsCubit>()
            .getSetting(SystemSetting.subscription) ??
        [];
    if (mySubscriptions.isNotEmpty) {
      isLifeTimeSubscription = mySubscriptions[0]['end_date'] == null;
      log(mySubscriptions[0]['id'].toString(), name: "@@@@@@@a");
      context
          .read<GetSubsctiptionPackageLimitsCubit>()
          .getLimits(Constant.subscriptionPackageId.toString());
    }

    hasAlreadyPackage = mySubscriptions.isNotEmpty;
    super.initState();
  }

  ifServiceUnlimited(int text, {dynamic remining}) {
    if (text == 0) {
      return UiUtils.getTranslatedLabel(context, "unlimited");
    }
    if (remining != null) {
      return "$remining/$text";
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    dynamic advertismentRemining = "--";
    dynamic propertyRemining = "--";
    if (context.watch<GetSubsctiptionPackageLimitsCubit>().state
        is GetSubsctiptionPackageLimitsSuccess) {
      SubcriptionPackageLimit packageLimit = (context
              .watch<GetSubsctiptionPackageLimitsCubit>()
              .state as GetSubsctiptionPackageLimitsSuccess)
          .packageLimit;

      advertismentRemining = (packageLimit.usedLimitOfAdvertisement).toString();
      propertyRemining = (packageLimit.usedLimitOfProperty).toString();
    }
    return RefreshIndicator(
      backgroundColor: context.color.primaryColor,
      color: context.color.teritoryColor,
      onRefresh: () async {
        context.read<FetchSubscriptionPackagesCubit>().fetchPackages();

        mySubscriptions = context
            .read<FetchSystemSettingsCubit>()
            .getSetting(SystemSetting.subscription);

        if (mySubscriptions.isNotEmpty) {
          isLifeTimeSubscription = mySubscriptions[0]['end_date'] == null;
        }

        hasAlreadyPackage = mySubscriptions.isNotEmpty;
      },
      child: Scaffold(
        backgroundColor: context.color.primaryColor,
        appBar: UiUtils.buildAppBar(context,
            showBackButton: true,
            title: UiUtils.getTranslatedLabel(context, "subsctiptionPlane")),
        body: BlocListener<FetchSystemSettingsCubit, FetchSystemSettingsState>(
          listener: (context, state) {
            if (state is FetchSystemSettingsSuccess) {
              mySubscriptions =
                  state.settings['package']['user_purchased_package'] as List;
              setState(() {});
            }
          },
          child: Builder(builder: (context) {
            return BlocConsumer<FetchSubscriptionPackagesCubit,
                FetchSubscriptionPackagesState>(
              listener: (context, state) {
                // if (state is FetchSubscriptionPackagesSuccess) {}
              },
              builder: (context, state) {
                if (state is FetchSubscriptionPackagesInProgress) {
                  return ListView.builder(
                    itemCount: 10,
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: CustomShimmer(
                          height: 160,
                        ),
                      );
                    },
                  );
                }
                if (state is FetchSubscriptionPackagesFailure) {
                  if (state.errorMessage.errorMessage == "no-internet") {
                    return NoInternet(
                      onRetry: () {
                        context
                            .read<FetchSubscriptionPackagesCubit>()
                            .fetchPackages();
                      },
                    );
                  }
                  return const SomethingWentWrong();
                }
                if (state is FetchSubscriptionPackagesSuccess) {
                  if (state.subscriptionPacakges.isEmpty &&
                      mySubscriptions.isEmpty) {
                    return NoDataFound(
                      onTap: () {
                        context
                            .read<FetchSubscriptionPackagesCubit>()
                            .fetchPackages();

                        mySubscriptions = context
                            .read<FetchSystemSettingsCubit>()
                            .getSetting(SystemSetting.subscription);
                        if (mySubscriptions.isNotEmpty) {
                          isLifeTimeSubscription =
                              mySubscriptions[0]['end_date'] == null;
                        }

                        hasAlreadyPackage = mySubscriptions.isNotEmpty;
                        setState(() {});
                      },
                    );
                  }

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        ...mySubscriptions.map((subscription) {
                          var packageName = subscription['package']['name'];
                          var packagePrice =
                              subscription['package']['price'].toString();
                          var packageValidity =
                              subscription['package']['duration'];
                          var advertismentLimit =
                              subscription['package']['advertisement_limit'];
                          var propertyLimit =
                              subscription['package']['property_limit'];
                          var startDate = subscription['start_date']
                              .toString()
                              .formatDate();
                          var endDate = subscription['end_date'];
                          log(subscription.toString(), name: "mysubscription");
                          if (isLifeTimeSubscription) {
                            packageValidity = "Lifetime";
                          }
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                            child: currentPackageTile(
                                name: packageName,
                                price: packagePrice,
                                advertismentLimit: advertismentLimit,
                                propertyLimit: propertyLimit,
                                duration: packageValidity,
                                endDate: endDate,
                                startDate: startDate,
                                advertismentRemining: advertismentRemining,
                                propertyRemining: propertyRemining),
                          );
                        }).toList(),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.subscriptionPacakges.length,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemBuilder: (context, index) {
                            SubscriptionPackageModel subscriptionPacakge =
                                state.subscriptionPacakges[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: buildPackageTile(
                                  context, subscriptionPacakge),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }

                return Container();
              },
            );
          }),
        ),
      ),
    );
  }

  Widget currentPackageTile(
      {required String name,
      dynamic advertismentLimit,
      dynamic propertyLimit,
      dynamic duration,
      dynamic startDate,
      dynamic endDate,
      dynamic advertismentRemining,
      dynamic propertyRemining,
      required String price}) {
    if (endDate != null) {
      endDate = endDate.toString().formatDate();
    }

    return Container(
      decoration: BoxDecoration(
          color: context.color.secondaryColor,
          borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  width: context.screenWidth,
                  child: UiUtils.getSvg(AppIcons.headerCurve,
                      color: context.color.teritoryColor, fit: BoxFit.fitWidth),
                ),
                PositionedDirectional(
                  start: 10.rw(context),
                  top: 8.rh(context),
                  child: Text(
                          UiUtils.getTranslatedLabel(context, "currentPackage"))
                      .size(context.font.larger)
                      .color(context.color.secondaryColor)
                      .bold(weight: FontWeight.w600),
                )
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(name)
                  .size(context.font.larger)
                  .color(context.color.textColorDark)
                  .bold(weight: FontWeight.w600),
            ),
            const SizedBox(
              height: 20,
            ),
            if (advertismentLimit != null)
              bullatePoint(context,
                  "${UiUtils.getTranslatedLabel(context, "adLimitIs")} ${advertismentLimit == '' ? UiUtils.getTranslatedLabel(context, "lifetime") : ifServiceUnlimited(advertismentLimit, remining: advertismentRemining)}"),
            SizedBox(
              height: 5.rh(context),
            ),
            Row(
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (propertyLimit != null)
                    bullatePoint(context,
                        "${UiUtils.getTranslatedLabel(context, "propertyLimit")} ${propertyLimit == '' ? UiUtils.getTranslatedLabel(context, "lifetime") : ifServiceUnlimited(propertyLimit, remining: propertyRemining)}"),
                  SizedBox(
                    height: 5.rh(context),
                  ),
                  if (isLifeTimeSubscription)
                    bullatePoint(context,
                        "${UiUtils.getTranslatedLabel(context, "validity")} ${endDate ?? UiUtils.getTranslatedLabel(context, "lifetime")} "),
                  if (!isLifeTimeSubscription)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: context.color.textColorDark,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(
                            width: 5.rw(context),
                          ),
                          SizedBox(
                            width: context.screenWidth * 0.5,
                            child: Text(UiUtils.getTranslatedLabel(
                                    context, "packageStartedOn") +
                                startDate +
                                UiUtils.getTranslatedLabel(
                                    context, "andPackageWillEndOn") +
                                endDate.toString()),
                          )
                        ],
                      ),
                    )
                ]),
                const Spacer(),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 15.0),
                  child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: context.color.teritoryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8)),
                      height: 39.rh(context),
                      constraints: BoxConstraints(
                        minWidth: 72.rw(context),
                      ),
                      child: Text(price.toString().formatAmount(prefix: true))
                          .color(context.color.teritoryColor)
                          .bold()
                          .size(context.font.large)),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPackageTile(
    BuildContext context,
    SubscriptionPackageModel subscriptionPacakge,
  ) {
    log(subscriptionPacakge.toString(), name: "@package");
    return Container(
      decoration: BoxDecoration(
          color: context.color.teritoryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              SizedBox(
                width: context.screenWidth,
                child: UiUtils.getSvg(AppIcons.headerCurve,
                    color: context.color.teritoryColor, fit: BoxFit.fitWidth),
              ),
              PositionedDirectional(
                start: 10.rw(context),
                top: 8.rh(context),
                child: Text(subscriptionPacakge.name ?? "")
                    .size(context.font.larger)
                    .color(context.color.secondaryColor)
                    .bold(weight: FontWeight.w600),
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          if (subscriptionPacakge.advertisementlimit != null)
            bullatePoint(context,
                "${UiUtils.getTranslatedLabel(context, "adLimitIs")} ${subscriptionPacakge.advertisementlimit == '' ? UiUtils.getTranslatedLabel(context, "lifetime") : ifServiceUnlimited(subscriptionPacakge.advertisementlimit)}"),
          SizedBox(
            height: 5.rh(context),
          ),
          Row(
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (subscriptionPacakge.propertyLimit != null)
                  bullatePoint(context,
                      "${UiUtils.getTranslatedLabel(context, "propertyLimit")} ${subscriptionPacakge.propertyLimit == '' ? UiUtils.getTranslatedLabel(context, "lifetime") : ifServiceUnlimited(subscriptionPacakge.propertyLimit)}"),
                SizedBox(
                  height: 5.rh(context),
                ),
                bullatePoint(context,
                    "${UiUtils.getTranslatedLabel(context, "validity")} ${subscriptionPacakge.duration ?? UiUtils.getTranslatedLabel(context, "lifetime")} ${UiUtils.getTranslatedLabel(context, "days")}"),
              ]),
              const Spacer(),
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 15.0),
                child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: context.color.secondaryColor,
                        borderRadius: BorderRadius.circular(8)),
                    height: 39.rh(context),
                    constraints: BoxConstraints(
                      minWidth: 72.rw(context),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(("${subscriptionPacakge.price}")
                              .toString()
                              .formatAmount(prefix: true))
                          .color(context.color.teritoryColor)
                          .bold()
                          .size(context.font.large),
                    )),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: UiUtils.buildButton(context, onPressed: () async {
              if (mySubscriptions.isEmpty) {
                PaymentGatways.openEnabled(
                    context, subscriptionPacakge.price, subscriptionPacakge);

                // Navigator.push(context, BlurredRouter(
                //   builder: (context) {
                //     return SubscriptionScreen(
                //       pacakge: subscriptionPacakge,
                //       isPackageAlready: false,
                //     );
                //   },
                // ));
              } else {
                var proceed = await UiUtils.showBlurredDialoge(context,
                    sigmaX: 3,
                    sigmaY: 3,
                    dialoge: BlurredDialogBox(
                        title: UiUtils.getTranslatedLabel(context, "warning"),
                        cancelTextColor: context.color.textColorDark,
                        acceptButtonName:
                            UiUtils.getTranslatedLabel(context, "proceed"),
                        content: Text(UiUtils.getTranslatedLabel(
                            context, "currentPacakgeActiveWarning"))));

                if (proceed == true) {
                  Future.delayed(
                    Duration.zero,
                    () {
                      log("enabled ${AppSettings.enabledPaymentGatway}");
                      // log("enabled ${AppSettings.paypal}");
                      PaymentGatways.openEnabled(context,
                          subscriptionPacakge.price, subscriptionPacakge);
                    },
                  );

                  // Future.delayed(
                  //   Duration.zero,
                  //   () {
                  //     Navigator.push(context, BlurredRouter(
                  //       builder: (context) {
                  //         return SubscriptionScreen(
                  //           pacakge: subscriptionPacakge,
                  //           isPackageAlready: true,
                  //         );
                  //       },
                  //     ));
                  //   },
                  // );
                }
              }
            },
                radius: 9,
                height: 33.rh(context),
                buttonTitle: UiUtils.getTranslatedLabel(context, "subscribe")),
          ),
        ],
      ),
    );
  }

  Widget bullatePoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: context.screenWidth * 0.55,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: context.color.textColorDark,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(
              width: 5.rw(context),
            ),
            Expanded(child: Text(text).setMaxLines(lines: 2))
          ],
        ),
      ),
    );
  }
}
