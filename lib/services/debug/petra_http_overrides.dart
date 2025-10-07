import 'dart:io';

import 'package:flutter/foundation.dart';

/// HTTP client overrides to handle SSL certificate issues in development environments
///
/// This class configures the HTTP client to accept self-signed certificates
/// which is useful when working with development environments, especially
/// when connecting to services with self-signed certificates like local development
/// servers or testing environments.
class PetraHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final HttpClient client = super.createHttpClient(context);

    // Accept self-signed certificates in debug mode
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
          if (kDebugMode) {
            print('⚠️ Accepting self-signed certificate for $host:$port');
          }
          return true; // Accept all certificates in debug mode
        };

    return client;
  }
}
