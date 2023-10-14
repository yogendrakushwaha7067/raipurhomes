import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Ui/screens/chat/chatAudio/globals.dart';
import 'app/app.dart';
import 'app/app_localization.dart';
import 'app/app_theme.dart';
import 'app/routes.dart';
import 'data/cubits/Utility/google_place_autocomplate_cubit.dart';
import 'data/cubits/Utility/house_type_cubit.dart';
import 'data/cubits/Utility/like_properties.dart';
import 'data/cubits/auth/auth_cubit.dart';
import 'data/cubits/auth/auth_state_cubit.dart';
import 'data/cubits/auth/login_cubit.dart';
import 'data/cubits/auth/send_otp_cubit.dart';
import 'data/cubits/auth/verify_otp_cubit.dart';
import 'data/cubits/category/fetch_category_cubit.dart';
import 'data/cubits/chatCubits/get_chat_users.dart';
import 'data/cubits/company_cubit.dart';
import 'data/cubits/enquiry/delete_enquiry_cubit.dart';
import 'data/cubits/enquiry/enquiry_status_cubit.dart';
import 'data/cubits/enquiry/fetch_my_enquiry_cubit.dart';
import 'data/cubits/enquiry/send_enquiry_cubit.dart';
import 'data/cubits/enquiry/store_enqury_id.dart';
import 'data/cubits/favorite/add_to_favorite_cubit.dart';
import 'data/cubits/favorite/fetch_favorites_cubit.dart';
import 'data/cubits/favorite/remove_favoriteubit.dart';
import 'data/cubits/fetch_articles_cubit.dart';
import 'data/cubits/fetch_notifications_cubit.dart';
import 'data/cubits/profile_setting_cubit.dart';
import 'data/cubits/property/create_property_cubit.dart';
import 'data/cubits/property/favorite_id_properties.dart';
import 'data/cubits/property/fetch_home_properties_cubit.dart';
import 'data/cubits/property/fetch_most_viewed_properties_cubit.dart';
import 'data/cubits/property/fetch_my_properties_cubit.dart';
import 'data/cubits/property/fetch_promoted_properties_cubit.dart';
import 'data/cubits/property/fetch_property_from_category_cubit.dart';
import 'data/cubits/property/fetch_top_rated_properties_cubit.dart';
import 'data/cubits/property/property_cubit.dart';
import 'data/cubits/property/search_property_cubit.dart';
import 'data/cubits/property/set_property_view_cubit.dart';
import 'data/cubits/property/top_viewed_property_cubit.dart';
import 'data/cubits/slider_cubit.dart';
import 'data/cubits/subscription/fetch_subscription_packages_cubit.dart';
import 'data/cubits/subscription/get_subsctiption_package_limits_cubit.dart';
import 'data/cubits/system/app_theme_cubit.dart';
import 'data/cubits/system/delete_account_cubit.dart';
import 'data/cubits/system/fetch_language_cubit.dart';
import 'data/cubits/system/fetch_system_settings_cubit.dart';
import 'data/cubits/system/get_api_keys_cubit.dart';
import 'data/cubits/system/language_cubit.dart';
import 'data/cubits/system/notification_cubit.dart';
import 'data/cubits/system/user_details.dart';
import 'settings.dart';
import 'utils/Notification/awsomeNotification.dart';
import 'utils/Notification/notification_service.dart';
import 'utils/constant.dart';
import 'utils/deeplinkManager.dart';
import 'utils/hive_utils.dart';

///////////
///V-1.0.2
///////////

void main(arguments) {
  initApp();
}

class EntryPoint extends StatefulWidget {
  final SharedPreferences prefr;
  const EntryPoint({Key? key, required this.prefr}) : super(key: key);

