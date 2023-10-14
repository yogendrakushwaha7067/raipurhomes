// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ebroker/utils/api.dart';

class GetApiKeysCubit extends Cubit<GetApiKeysState> {
  GetApiKeysCubit() : super(GetApiKeysInitial());

  Future<void> fetch() async {
    try {
      emit(
        GetApiKeysInProgress(),
      );

      Map<String, dynamic> result = await Api.post(
        url: Api.getPaymentApiKeys,
        parameter: {},
      );
      List data = (result['data'] as List);

      var razorpayKey = _getDataFromKey(data, "razor_key");
      var razorPaySecret = _getDataFromKey(data, "razor_secret");
      var paystackPublicKey = _getDataFromKey(data, "paystack_public_key");
      var paystackSecretKey = _getDataFromKey(data, "paystack_secret_key");
      var paystackCurrency = _getDataFromKey(data, "paystack_currency");
      String enabledGatway = "";
      if (_getDataFromKey(data, "paypal_gateway") == "1") {
        enabledGatway = "paypal";
      } else if (_getDataFromKey(data, "razorpay_gateway") == "1") {
        enabledGatway = "razorpay";
      } else if (_getDataFromKey(data, "paystack_gateway") == "1") {
        enabledGatway = "paystack";
      }

      emit(
        GetApiKeysSuccess(
          razorPayKey: razorpayKey,
          enabledPaymentGatway: enabledGatway,
          razorPaySecret: razorPaySecret,
          paystackPublicKey: paystackPublicKey,
          paystackCurrency: paystackCurrency,
          paystackSecret: paystackSecretKey,
        ),
      );
    } catch (e) {
      log("erorr is a $e ");
      emit(GetApiKeysFail(e.toString()));
    }
  }

  _getDataFromKey(List data, String key) {
    return data.where((element) => element['type'] == key).first['data'];
  }
}

abstract class GetApiKeysState {}

class GetApiKeysInitial extends GetApiKeysState {}

class GetApiKeysInProgress extends GetApiKeysState {}

class GetApiKeysSuccess extends GetApiKeysState {
  final String razorPayKey;
  final String razorPaySecret;
  final String paystackPublicKey;
  final String paystackSecret;
  final String paystackCurrency;
  final String enabledPaymentGatway;
  GetApiKeysSuccess({
    required this.razorPayKey,
    required this.razorPaySecret,
    required this.enabledPaymentGatway,
    required this.paystackPublicKey,
    required this.paystackCurrency,
    required this.paystackSecret,
  });
}

class GetApiKeysFail extends GetApiKeysState {
  final dynamic error;
  GetApiKeysFail(this.error);
}
