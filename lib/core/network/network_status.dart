import 'package:connectivity_plus/connectivity_plus.dart';

abstract interface class NetworkStatus {
  Future<bool> checkConnectivity();

  Stream<bool> get connectivityChanges;
}

final class ConnectivityNetworkStatus implements NetworkStatus {
  ConnectivityNetworkStatus({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> checkConnectivity() async {
    return _hasConnection(await _connectivity.checkConnectivity());
  }

  @override
  Stream<bool> get connectivityChanges {
    return _connectivity.onConnectivityChanged.map(_hasConnection).distinct();
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }
}
