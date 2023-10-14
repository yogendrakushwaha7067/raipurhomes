import 'dart:async';

import 'Widgets/property_horizontal_card.dart';
import '../widgets/AnimatedRoutes/blur_page_route.dart';
import '../widgets/Erros/something_went_wrong.dart';
import '../../../utils/AppIcon.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/responsiveSize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/routes.dart';
import '../../../data/cubits/property/search_property_cubit.dart';
import '../../../data/helper/designs.dart';
import '../../../utils/helper_utils.dart';
import '../../../data/model/property_model.dart';
import '../../../utils/ui_utils.dart';

class SearchScreen extends StatefulWidget {
  final bool autoFocus;
  final bool openFilterScreen;
  const SearchScreen(
      {Key? key, required this.autoFocus, required this.openFilterScreen})
      : super(key: key);
  static Route route(RouteSettings settings) {
    Map? arguments = settings.arguments as Map?;
    return BlurredRouter(
      builder: (context) {
        return SearchScreen(
          autoFocus: arguments?['autoFocus'],
          openFilterScreen: arguments?['openFilterScreen'],
        );
      },
    );
  }

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<SearchScreen> {
  @override
  bool get wantKeepAlive => true;
  bool isFocused = false;
  String previouseSearchQuery = "";
  static TextEditingController searchController = TextEditingController();
  int offset = 0;
  late ScrollController controller;
  List<PropertyModel> propertylist = [];
  List idlist = [];
  Timer? _searchDelay;
  bool showContent = true;
  @override
  void initState() {
    super.initState();

    if (widget.openFilterScreen) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pushNamed(context, Routes.filterScreen);
      });
    }
    searchController = TextEditingController();
    searchController.addListener(searchPropertyListener);
    controller = ScrollController()..addListener(pageScrollListen);
  }

  pageScrollListen() {
    if (controller.isEndReached()) {
      if (context.read<SearchPropertyCubit>().hasMoreData()) {
        context.read<SearchPropertyCubit>().fetchMoreSearchData();
      }
    }
  }

//this will listen and manage search
  void searchPropertyListener() {
    _searchDelay?.cancel();
    searchCallAfterDelay();
  }

//This will create delay so we don't face rapid api call
  void searchCallAfterDelay() {
    _searchDelay = Timer(const Duration(milliseconds: 500), propertySearch);
  }

  ///This will call api after some delay
  propertySearch() {
    if (searchController.text.isNotEmpty) {
      if (previouseSearchQuery != searchController.text) {
        context
            .read<SearchPropertyCubit>()
            .searchProperty(searchController.text, offset: 0);
        previouseSearchQuery = searchController.text;
      }
    } else {
      context.read<SearchPropertyCubit>().clearSearch();
    }
  }

  Widget filterOptionsBtn() {
    return IconButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.filterScreen).then((value) {
            if (value == true) {
              context
                  .read<SearchPropertyCubit>()
                  .searchProperty(searchController.text, offset: 0);
            }
          });
        },
        icon: Icon(
          Icons.filter_list_rounded,
          color: Theme.of(context).colorScheme.blackColor,
        ));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: context.color.primaryColor,
        title: searchTextField(),
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          Expanded(
            child: BlocBuilder<SearchPropertyCubit, SearchPropertyState>(
              builder: (context, state) {
                return listWidget(state);
              },
            ),
          ),
        ],
      ),
    );
  }

  listWidget(SearchPropertyState state) {
    if (state is SearchPropertyFetchProgress) {
      return Center(
        child:
            UiUtils.progress(normalProgressColor: context.color.teritoryColor),
      );
    }
    if (state is SearchPropertyFailure) {
      return const SomethingWentWrong();
    }

    if (state is SearchPropertySuccess) {
      if (state.searchedroperties.isEmpty) {
        return Center(
          child: Text(
            UiUtils.getTranslatedLabel(context, "nodatafound"),
          ),
        );
      }
      if (searchController.text == "") {
        return Center(
          child: Text(
            UiUtils.getTranslatedLabel(context, "nodatafound"),
          ),
        );
      }
      return SingleChildScrollView(
        controller: controller,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Wrap(
                direction: Axis.horizontal,
                children:
                    List.generate(state.searchedroperties.length, (index) {
                  PropertyModel property = state.searchedroperties[index];
                  List propertiesList = state.searchedroperties;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 0,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        HelperUtils.goToNextPage(
                            Routes.propertyDetails, context, false, args: {
                          'propertyData': property,
                          'propertiesList': propertiesList
                        });
                      },
                      child: PropertyHorizontalCard(property: property),
                    ),
                  );
                }),
              ),
              if (state.isLoadingMore) UiUtils.progress()
            ],
          ),
        ),
      );
    }
    return Container();
  }

  Widget setSearchIcon() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: UiUtils.getSvg(AppIcons.search));
  }

  Widget setSuffixIcon() {
    return GestureDetector(
      onTap: () {
        searchController.clear();
        isFocused = false; //set icon color to black back
        FocusScope.of(context).unfocus(); //dismiss keyboard
        setState(() {});
      },
      child: Icon(
        Icons.close_rounded,
        color: Theme.of(context).colorScheme.blackColor,
        size: 30,
      ),
    );
  }

  Widget searchTextField() {
    return FittedBox(
      fit: BoxFit.none,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Container(
                width: 270.rw(context),
                height: 50.rh(context),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 1.5, color: context.color.borderColor),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: context.color.secondaryColor),
                child: TextFormField(
                    autofocus: widget.autoFocus,
                    controller: searchController,
                    decoration: InputDecoration(
                      border: InputBorder.none, //OutlineInputBorder()
                      fillColor: Theme.of(context).colorScheme.secondaryColor,
                      hintText:
                          UiUtils.getTranslatedLabel(context, "searchHintLbl"),
                      prefixIcon: setSearchIcon(),
                      prefixIconConstraints:
                          const BoxConstraints(minHeight: 5, minWidth: 5),
                    ),
                    enableSuggestions: true,
                    onEditingComplete: () {
                      setState(
                        () {
                          isFocused = false;
                        },
                      );
                      FocusScope.of(context).unfocus();
                    },
                    onTap: () {
                      //change prefix icon color to primary
                      setState(() {
                        isFocused = true;
                      });
                    })),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.filterScreen,
              ).then((value) {
                if (value == true) {
                  context
                      .read<SearchPropertyCubit>()
                      .searchProperty(searchController.text, offset: 0);
                }
              });
            },
            child: Container(
              width: 50.rw(context),
              height: 50.rh(context),
              decoration: BoxDecoration(
                border:
                    Border.all(width: 1.5, color: context.color.borderColor),
                color: context.color.secondaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: UiUtils.getSvg(AppIcons.filter),
              ),
            ),
          ),
          SizedBox(
            width: 20.rw(context),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
