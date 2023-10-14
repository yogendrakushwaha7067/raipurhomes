import '../helper/custom_exception.dart';
import '../model/company.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/api.dart';

abstract class CompanyState {}

class CompanyInitial extends CompanyState {}

class CompanyFetchProgress extends CompanyState {}

class CompanyFetchSuccess extends CompanyState {
  List<Company> companyData = [];

  CompanyFetchSuccess(this.companyData);
}

class CompanyFetchFailure extends CompanyState {
  final String errmsg;
  CompanyFetchFailure(this.errmsg);
}

class CompanyCubit extends Cubit<CompanyState> {
  CompanyCubit() : super(CompanyInitial());

  fetchCompany(BuildContext context) {
    emit(CompanyFetchProgress());
    fetchCompanyFromDb(context)
        .then((value) => emit(CompanyFetchSuccess(value)))
        .catchError((e) => emit(CompanyFetchFailure(e.toString())));
  }

  Future<List<Company>> fetchCompanyFromDb(BuildContext context) async {
    List<Company> companyData = [];

    Map<String, String> body = {
      Api.type: Api.company,
    };

    // var response = await HelperUtils.sendApiRequest(
    //     Api.apiGetSystemSettings, body, true, context,
    //     passUserid: false);

    var response =
        await Api.post(url: Api.apiGetSystemSettings, parameter: body);

    // var getdata = json.decode(response);

    if (!response[Api.error]) {
      List list = response['data'];
      companyData = list.map((model) => Company.fromJson(model)).toList();

      companyData.firstWhere((element) => element.type == Api.tele1);

      //set company mobile/contact number for Call @ Property details
      // Constant.session
      //     .setData(Session.keyCompMobNo, contactNumber.data.toString());
    } else {
      throw CustomException(response[Api.message]);
    }

    return companyData;
  }
}
