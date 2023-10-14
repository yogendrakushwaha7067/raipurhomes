// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:ebroker/utils/errorFilter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ebroker/data/Repositories/auth_repository.dart';

abstract class VerifyOtpState {}

class VerifyOtpInitial extends VerifyOtpState {}

class VerifyOtpInProgress extends VerifyOtpState {}

class VerifyOtpSuccess extends VerifyOtpState {
  final UserCredential credential;
  VerifyOtpSuccess({
    required this.credential,
  });
}

class VerifyOtpFailure extends VerifyOtpState {
  final String errorMessage;

  VerifyOtpFailure(this.errorMessage);
}

class VerifyOtpCubit extends Cubit<VerifyOtpState> {
  final AuthRepository _authReoisitory = AuthRepository();

  VerifyOtpCubit() : super(VerifyOtpInitial());

  verifyOTP({required String verificationId, required String otp}) async {
    try {
      emit(VerifyOtpInProgress());
      UserCredential userCredential = await _authReoisitory.verifyOTP(
          otpVerificationId: verificationId, otp: otp);

      emit(VerifyOtpSuccess(credential: userCredential));
    } on FirebaseAuthException catch (e) {
      emit(VerifyOtpFailure(ErrorFilter.check(e.code).error));
    } catch (e) {
      emit(VerifyOtpFailure(e.toString()));
    }
  }

  setInitialState() {
    emit(VerifyOtpInitial());
  }
}
