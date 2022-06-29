import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

class Internet {
  static int okayStatusCode = 200;
  static int exceededRequestNumberStatusCode = 503;

  static Future<bool> checkAsync() async {
    return await Connectivity().checkConnectivity() != ConnectivityResult.none;
  }

  static void check(BuildContext context, {void Function()? ifConnected}) {
    Connectivity().checkConnectivity().then((result) {
      if (result == ConnectivityResult.none) {
        // TODO Show error message.
      } else if(ifConnected != null) {
        ifConnected();
      }
    });
  }
}