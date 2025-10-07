import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:petrasoft_school_management_solutions/services/endpoint_manager/local_utils/petra_http.service.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionChecker {
  String? _packageVersion;
  String? _storeVersion;
  final _petraHttp = PetraHttp();

  String? get packageVersion => _packageVersion;
  String? get storeVersion => _storeVersion;

  Future<void> checkVersion(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _packageVersion = packageInfo.version;

      if (Platform.isAndroid) {
        await _getPlayStoreVersion(packageInfo.packageName);
      } else if (Platform.isIOS) {
        await _getAppStoreVersion(packageInfo.packageName);
      }
    } catch (e) {
      debugPrint('Version check failed: $e');
    }
  }

  Future<void> _getPlayStoreVersion(String packageName) async {
    try {
      final response = await _petraHttp.get(
        'https://play.google.com/store/apps/details?id=$packageName',
      );

      if (response.statusCode == 200) {
        final body = response.data.toString();
        final regexp = RegExp(r'Current Version.+?>([\d.]+)<');
        final match = regexp.firstMatch(body);
        if (match != null) {
          _storeVersion = match.group(1);
        }
      }
    } catch (e) {
      debugPrint('Failed to get Play Store version: $e');
    }
  }

  Future<void> _getAppStoreVersion(String bundleId) async {
    try {
      final response = await _petraHttp.get(
        'https://itunes.apple.com/lookup?bundleId=$bundleId',
      );

      if (response.statusCode == 200) {
        final json = response.data;
        if (json['results'].isNotEmpty) {
          _storeVersion = json['results'][0]['version'];
        }
      }
    } catch (e) {
      debugPrint('Failed to get App Store version: $e');
    }
  }

  Future<void> launchStore() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final uri = Uri.parse(
        Platform.isAndroid
            ? 'market://details?id=${packageInfo.packageName}'
            : 'https://apps.apple.com/app/id${packageInfo.packageName}',
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Failed to launch store: $e');
    }
  }

  bool needsUpdate() {
    if (_packageVersion == null || _storeVersion == null) return false;

    final currentParts = _packageVersion!.split('.');
    final storeParts = _storeVersion!.split('.');

    for (var i = 0; i < currentParts.length && i < storeParts.length; i++) {
      final current = int.parse(currentParts[i]);
      final store = int.parse(storeParts[i]);
      if (store > current) return true;
      if (store < current) return false;
    }
    return false;
  }
}
