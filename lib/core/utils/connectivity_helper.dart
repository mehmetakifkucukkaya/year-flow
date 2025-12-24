import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  const ConnectivityHelper._();

  /// Check if device is online
  static Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Get network status stream as boolean: true when online
  static Stream<bool> get onlineStatusStream {
    return Connectivity().onConnectivityChanged.map(
          (result) => result != ConnectivityResult.none,
        );
  }
}
