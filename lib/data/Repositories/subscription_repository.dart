import '../model/data_output.dart';
import '../model/subscription_pacakage_model.dart';
import '../../utils/api.dart';
import '../../utils/hive_utils.dart';

class SubscriptionRepository {
  Future<DataOutput<SubscriptionPackageModel>> getSubscriptionPacakges() async {
    Map<String, dynamic> response =
        await Api.post(url: Api.getPackage, parameter: {});

    List<SubscriptionPackageModel> modelList = (response['data'] as List)
        .map((element) => SubscriptionPackageModel.fromJson(element))
        .toList();

    return DataOutput(total: modelList.length, modelList: modelList);
  }

  subscribeToPackage(int packageId, bool isPackageAvailable) async {
    try {
      Map<String, dynamic> parameters = {
        Api.packageId: packageId,
        Api.userid: HiveUtils.getUserId(),
      };
      if (isPackageAvailable) {
        parameters['flag'] = 1;
      }

      await Api.post(url: Api.userPurchasePackage, parameter: parameters);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
