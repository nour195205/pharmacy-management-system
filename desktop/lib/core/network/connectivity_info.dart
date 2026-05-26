import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

class ConnectivityInfoImpl implements ConnectivityInfo {
  final Connectivity _connectivity;

  ConnectivityInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return _hasInternet(result);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((results) => _hasInternet(results));
  }

  bool _hasInternet(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((result) => result != ConnectivityResult.none);
  }
}
