import 'dart:developer';
import 'dart:io';

import 'constant.dart';
import 'errorFilter.dart';
import 'hive_keys.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class ApiException implements Exception {
  ApiException(this.errorMessage);

  dynamic errorMessage;

  @override
  String toString() {
    return ErrorFilter.check(errorMessage).error;
  }
}

class Api {
  static Map<String, dynamic> headers() {
    String jwtToken = Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.jwtToken);
    if (kDebugMode) {
      return {
        "Authorization": "Bearer $jwtToken",
      };
    }

    return {
      "Authorization": "Bearer $jwtToken",
    };
  }

//Place API
  static const String _placeApiBaseUrl =
      "https://maps.googleapis.com/maps/api/place/";
  static String placeApiKey = "key";
  static const String input = "input";
  static const String types = "types";
  static const String placeid = "placeid";
  static String placeAPI = "${_placeApiBaseUrl}autocomplete/json";
  static String placeApiDetails = "${_placeApiBaseUrl}details/json";

//

  //api fun
  static String apiLogin = "user_signup";
  static String apiUpdateProfile = "update_profile";
  static String apiGetSlider = "get_slider";
  static String apiGetCategories = "get_categories";
  static String apiGetUnit = "get_unit";
  static String apiGetProprty = "get_property";
  static String apiPostProperty = "post_property";
  static String apiUpdateProperty = "update_post_property";
  static String apiGetHouseType = "get_house_type";
  static String apiGetNotificationList = "get_notification_list";
  static String setPropertyView = "set_property_total_click";
  static String apiDeleteUser = "delete_user";
  static String paypal = "paypal";

  static String getArticles = "get_articles";
  static String addFavourite = "add_favourite";
  static String removeFavorite = "delete_favourite";
  static String getPackage = "get_package";
  static String userPurchasePackage = "user_purchase_package";
  static String deleteInquiry = "delete_inquiry";
  static String getLanguagae = "get_languages";
  static String getPaymentApiKeys = "get_payment_settings";

  static String apiGetSystemSettings = "get_system_settings";
  static String apiSetPropertyEnquiry = "set_property_inquiry";
  static String apiGetPropertyEnquiry = "get_property_inquiry";
  static String apiGetNotifications = "get_notification_list";
  static String apiRemovePostImages = "remove_post_images";
  static String apigetUserbyId = "get_user_by_id";
  static String getFavoriteProperty = "get_favourite_property";
  static String interestedUsers = "interested_users";
  static String storeAdvertisement = "store_advertisement";
  static String getLimitsOfPackage = "get_limits";
  static String getPaymentDetails = "get_payment_details";
  static String deleteAdvertisement = "delete_advertisement";
  static String updatePropertyStatus = "update_property_status";
  //Chat module apis
  static String getChatList = "get_chats";
  static String sendMessage = "send_message";
  static String getMessages = "get_messages";

  //params
  static String id = "id";
  static String mobile = "mobile";
  static String type = "type";
  static String firebaseId = "firebase_id";
  static String profile = "profile";
  static String fcmId = "fcm_id";
  static String address = "address";
  static String clientAddress = "client_address";
  static String email = "email";
  static String name = "name";
  static String error = "error";
  static String message = "message";
  static String loginType = "logintype";
  static String isActive = "isActive";
  static String image = "image";
  static String category = "category";
  static String typeids = "typeids";
  static String userid = "userid";
  static String measurement = "measurement";
  static String categoryId = "category_id";
  static String title = "title";
  static String carpetArea = "carpet_area";
  static String builtUpArea = "built_up_area";
  static String plotArea = "plot_area";
  static String hectaArea = "hecta_area";
  static String acre = "acre";
  static String locationLatitude = "location_latitude";
  static String locationLongitude = "location_longitude";
  static String unitType = "unit_type";
  static String description = "description";
  static String furnished = "furnished";
  static String houseType = "house_type";
  static String taluka = "taluka";
  static String village = "village";
  static String properyType = "propery_type";
  static String price = "price";
  static String titleImage = "title_image";
  static String postCreated = "post_created";
  static String galleryImages = "gallery_images";
  static String typeId = "type_id";
  static String propertyType = "property_type";
  static String imageUrl = "image_url";
  static String gallery = "gallery";
  static String parameterTypes = "parameter_types";
  static String status = "status";
  static String totalView = "total_view";
  static String addedBy = "added_by";
  static String district = "district";
  static String state = "state";
  static String houseNo = "house_no";
  static String surveyNo = "survey_no";
  static String plotNo = "plot_no";
  static String city = "city";
  static String languageCode = "language_code";
  static String country = "country";

  //devanshi
  static String bathroom = "bathroom";
  static String aboutApp = "about_app";
  static String termsAndConditions = "terms_conditions";
  static String privacyPolicy = "privacy_policy";
  static String currencySymbol = "currency_symbol";
  static String company = "company";
  static String data = "data";
  static String actionType = "action_type";
  static String propertyId = "property_id";
  static String customerId = "customer_id";
  static String propertysId = "propertys_id";
  static String customersId = "customers_id";
  static String enqStatus = "status";
  static String search = "search";
  static String createdAt = "created_at";
  static String sendType = "send_type";
  static String created = "created";
  static String compName = "company_name";
  static String compWebsite = "company_website";
  static String compEmail = "company_email";
  static String compAdrs = "company_address";
  static String tele1 = "company_tel1";
  static String tele2 = "company_tel2";
  static String maintenanceMode = "maintenance_mode";
  static String maxPrice = "max_price";
  static String minPrice = "min_price";
  static String postedSince = "posted_since";
  static String property = "property";
  static String offset = "offset";
  static String topRated = "top_rated";
  static String promoted = "promoted";
  static String limit = "limit";
  static String packageId = "package_id";
  static String notification = "notification";
  static String v360degImage = "threeD_image";
  static String videoLink = "video_link";

  //not in use yet
  // static String offset = "offset";
  // static String limit = "limit";

  static Future<Map<String, dynamic>> post(
      {required String url,
      required Map<String, dynamic> parameter,
      Options? options,
      bool? useAuthToken,
      bool? useBaseUrl}) async {
    try {
      final Dio dio = Dio();
      final FormData formData =
          FormData.fromMap(parameter, ListFormat.multiCompatible);

      final response =
          await dio.post(((useBaseUrl ?? true) ? Constant.baseUrl : "") + url,
              data: formData,
              options: (useAuthToken ?? true)
                  ? Options(
                      contentType: "multipart/form-data",
                      headers: headers(),
                    )
                  : Options(
                      contentType: "multipart/form-data",
                    ));


      var resp = response.data;
      // resp = JsonEncoder(resp);
    //  print(response.headers);
      if (resp['error'] ?? false) {
        log("API is ${url.toString()}");
        log("parameters are $parameter");
        log("response is ${response.data} of{$url}");


        throw ApiException(resp['message'].toString());
      }
      log("API is ${url.toString()}");
      log("parameters are $parameter");
      log("response is ${response.data}  of{$url}");

      return Map.from(resp);
    } on DioError catch (e) {
      if (e.response?.statusCode == 401) {
        throw "auth-expired";
      }
      throw ApiException(
        e.error is SocketException
            ? "no-internet"
            : "Something went wrong with error ${e.response?.statusCode}",
      );
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e, st) {
      log(st.toString(), name: "@@ee");
      throw ApiException(st.toString());
    }
  }

  static Future<Map<String, dynamic>> get(
      {required String url,
      bool? useAuthToken,
      Map<String, dynamic>? queryParameters,
      bool? useBaseUrl}) async {
    try {
      //
      final Dio dio = Dio();
      log({
        "parametrs": queryParameters,
        "url": ((useBaseUrl ?? true) ? Constant.baseUrl : "") + url
      }.toString());

      final response = await dio.get(
          ((useBaseUrl ?? true) ? Constant.baseUrl : "") + url,
          queryParameters: queryParameters,
          options: (useAuthToken ?? true) ? Options(headers: headers()) : null);
      //log("API is ${url.toString()}");
      //log("parameters are $queryParameters");
      //log("response is ${response.data}");
      if (response.data['error'] == true) {
        throw ApiException(response.data['code'].toString());
      }

      return Map.from(response.data);
    } on DioError catch (e) {
      if (e.response?.statusCode == 401) {
        throw "auth-expired";
      }
      throw ApiException(e.error is SocketException
          ? "no-internet"
          : "Something went wrong with error ${e.response?.statusCode}");
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e, st) {
      throw ApiException(st.toString());
    }
  }
}
