import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Ui/screens/Advertisement/create_advertisement_screen.dart';
import '../Ui/screens/Articles/article_details.dart';
import '../Ui/screens/Articles/articles_screen.dart';
import '../Ui/screens/Converter/area_converter.dart';
import '../Ui/screens/favorites_screen.dart';
import '../Ui/screens/filter_screen.dart';
import '../Ui/screens/home/change_language_screen.dart';
import '../Ui/screens/home/search_screen.dart';
import '../Ui/screens/home/view_most_viewed_properties.dart';
import '../Ui/screens/home/view_promoted_properties.dart';
import '../Ui/screens/Advertisement/my_advertisment_screen.dart';
import '../Ui/screens/onboarding/onboarding_screen.dart';
import '../Ui/screens/proprties/AddProperyScreens/add_property_details.dart';
import '../Ui/screens/proprties/AddProperyScreens/select_type_of_property.dart';
import '../Ui/screens/proprties/AddProperyScreens/set_property_parameters.dart';
import '../Ui/screens/proprties/property_details.dart';
import '../Ui/screens/settings/contact_us.dart';
import '../Ui/screens/settings/my_enquiry.dart';
import '../Ui/screens/settings/notification_detail.dart';
import '../Ui/screens/settings/notifications.dart';
import '../Ui/screens/splash_screen.dart';
import '../Ui/screens/subscription/packages_list.dart';
import '../Ui/screens/subscription/subscribe_screen.dart';
import '../Ui/screens/subscription/transaction_history_screen.dart';
import '../Ui/screens/userprofile/edit_profile.dart';
import '../Ui/screens/widgets/maintenance_mode.dart';

import '../Ui/screens/auth/login_screen.dart';
import '../Ui/screens/home/category_list.dart';
import '../Ui/screens/main_activity.dart';
import '../Ui/screens/proprties/properties_list.dart';
import '../Ui/screens/settings/profile_setting.dart';
import '../Ui/screens/widgets/AnimatedRoutes/blur_page_route.dart';
import '../sandBox/playground.dart';
import '../utils/ui_utils.dart';

class Routes {
  //private constructor
  Routes._();

  static const splash = 'splash';
  static const onboarding = 'onboarding';
  static const login = 'login';
  static const completeProfile = 'complete_profile';
  static const main = 'main';
  static const home = 'Home';
  static const addProperty = 'addProperty';
  static const waitingScreen = 'waitingScreen';
  static const categories = 'Categories';
  static const addresses = 'address';
  static const chooseAdrs = 'chooseAddress';
  static const propertiesList = 'propertiesList';
  static const propertyDetails = 'PropertyDetails';
  static const contactUs = 'ContactUs';
  static const profileSettings = 'profileSettings';
  static const myEnquiry = 'MyEnquiry';
  static const filterScreen = 'filterScreen';
  static const notificationPage = 'notificationpage';
  static const notificationDetailPage = 'notificationdetailpage';
  static const addPropertyScreenRoute = 'addPropertyScreenRoute';
  static const articlesScreenRoute = 'articlesScreenRoute';
  static const subscriptionPackageListRoute = 'subscriptionPackageListRoute';
  static const subscriptionScreen = 'subscriptionScreen';
  static const maintenanceMode = '/maintenanceMode';
  static const favoritesScreen = '/favoritescreen';
  static const createAdvertismentScreenRoute = '/createAdvertisment';
  static const promotedPropertiesScreen = '/promotedPropertiesScreen';
  static const mostViewedPropertiesScreen = '/mostViewedPropertiesScreen';
  static const articleDetailsScreenRoute = '/articleDetailsScreenRoute';
  static const areaConvertorScreen = '/areaCalculatorScreen';
  static const languageListScreenRoute = '/languageListScreenRoute';
  static const searchScreenRoute = '/searchScreenRoute';

  static const myAdvertisment = '/myAdvertisment';
  static const transactionHistory = '/transactionHistory';

  ///Add property screens
  static const selectPropertyTypeScreen = '/selectPropertyType';
  static const addPropertyDetailsScreen = '/addPropertyDetailsScreen';
  static const setPropertyParametersScreen = '/setPropertyParametersScreen';

  //Sandbox[test]
  static const playground = 'playground';

  static String currentRoute = splash;
  static String previousCustomerRoute = splash;
  static Route onGenerateRouted(RouteSettings routeSettings) {
    previousCustomerRoute = currentRoute;
    currentRoute = routeSettings.name ?? "";
    switch (routeSettings.name) {
      case splash:
        return BlurredRouter(builder: ((context) => const SplashScreen()));
      case onboarding:
        return CupertinoPageRoute(
            builder: ((context) => const OnboardingScreen()));
      case main:
        return MainActivity.route(routeSettings);
      case login:
        return LoginScreen.route(routeSettings);
      case completeProfile:
        return UserProfileScreen.route(routeSettings);
      // case addProperty:
      //   return AddEditProperty.route(routeSettings);
      //return AddProperty.route(routeSettings);

      case categories:
        return CategoryList.route(routeSettings);
      case maintenanceMode:
        return MaintenanceMode.route(routeSettings);
      case languageListScreenRoute:
        return LanguagesListScreen.route(routeSettings);
      case propertiesList:
        return PropertiesList.route(routeSettings);
      case propertyDetails:
        return PropertyDetails.route(routeSettings);
      case contactUs:
        return ContactUs.route(routeSettings);
      case profileSettings:
        return ProfileSettings.route(routeSettings);

      case myEnquiry:
        return MyEnquiry.route(routeSettings);
      case filterScreen:
        return FilterScreen.route(routeSettings);
      case notificationPage:
        return Notifications.route(routeSettings);
      case notificationDetailPage:
        return NotificationDetail.route(routeSettings);

      case articlesScreenRoute:
        return ArticlesScreen.route(routeSettings);

      case areaConvertorScreen:
        return AreaCalculator.route(routeSettings);

      case articleDetailsScreenRoute:
        return ArticleDetails.route(routeSettings);
      case subscriptionPackageListRoute:
        return SubsctiptionPackageListScreen.route(routeSettings);
      case subscriptionScreen:
        return SubscriptionScreen.route(routeSettings);
      case favoritesScreen:
        return FavoritesScreen.route(routeSettings);
      case createAdvertismentScreenRoute:
        return CreateAdvertisementScreen.route(routeSettings);
      case promotedPropertiesScreen:
        return PromotedPropertiesScreen.route(routeSettings);
      case mostViewedPropertiesScreen:
        return MostViewedPropertiesScreen.route(routeSettings);

      case selectPropertyTypeScreen:
        return SelectPropertyType.route(routeSettings);

      case transactionHistory:
        return TransactionHistory.route(routeSettings);

      case myAdvertisment:
        return MyAdvertismentScreen.route(routeSettings);

      case addPropertyDetailsScreen:
        return AddPropertyDetails.route(routeSettings);
      case setPropertyParametersScreen:
        return SetProeprtyParametersScreen.route(routeSettings);
      case searchScreenRoute:
        return SearchScreen.route(routeSettings);
      //sandBox//Playground
      case playground:
        return PlayGround.route(routeSettings);
      default:
        return BlurredRouter(
          builder: ((context) => Scaffold(
                body: Text(
                  UiUtils.getTranslatedLabel(context, "pageNotFoundErrorMsg"),
                ),
              )),
        );
    }
  }
}
