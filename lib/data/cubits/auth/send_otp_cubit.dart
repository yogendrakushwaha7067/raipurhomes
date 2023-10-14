// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ebroker/data/Repositories/auth_repository.dart';

String verificationID = "";

abstract class SendOtpState {}

class SendOtpInitial extends SendOtpState {}

class SendOtpInProgress extends SendOtpState {}

class SendOtpSuccess extends SendOtpState {
  final String verificationId;
  SendOtpSuccess({
    required this.verificationId,
  });
}

class SendOtpFailure extends SendOtpState {
  final String errorMessage;

  SendOtpFailure(this.errorMessage);
}

class SendOtpCubit extends Cubit<SendOtpState> {
  SendOtpCubit() : super(SendOtpInitial());

  final AuthRepository _authRepository = AuthRepository();
  void sendOTP({required String phoneNumber}) async {
    try {
      emit(SendOtpInProgress());
      await _authRepository.sendOTP(
        phoneNumber: phoneNumber,
        onCodeSent: (verificationId) {
          verificationID = verificationId;
          emit(SendOtpSuccess(verificationId: verificationId));
        },
        onError: (e) {
          log("ERROR WHILE SEND OTP");
          emit(SendOtpFailure(e.toString()));
        },
      );
    } catch (e) {
      emit(SendOtpFailure(e.toString()));
    }
  }

  setToInitial() {
    emit(SendOtpInitial());
  }
}
