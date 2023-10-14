import '../model/data_output.dart';
import '../model/property_model.dart';
import '../../utils/api.dart';
import '../../utils/constant.dart';

class FavoriteRepository {
  addToFavorite(int id, String type) async {
    Map<String, dynamic> paramerters = {Api.propertyId: id, Api.type: type};

    await Api.post(url: Api.addFavourite, parameter: paramerters);
  }

  removeFavorite(int id) async {
    Map<String, dynamic> paramerters = {
      Api.propertyId: id,
    };

    await Api.post(url: Api.removeFavorite, parameter: paramerters);
  }

  Future<DataOutput<PropertyModel>> fechFavorites({required int offset}) async {
    Map<String, dynamic> parameters = {
      Api.offset: offset,
      Api.limit: Constant.loadLimit
    };

    Map<String, dynamic> response = await Api.post(
      url: Api.getFavoriteProperty,
      parameter: parameters,
    );

    List<PropertyModel> modelList = (response['data'] as List)
        .map((e) => PropertyModel.fromMap(e))
        .toList();

    return DataOutput<PropertyModel>(
        total: response['total'] ?? 0, modelList: modelList);
  }
}
