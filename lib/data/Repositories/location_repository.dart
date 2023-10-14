// ignore_for_file: file_names

import 'package:ebroker/utils/constant.dart';
import 'package:dio/dio.dart';

import '../../utils/api.dart';
import '../model/google_place_model.dart';

class GooglePlaceRepository {
  //This will search places from google place api
  //We use this to search location while adding new property
  Future<List<GooglePlaceModel>> serchCities(
    String text,
  ) async {
    try {
      ///************************ */
      Map<String, dynamic> queryParameters = {
        Api.placeApiKey: Constant.googlePlaceAPIkey,
        Api.input: text,
        Api.type: "(cities)"
      };

      ///************************ */

      // Map<String, dynamic> apiResponse = await Api.get(
      //   url: Api.placeAPI,
      //   useAuthToken: false,
      //   useBaseUrl: false,
      //   queryParameters: queryParameters,
      // );
      print("jdhdbgdsgdggdgsvbbsbsns");
      final Dio dio = Dio();
      final response = await dio.get(
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=21.2514,81.6296&radius=260000&keyword=${text}&key=AIzaSyDMXZ-xTPm64DijUZqtVWEo_I6HDA8eviw",
      );


      return _buildPlaceModelList(Map.from(response.data));
    } catch (e) {
      if (e is DioError) {}
      throw ApiException(e.toString());
    }
  }

  ///this will convert normal response to List of models so we can use it easily in code
  List<GooglePlaceModel> _buildPlaceModelList(
      Map<String, dynamic> apiResponse) {
    ///loop throuh predictions list,
    ///this will create List of GooglePlaceModel
    try {
      var filterdResult = (apiResponse["results"] as List).map((details) {
        String name = details['name'];
        String placeId = details['place_id'];



        String city = details['name'] ;
        //+ details['vicinity']
       // getLocationComponent(details, "locality");

        String country = "India";
       // getLocationComponent(details, "geocode");

        String state = "Chhattisgarh";
        //getLocationComponent(details, "political");

        ///
        ///
        GooglePlaceModel placeModel = GooglePlaceModel(
          city: city,
          description: name,
          placeId: placeId,
          state: state,
          country: country,
          latitude: '',
          longitude: '',
        );

        return placeModel;
      }).toList();

      return filterdResult;
    } catch (e) {
      rethrow;
    }
  }

  String getLocationComponent(Map details, String component) {
    int index = (details['types'] as List)
        .indexWhere((element) => element == component);
    if ((details['terms'] as List).length > index) {
      return (details['terms'] as List).elementAt(index)['value'];
    } else {
      return "";
    }
  }

  ///Google Place Autocomple api will give us Place Id.
  ///We will use this place id to get Place Details
  getPlaceDetailsFromPlaceId(String placeId) async {
    try {} catch (e) {
      rethrow;
    }
    Map<String, dynamic> queryParameters = {
      Api.placeApiKey: Constant.googlePlaceAPIkey,
      Api.placeid: placeId
    };
    Map<String, dynamic> response = await Api.get(
        url: Api.placeApiDetails,
        queryParameters: queryParameters,
        useBaseUrl: false,
        useAuthToken: false);

    return response['result']['geometry']['location'];
  }
}
