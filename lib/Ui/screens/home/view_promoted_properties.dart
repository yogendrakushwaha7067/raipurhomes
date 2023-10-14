import 'Widgets/property_horizontal_card.dart';
import '../widgets/Erros/no_data_found.dart';
import '../widgets/Erros/something_went_wrong.dart';
import '../../../data/cubits/property/fetch_promoted_properties_cubit.dart';
import '../../../data/model/property_model.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/AnimatedRoutes/blur_page_route.dart';

import '../../../app/routes.dart';
import '../../../utils/helper_utils.dart';

class PromotedPropertiesScreen extends StatefulWidget {
  const PromotedPropertiesScreen({super.key});

  static Route route(RouteSettings routeSettings) {
    return BlurredRouter(
      builder: (context) {
        return const PromotedPropertiesScreen();
      },
    );
  }

  @override
  State<PromotedPropertiesScreen> createState() =>
      _PromotedPropertiesScreenState();
}

class _PromotedPropertiesScreenState extends State<PromotedPropertiesScreen> {
  ///This Scroll controller for listen page end
  final ScrollController _pageScollController = ScrollController();
  @override
  void initState() {
    _pageScollController.addListener(onPageEnd);
    super.initState();
  }

  ///This method will listen page scroll changes
  void onPageEnd() {
    // / / /This is exetension which will check if we reached end or not
    if (_pageScollController.isEndReached()) {
      if (context.read<FetchPromotedPropertiesCubit>().hasMoreData()) {
        context
            .read<FetchPromotedPropertiesCubit>()
            .fetchPromotedPropertiesMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: AppBar(
        backgroundColor: context.color.secondaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: context.color.teritoryColor),
        title: Text(
          UiUtils.getTranslatedLabel(context, "promotedProperties"),
        ).color(context.color.teritoryColor).size(context.font.large),
      ),
      body: BlocBuilder<FetchPromotedPropertiesCubit,
          FetchPromotedPropertiesState>(
        builder: (context, state) {
          if (state is FetchPromotedPropertiesInProgress) {
            return Center(
              child: UiUtils.progress(
                  normalProgressColor: context.color.teritoryColor),
            );
          }
          if (state is FetchPromotedPropertiesFailure) {
            return const SomethingWentWrong();
          }
          if (state is FetchPromotedPropertiesSuccess) {
            if (state.propertymodel.isEmpty) {
              return Center(
                child: NoDataFound(
                  onTap: () {
                    context
                        .read<FetchPromotedPropertiesCubit>()
                        .fetchPromotedProperties();
                  },
                ),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: ScrollConfiguration(
                    behavior: RemoveGlow(),
                    child: ListView.builder(
                      controller: _pageScollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: state.propertymodel.length,
                      itemBuilder: (context, index) {
                        PropertyModel property = state.propertymodel[index];
                        return GestureDetector(
                            onTap: () {
                              HelperUtils.goToNextPage(
                                  Routes.propertyDetails, context, false,
                                  args: {
                                    'propertyData': property,
                                    'propertiesList': state.propertymodel,
                                    'fromMyProperty': false,
                                  });
                            },
                            child: PropertyHorizontalCard(property: property));
                      },
                    ),
                  ),
                ),
                if (state.isLoadingMore) UiUtils.progress()
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}
