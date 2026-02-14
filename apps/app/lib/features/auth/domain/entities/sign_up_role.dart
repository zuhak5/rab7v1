enum SignUpRole { customer, driver, merchant }

extension SignUpRoleX on SignUpRole {
  String get value => switch (this) {
    SignUpRole.customer => 'customer',
    SignUpRole.driver => 'driver',
    SignUpRole.merchant => 'merchant',
  };

  String get backendRole => switch (this) {
    SignUpRole.customer => 'rider',
    SignUpRole.driver => 'driver',
    SignUpRole.merchant => 'merchant',
  };

  String get title => switch (this) {
    SignUpRole.customer => 'العميل',
    SignUpRole.driver => 'السائق',
    SignUpRole.merchant => 'التاجر',
  };

  String get subtitle => switch (this) {
    SignUpRole.customer => 'اطلب الرحلات وتابع الحالة لحظة بلحظة.',
    SignUpRole.driver => 'استقبل الطلبات وأدر رحلاتك اليومية.',
    SignUpRole.merchant => 'أدر طلبات المتجر والتوصيل من التطبيق.',
  };
}

SignUpRole? signUpRoleFromBackend(String? value) {
  switch (value) {
    case 'rider':
      return SignUpRole.customer;
    case 'driver':
      return SignUpRole.driver;
    case 'merchant':
      return SignUpRole.merchant;
    default:
      return null;
  }
}
