import '../repositories/auth_repository.dart';

class RequestPhoneOtpUseCase {
  const RequestPhoneOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call(String phone) {
    return _repository.requestPhoneOtp(phone);
  }
}
