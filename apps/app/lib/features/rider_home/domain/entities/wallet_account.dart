import 'package:equatable/equatable.dart';

class WalletAccountEntity extends Equatable {
  const WalletAccountEntity({
    required this.balanceIqd,
    required this.currency,
    required this.updatedAt,
    this.heldIqd = 0,
  });

  final int balanceIqd;
  final int heldIqd;
  final String currency;
  final DateTime updatedAt;

  @override
  List<Object> get props => <Object>[balanceIqd, heldIqd, currency, updatedAt];
}
