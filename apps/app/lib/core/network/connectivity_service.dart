import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService(this._connectivity);

  final Connectivity _connectivity;

  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  Future<List<ConnectivityResult>> check() => _connectivity.checkConnectivity();
}
