import 'dart:convert';

import 'package:ebroker/utils/Extensions/extensions.dart';

import '../../model/property_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_maps_webservice/directions.dart';

import '../../../utils/api.dart';
import '../../helper/custom_exception.dart';
import '../../../utils/helper_utils.dart';

abstract class PropertyState {}

class PropertyInitial extends PropertyState {}

class PropertyFetchProgress extends PropertyState {}

class PropertyFetchSuccess extends PropertyState {
  List<PropertyModel> propertylist = [];
  int total = 0;
  PropertyFetchSuccess(this.propertylist, this.total);
}

class PropertyFetchFailure extends PropertyState {
  final String errmsg;
  PropertyFetchFailure(this.errmsg);
}

class PropertyCubit extends Cubit<PropertyState> {
  PropertyCubit() : super(PropertyInitial());

  fetchProperty(BuildContext context, Map<String, dynamic> mbodyparam,
      {bool fromUserlist = false}) {
    emit(PropertyFetchProgress());
    fetchPropertyFromDb(context, mbodyparam, fromUserlist: fromUserlist)
        .then((value) =>
            emit(PropertyFetchSuccess(value['list'], value['total'])))
        .catchError((e) => emit(PropertyFetchFailure(e.toString())));
  }

  Future<Map> fetchPropertyFromDb(
      BuildContext context, Map<String, dynamic> bodyparam,
      {bool fromUserlist = false}) async {
    //String? propertyId,
    Map result = {};
    List<PropertyModel> propertylist = [];
    int mtotal = 0;
    var response = await HelperUtils.sendApiRequest(
      Api.apiGetProprty,
      bodyparam,
      true,
      context,
      passUserid: fromUserlist,
    );
    var getdata = json.decode(response);
    if (getdata != null) {
      if (!getdata[Api.error]) {
        List list = getdata['data'];
        mtotal = getdata["total"];
        result['total'] = mtotal;
        propertylist =
            list.map((model) => PropertyModel.fromMap(model)).toList();
      } else {
        throw CustomException(getdata[Api.message]);
      }
    } else {
      Future.delayed(
        Duration.zero,
        () {
          throw CustomException("nodatafound".translate(context));
        },
      );
    }
    result['list'] = propertylist;
    return result;
  }
}
