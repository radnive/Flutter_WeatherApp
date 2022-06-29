import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weather_app/components/message.dart';
import 'package:weather_app/generated/l10n.dart';

class Internet {
  static int okayStatusCode = 200;
  static int exceededRequestNumberStatusCode = 503;

  static Future<bool> checkAsync() async {
    return await Connectivity().checkConnectivity() != ConnectivityResult.none;
  }

  static void check(BuildContext context, {void Function()? ifConnected}) {
    Connectivity().checkConnectivity().then((result) {
      if (result == ConnectivityResult.none) {
        // Get Strings resource.
        final strings = S.of(context);

        // Show error message.
        Message(context).e(
          title: strings.noInternetErrorMessageTitle,
          subtitle: strings.noInternetErrorMessageSubtitle,
          buttonText: strings.retryButtonText,
          onButtonPressed: () {
            Internet.check(context, ifConnected: ifConnected);
          }
        );
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

      // Get Strings resource.
      final strings = S.of(context);

      // Show error message.
      Message(context).e(
        title: strings.openWebpageErrorTitleMessage,
        subtitle: strings.openWebpageErrorSubtitleMessage,
        buttonText: strings.okayButtonText
      );
    }
  }
}