  @override
  createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  @override
  void initState() {
    super.initState();
    ChatGlobals.init();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AuthCubit()),
          BlocProvider(create: (context) => LoginCubit()),
          BlocProvider(create: (context) => SliderCubit()),
          BlocProvider(create: (context) => CompanyCubit()),
          BlocProvider(create: (context) => SendOtpCubit()),
          BlocProvider(create: (context) => PropertyCubit()),
          BlocProvider(create: (context) => VerifyOtpCubit()),
          BlocProvider(create: (context) => FetchCategoryCubit()),
          BlocProvider(create: (context) => HouseTypeCubit()),
          BlocProvider(create: (context) => SearchPropertyCubit()),
          BlocProvider(create: (context) => DeleteAccountCubit()),
          BlocProvider(create: (context) => TopViewedPropertyCubit()),
          BlocProvider(create: (context) => ProfileSettingCubit()),
          BlocProvider(create: (context) => NotificationCubit()),
          BlocProvider(create: (context) => EnquiryStatusCubit()),
          BlocProvider(create: (context) => AppThemeCubit()),
          BlocProvider(create: (context) => AuthenticationCubit()),
          BlocProvider(create: (context) => FetchHomePropertiesCubit()),
          BlocProvider(create: (context) => FetchTopRatedPropertiesCubit()),
          BlocProvider(create: (context) => FetchMyPropertiesCubit()),
          BlocProvider(create: (context) => FetchMyEnquiryCubit()),
          BlocProvider(create: (context) => FetchPropertyFromCategoryCubit()),
          BlocProvider(create: (context) => SendEnquiryCubit()),
          BlocProvider(create: (context) => FetchNotificationsCubit()),
          BlocProvider(create: (context) => LanguageCubit()),
          BlocProvider(create: (context) => GooglePlaceAutocompleteCubit()),
          BlocProvider(create: (context) => FetchArticlesCubit()),
          BlocProvider(create: (context) => FetchSystemSettingsCubit()),
          BlocProvider(create: (context) => FavoriteIDsCubit()),
          BlocProvider(create: (context) => DeleteEnquiryCubit()),
          BlocProvider(create: (context) => FetchPromotedPropertiesCubit()),
          BlocProvider(create: (context) => FetchMostViewedPropertiesCubit()),
          BlocProvider(create: (context) => FetchFavoritesCubit()),
          BlocProvider(create: (context) => CreatePropertyCubit()),
          BlocProvider(create: (context) => UserDetailsCubit()),
          BlocProvider(create: (context) => FetchLanguageCubit()),
          BlocProvider(create: (context) => LikedPropertiesCubit()),
          BlocProvider(create: (context) => EnquiryIdsLocalCubit()),
          BlocProvider(create: (context) => AddToFavoriteCubitCubit()),
          BlocProvider(create: (context) => FetchSubscriptionPackagesCubit()),
          BlocProvider(create: (context) => RemoveFavoriteCubit()),
          BlocProvider(create: (context) => GetApiKeysCubit()),
          BlocProvider(create: (context) => SetPropertyViewCubit()),
          BlocProvider(create: (context) => GetChatListCubit()),
          BlocProvider(
              create: (context) => GetSubsctiptionPackageLimitsCubit()),
        ],
        child: Builder(builder: (context) {
          return const App();
        }));
  }
}

class App extends StatefulWidget {
  const App({super.key});
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    context.read<LanguageCubit>().loadCurrentLanguage();
    AppTheme currentTheme = HiveUtils.getCurrentTheme();

    LocalAwsomeNotification().init(context);
    NotificationService.init(context);
    DeepLinkManager.initDeepLinks(context);
    context.read<AppThemeCubit>().changeTheme(currentTheme);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = context.watch<AppThemeCubit>().state.appTheme;
    return BlocListener<FetchLanguageCubit, FetchLanguageState>(
      listener: (context, state) {},
      child: BlocListener<GetApiKeysCubit, GetApiKeysState>(
        listener: (context, state) {
          if (state is GetApiKeysSuccess) {
            ///Asigning Api keys from here
            AppSettings.paystackKey = state.paystackPublicKey;
            AppSettings.razorpayKey = state.razorPayKey;
            AppSettings.enabledPaymentGatway = state.enabledPaymentGatway;
            AppSettings.paystackCurrency = state.paystackCurrency;
          }
        },
        child: BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, languageState) {
            return MaterialApp(
              initialRoute: Routes
                  .splash, // App will start from here splash screen is first screen,
              navigatorKey: Constant.navigatorKey,
              title: Constant.appName,
              debugShowCheckedModeBanner: false,
              onGenerateRoute: Routes.onGenerateRouted,
              theme: appThemeData[currentTheme],
              builder: (context, child) {
                TextDirection direction;
                if (languageState is LanguageLoader) {
                  if (Constant.totalRtlLanguages
                      .contains((languageState).languageCode)) {
                    direction = TextDirection.rtl;
                  } else {
                    direction = TextDirection.ltr;
                  }
                } else {
                  direction = TextDirection.ltr;
                }

                return Directionality(
                  textDirection: direction,
                  child: DevicePreview(
                    enabled: false,
                    builder: (context) {
                      return child!;
                    },
                  ),
                );
              },
              localizationsDelegates: const [
                AppLocalization.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              locale: loadLocalLanguageIfFail(
                languageState,
              ),
            );
          },
        ),
      ),
    );
  }

  loadLocalLanguageIfFail(LanguageState state) {
    if ((state is LanguageLoader)) {
      return Locale(state.languageCode);
    } else if (state is LanguageLoadFail) {
      return const Locale("en");
    }
  }
}
