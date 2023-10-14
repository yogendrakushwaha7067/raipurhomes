import '../model/article_model.dart';
import '../model/data_output.dart';
import '../../utils/api.dart';
import '../../utils/constant.dart';

class ArticlesRepository {
  Future<DataOutput<ArticleModel>> fetchArticles({required int offset}) async {
    Map<String, dynamic> parameters = {
      Api.offset: offset,
      Api.limit: Constant.loadLimit
    };

    Map<String, dynamic> result =
        await Api.post(url: Api.getArticles, parameter: parameters);

    List<ArticleModel> modelList = (result['data'] as List)
        .map((element) => ArticleModel.fromJson(element))
        .toList();

    return DataOutput<ArticleModel>(
        total: result['total'] ?? 0, modelList: modelList);
  }
}
