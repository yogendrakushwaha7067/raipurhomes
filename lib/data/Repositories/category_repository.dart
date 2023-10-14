import '../model/category.dart';
import '../model/data_output.dart';
import '../../utils/api.dart';

import '../../utils/constant.dart';

class CategoryRepository {
  Future<DataOutput<Category>> fetchCategories({
    required int offset,
  }) async {
    Map<String, dynamic> parameters = {
      Api.offset: offset,
      Api.limit: Constant.loadLimit,
    };
    Map<String, dynamic> response =
        await Api.post(url: Api.apiGetCategories, parameter: parameters);

    List<Category> modelList = (response['data'] as List).map(
      (e) {
        return Category.fromJson(e);
      },
    ).toList();

    return DataOutput(total: response['total'] ?? 0, modelList: modelList);
  }
}
