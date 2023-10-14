import '../model/data_output.dart';
import '../../utils/api.dart';
import '../../utils/constant.dart';
import '../../utils/hive_utils.dart';

import '../model/property_model.dart';

enum PropertyType {
  sell("0"),
  rent("1");

  final String value;
  const PropertyType(this.value);
}

class PropertyRepository {
  ///This method will add property
  Future createProperty({required Map<String, dynamic> parameters}) async {
    var api = Api.apiPostProperty;
    if (parameters['action_type'] == "0") {
      api = Api.apiUpdateProperty;

      if ((parameters['gallary_images'] as List).isEmpty) {
        parameters.remove("gallary_images");
      }
      if (parameters['title_image'] == null ||
          parameters['title_image'] == "") {
        parameters.remove("title_image");
      }
    }

    return await Api.post(url: api, parameter: parameters);
  }

  /// it will get all proerpties
  Future<DataOutput<PropertyModel>> fetchProperty({required int offset}) async {
    Map<String, dynamic> parameters = {
      Api.offset: offset,
      Api.limit: Constant.loadLimit
    };

    Map<String, dynamic> response =
        await Api.post(url: Api.apiGetProprty, parameter: parameters);

    List<PropertyModel> modelList = (response['data'] as List)
        .map((e) => PropertyModel.fromMap(e))
        .toList();

    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  Future<DataOutput<PropertyModel>> fetchPropertyFromPropertyId(
      dynamic id) async {
    Map<String, dynamic> parameters = {Api.id: id};

    Map<String, dynamic> response =
        await Api.post(url: Api.apiGetProprty, parameter: parameters);

    List<PropertyModel> modelList = (response['data'] as List)
        .map((e) => PropertyModel.fromMap(e))
        .toList();

    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  deleteProperty(int id) async {
    await Api.post(
        url: Api.apiUpdateProperty,
        parameter: {Api.id: id, Api.actionType: "1"});
  }

  Future<DataOutput<PropertyModel>> fetchTopRatedProperty() async {
    Map<String, dynamic> parameters = {Api.topRated: "1"};

    Map<String, dynamic> response =
        await Api.post(url: Api.apiGetProprty, parameter: parameters);

    List<PropertyModel> modelList = (response['data'] as List)
        .map((e) => PropertyModel.fromMap(e))
        .toList();

    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  ///fetch most viewd proeprties
  Future<DataOutput<PropertyModel>> fetchMostViewedProperty(
      {required int offset, required bool sendCityName}) async {
    Map<String, dynamic> parameters = {
      Api.topRated: "1",
      Api.offset: offset,
      Api.limit: Constant.loadLimit
    };

    if (sendCityName) {
      if (HiveUtils.getCityName() != null) {
        if (!Constant.isDemoModeOn) {
          parameters['city'] = HiveUtils.getCityName();
        }
      }
    }

    Map<String, dynamic> response =
        await Api.post(url: Api.apiGetProprty, parameter: parameters);

    List<PropertyModel> modelList = (response['data'] as List)
        .map((e) => PropertyModel.fromMap(e))
        .toList();

    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  ///fetch advertised proeprties
  Future<DataOutput<PropertyModel>> fetchPromotedProperty(
      {required int offset, required bool sendCityName}) async {
    Map<String, dynamic> parameters = {
      Api.promoted: true,
      Api.offset: offset,
      Api.limit: Constant.loadLimit
    };
    if (sendCityName) {
      if (HiveUtils.getCityName() != null) {
        if (!Constant.isDemoModeOn) {
          parameters['city'] = HiveUtils.getCityName();
        }
      }
    }
    Map<String, dynamic> response =
        await Api.post(url: Api.apiGetProprty, parameter: parameters);

    List<PropertyModel> modelList = (response['data'] as List)
        .map((e) => PropertyModel.fromMap(e))
        .toList();

    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  Future<DataOutput<PropertyModel>> fetchMyPromotedProeprties(
      {required int offset}) async {
    Map<String, dynamic> parameters = {
      "users_promoted": 1,
      Api.offset: offset,
      Api.limit: Constant.loadLimit
    };

    Map<String, dynamic> response =
        await Api.post(url: Api.apiGetProprty, parameter: parameters);

    List<PropertyModel> modelList = (response['data'] as List)
        .map((e) => PropertyModel.fromMap(e))
        .toList();

    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  ///Search proeprty
  Future<DataOutput<PropertyModel>> searchProperty(String searchQuery,
      {required int offset}) async {
    Map<String, dynamic> parameters = {
      Api.search: searchQuery,
      Api.offset: offset,
      Api.limit: Constant.loadLimit
    };

    if (Constant.propertyFilter != null) {
      parameters.addAll(Constant.propertyFilter!.toMap());
    }

    Map<String, dynamic> response =
        await Api.post(url: Api.apiGetProprty, parameter: parameters);

    List<PropertyModel> modelList = (response['data'] as List)
        .map((e) => PropertyModel.fromMap(e))
        .toList();

    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  ///to get my properties which i had added to sell or rent
  Future<DataOutput<PropertyModel>> fetchMyProperties(
      {required int offset, required String type}) async {
    String? propertyType = _findPropertyType(type.toLowerCase());

    Map<String, dynamic> parameters = {
      Api.offset: offset,
      Api.limit: Constant.loadLimit,
      Api.userid: HiveUtils.getUserId(),
      Api.propertyType: propertyType
    };
    Map<String, dynamic> response =
        await Api.post(url: Api.apiGetProprty, parameter: parameters);

    List<PropertyModel> modelList = (response['data'] as List)
        .map((e) => PropertyModel.fromMap(e))
        .toList();

    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  String? _findPropertyType(String type) {
    if (type == "sell") {
      return "0";
    } else if (type == "rent") {
      return "1";
    }
    return null;
  }

  Future<DataOutput<PropertyModel>> fetchProperyFromCategoryId(
      {required int id, required int offset, bool? showPropertyType}) async {
    Map<String, dynamic> parameters = {
      Api.categoryId: id,
      Api.offset: offset,
      Api.limit: Constant.loadLimit
    };

    if (Constant.propertyFilter != null) {
      parameters.addAll(Constant.propertyFilter!.toMap());

      if (Constant.propertyFilter?.categoryId == "") {
        if (showPropertyType ?? true) {
          parameters.remove(Api.categoryId);
        } else {
          parameters[Api.categoryId] = id;
        }
      }
    }

    Map<String, dynamic> response =
        await Api.post(url: Api.apiGetProprty, parameter: parameters);

    List<PropertyModel> modelList = (response['data'] as List)
        .map((e) => PropertyModel.fromMap(e))
        .toList();
    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }

  ///this method will set if we are interested in any category when we click intereseted
  setInterest({required String propertyId, required String interest}) async {
    await Api.post(url: Api.interestedUsers, parameter: {
      Api.type: interest,
      Api.propertyId: propertyId,
    });
  }

  setProeprtyView(String propertyId) async {
    await Api.post(
        url: Api.setPropertyView, parameter: {Api.propertyId: propertyId});
  }

  Future updatePropertyStatus(
      {required dynamic propertyId, required dynamic status}) async {
    await Api.post(
        url: Api.updatePropertyStatus,
        parameter: {"status": status, "property_id": propertyId});
  }
}
