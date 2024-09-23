import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectUtil{
  static bool checkNetwork(List<ConnectivityResult> connectivityResult) {
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      return true; /// The app is connected to a mobile network.
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      return true; /// The app is connected to a WiFi network.
    }
    return false;
  }

  static Future<bool> getStateNetwork() async{
    List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
    return checkNetwork(connectivityResult);
  }
}
