import '../repositories/auth_repository.dart';

class VerifyPhoneOtpUseCase {
  const VerifyPhoneOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String phone, required String otp}) {
    return _repository.verifyPhoneOtp(phone: phone, otp: otp);
  }
}
