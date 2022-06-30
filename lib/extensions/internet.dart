import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weather_app/components/message.dart';
import 'package:weather_app/generated/l10n.dart';
import 'package:http/http.dart' as http;

class Internet {
  static int okayStatusCode = 200;
  static int exceededRequestNumberStatusCode = 503;

  /// Check internet connection asynchronous.
  static Future<bool> checkAsync() async {
    return await Connectivity().checkConnectivity() != ConnectivityResult.none;
  }

  /// Check internet connection.
  static void check(BuildContext context, {
    void Function()? ifConnected,
    void Function()? onError
  }) {
    Connectivity().checkConnectivity().then((result) {
      if (result == ConnectivityResult.none) {
        // Call on error method.
        if(onError != null) onError();

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

  /// Open url in browser.
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

  /// Send GET request using http dependency.
  /// !! This method using MessageSnackBar to notify user. !!
  static void get(BuildContext context, {
    required Uri uri,
    void Function(http.Response)? onResponse,
    void Function()? onNoResponse,
    void Function()? onRetry,
    void Function(dynamic error)? onError,
    void Function(bool isOkay)? onComplete
  }) {
    // Show error message.
    void showErrorMessage(dynamic error) {
      // Call onError method.
      if(onError != null) onError(error);
      // Call onCompleted method.
      if(onComplete != null) onComplete(false);
      // Get Strings resource.
      final S strings = S.of(context);
      // Show error message.
      Message(context).e(
        title: strings.somethingWentWrongTitle,
        subtitle: strings.somethingWentWrongSubtitle,
        buttonText: strings.retryButtonText,
        onButtonPressed: () {
          // Call onRetry method.
          if(onRetry != null) onRetry();
          // Call get method message again.
          get(
            context,
            uri: uri,
            onResponse: onResponse,
            onNoResponse: onNoResponse,
            onError: onError,
            onComplete: onComplete
          );
        }
      );
    }

    http.get(uri).then((response) {
      if(response.statusCode == okayStatusCode) {
        // Call onResponse method.
        if(onResponse != null) onResponse(response);
        // Call onComplete method.
        if(onComplete != null) onComplete(true);
      } else if(response.statusCode == exceededRequestNumberStatusCode) {
        // Call onNoResponse method.
        if(onNoResponse != null) onNoResponse();
        // Call onComplete method.
        if(onComplete != null) onComplete(false);
        // Get Strings resource.
        final S strings = S.of(context);
        // Show warning message.
        Message(context).w(
          title: strings.requestsNumberErrorMessageTitle,
          subtitle: strings.requestsNumberErrorMessageSubtitle,
          buttonText: strings.okayButtonText
        );
      } else {
        showErrorMessage(response.statusCode);
      }
    }, onError: (error) {
      showErrorMessage(error);
    });
  }
}