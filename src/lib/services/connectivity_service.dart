import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService {
  final _connectivity = Connectivity();
  final _internetChecker = InternetConnection(); // from internet_connection_checker_plus
  final _connectivityController = StreamController<bool>.broadcast();

  Stream<bool> get connectivityStream => _connectivityController.stream;

  ConnectivityService() {
    _initConnectivity();
  }

  void _initConnectivity() {
    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((_) async {
      final hasInternet = await checkConnection();
      _connectivityController.add(hasInternet);
    });

    // Also listen to actual internet access changes
    _internetChecker.onStatusChange.listen((status) {
      final hasInternet = status == InternetStatus.connected;
      _connectivityController.add(hasInternet);
    });
  }

  Future<bool> checkConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    return await _internetChecker.hasInternetAccess;
  }

  void dispose() {
    _connectivityController.close();
  }
}
