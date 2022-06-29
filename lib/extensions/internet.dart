import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

  static void openUrl(BuildContext context, {required String url, void Function()? onError}) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch(error) {
      if (onError != null) { onError(); }
      // TODO Show error message.
    }
  }
}