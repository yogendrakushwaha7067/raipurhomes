import '../../home/Widgets/property_horizontal_card.dart';
import '../../widgets/Erros/no_data_found.dart';
import '../../widgets/Erros/no_internet.dart';
import '../../widgets/Erros/something_went_wrong.dart';
import '../../../../data/cubits/favorite/add_to_favorite_cubit.dart';
import '../../../../utils/Extensions/extensions.dart';
import '../../../../utils/responsiveSize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/routes.dart';
import '../../../../data/cubits/property/fetch_my_properties_cubit.dart';
import '../../../../data/helper/designs.dart';
import '../../../../data/model/property_model.dart';
import '../../../../utils/ui_utils.dart';
import '../../widgets/shimmerLoadingContainer.dart';

FetchMyPropertiesCubit? cubitReference;
dynamic propertyType;
Map ref = {};

class SellRentScreen extends StatefulWidget {
  final String type;
  const SellRentScreen({super.key, required this.type});

  @override
  State<SellRentScreen> createState() => _SellRentScreenState();
}

class _SellRentScreenState extends State<SellRentScreen>
    with AutomaticKeepAliveClientMixin {
  late ScrollController controller;

  bool isNetworkAvailable = true;
  @override
  void initState() {
    super.initState();
    controller = ScrollController()..addListener(pageScrollListener);
    context.read<FetchMyPropertiesCubit>().fetchMyProperties(type: widget.type);
  }

  void pageScrollListener() {
    if (controller.isEndReached()) {
      if (context.read<FetchMyPropertiesCubit>().hasMoreData()) {
        context
            .read<FetchMyPropertiesCubit>()
            .fetchMoreProperties(type: widget.type);
      }
    }
  }

  statusText(String text) {
    if (text == "1") {
      return UiUtils.getTranslatedLabel(context, "active");
    } else if (text == "0") {
      return UiUtils.getTranslatedLabel(context, "deactive");
    }
  }

  statusColor(String text) {
    if (text == "1") {
      return const Color.fromRGBO(64, 171, 60, 1);
    } else {
      return const Color.fromRGBO(238, 150, 43, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.type == "sell") {
      ref['sell'] = context.read<FetchMyPropertiesCubit>();
    } else {
      ref['rent'] = context.read<FetchMyPropertiesCubit>();
    }
    return RefreshIndicator(
      color: context.color.teritoryColor,
      onRefresh: () async {
        context
            .read<FetchMyPropertiesCubit>()
            .fetchMyProperties(type: widget.type);
      },
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        body: BlocConsumer<FetchMyPropertiesCubit, FetchMyPropertiesState>(
            listener: (context, state) {
          if (state is FetchMyPropertiesFailure) {
            if (state.errorMessage.errorMessage == "no-internet") {
              isNetworkAvailable = false;
              setState(() {}); //if
            }
          }

          if (state is FetchMyPropertiesSuccess) {}
        }, builder: (context, state) {
          if (state is FetchMyPropertiesInProgress) {
            return buildMyPropertyShimmer();
          }
          if (state is FetchMyPropertiesFailure) {
            if (!isNetworkAvailable) {
              return NoInternet(
                onRetry: () {
                  context
                      .read<FetchMyPropertiesCubit>()
                      .fetchMyProperties(type: widget.type);
                },
              );
            }

            return const SomethingWentWrong();
          }

          if (state is FetchMyPropertiesSuccess) {
            if (state.myProperty.isEmpty) {
              return SizedBox(
                height: context.screenHeight - 150.rh(context),
                child: NoDataFound(
                  onTap: () {
                    context
                        .read<FetchMyPropertiesCubit>()
                        .fetchMyProperties(type: widget.type);
                  },
                ),
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: controller,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
              itemCount:
                  state.myProperty.length + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (context, index) {
                return const SizedBox(
                  height: 2,
                );
              },
              itemBuilder: ((context, index) {
                if (state.myProperty.length == index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [CircularProgressIndicator()],
                  );
                }

                PropertyModel property = state.myProperty[index];
                // log(property.titleImage!, name: "@titleimage $index");
                return GestureDetector(
                  onTap: () {
                    // HelperUtils.goToNextPage(
                    //     Routes.propertyDetails, context, false, args: );
                    cubitReference = context.read<FetchMyPropertiesCubit>();
                    Navigator.pushNamed(
                      context,
                      Routes.propertyDetails,
                      arguments: {
                        'propertyData': property,
                        'fromMyProperty': true
                      },
                    ).then((value) {
                      if (value == true) {
                        context
                            .read<FetchMyPropertiesCubit>()
                            .fetchMyProperties(type: widget.type);
                      }
                    });
                  },
                  child: BlocProvider(
                    create: (context) => AddToFavoriteCubitCubit(),
                    child: PropertyHorizontalCard(
                      property: property,

                      statusButton: StatusButton(
                        lable: statusText(property.status.toString()),
                        color: statusColor(property.status.toString()),
                        textColor: context.color.buttonColor,
                      ),
                      // useRow: true,
                    ),
                  ),
                );
              }),
            );
          }

          return Container();
        }),
      ),
    );
  }

  Widget buildMyPropertyShimmer() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
          vertical: 10 + defaultPadding, horizontal: defaultPadding),
      itemCount: 5,
      separatorBuilder: (context, index) {
        return const SizedBox(
          height: 12,
        );
      },
      itemBuilder: (context, index) {
        return Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const ClipRRect(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  child: CustomShimmer(height: 90, width: 90),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: LayoutBuilder(builder: (context, c) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(
                          height: 10,
                        ),
                        CustomShimmer(
                          height: 10,
                          width: c.maxWidth - 50,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const CustomShimmer(
                          height: 10,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        CustomShimmer(
                          height: 10,
                          width: c.maxWidth / 1.2,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        CustomShimmer(
                          height: 10,
                          width: c.maxWidth / 4,
                        ),
                      ],
                    );
                  }),
                )
              ]),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
