import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/models/user.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/models/user_type.dart';
import 'package:petrasoft_school_management_solutions/services/endpoint_manager/local_utils/petra_http.service.dart';
import 'package:petrasoft_school_management_solutions/services/endpoint_manager/models/endpoints.dart';

import '../models/notice.dart';

/// Result wrapper for notice data with UI-ready properties
class NoticeResult {
  final List<Notice> notices;
  final List<String> categories;
  final String? error;
  final bool isSuccess;
  final String dropdownTitle; // Title for the dropdown (e.g., "Categories", "Children", etc.)

  NoticeResult.success({
    required this.notices,
    required this.categories,
    required this.dropdownTitle,
  })  : error = null,
        isSuccess = true;

  const NoticeResult.error(this.error)
      : notices = const [],
        categories = const [],
        dropdownTitle = "",
        isSuccess = false;
}

class NoticeService {
  static final _http = PetraHttp();

  /// Get the appropriate dropdown title based on user type
  static String _getDropdownTitle(UserType userType) {
    switch (userType) {
      case UserType.ADMIN:
        return 'Categories';
      case UserType.PARENT:
        return 'Children';
      case UserType.TEACHER:
        return 'Categories';
      default:
        return 'Filter';
    }
  }

  /// Fetches notices for the current user
  /// Returns a NoticeResult that contains the appropriate data structure based on user type
  static Future<NoticeResult> fetchNotices() async {
    try {
      final user = PetraUser.instance;
      if (user.apiToken.isEmpty) {
        return NoticeResult.error('authTokenNotFound');
      }

      final response = await _http.post(
        Endpoint.userNotices.endpointURL,
        {},
        headers: {
          'authorization': 'Bearer ${user.apiToken}',
          'x-api-token': user.apiToken,
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print('Notice API Response: ${response.statusCode}');
        print('Notice API Body: ${response.data}');
      }

      final responseBody = response.data as Map<String, dynamic>;

      if (responseBody['status_code'] == 200) {
        final result = _parseNotices(responseBody, user.userType);
        return NoticeResult.success(
          notices: result.$1,
          categories: result.$2,
          dropdownTitle: _getDropdownTitle(user.userType),
        );
      } else if (responseBody['status_code'] == 401) {
        return NoticeResult.error('pleaseLoginAgain');
      } else {
        final message = responseBody['message'] ?? 'unknownError';
        return NoticeResult.error(message);
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Notice fetch error: $e');
      }

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return NoticeResult.error('connectionTimeout');
        case DioExceptionType.badResponse:
          return NoticeResult.error('serverError');
        default:
          return NoticeResult.error('networkError');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected notice fetch error: $e');
      }
      return NoticeResult.error('unknownError');
    }
  }

  /// Parses notices based on user type and returns (notices, categories)
  static (List<Notice>, List<String>) _parseNotices(
    Map<String, dynamic> responseBody,
    UserType userType,
  ) {
    final data = responseBody['message']['data'];
    final List<Notice> notices = [];
    final Set<String> categories = {};

    switch (userType) {
      case UserType.TEACHER:
        // For teachers, direct list of notices
        final List<dynamic> teacherNotices = data as List;
        notices.addAll(
          teacherNotices
              .map((json) => Notice.fromJson(json))
              .where((notice) => notice.isValid),
        );
        break;

      case UserType.PARENT:
        // For parents, notices are grouped by student
        final Map<String, dynamic> studentData = data as Map<String, dynamic>;
        for (var entry in studentData.entries) {
          final studentName = entry.value['student_name'] as String;
          categories.add(studentName);

          final List<dynamic> studentNotices = entry.value['notices'] as List;
          for (var noticeData in studentNotices) {
            final notice = Notice.fromJson(noticeData, category: studentName);
            if (notice.isValid) notices.add(notice);
          }
        }
        break;

      case UserType.ADMIN:
      default:
        // For admin, notices are grouped by category
        final Map<String, dynamic> categoryData = data as Map<String, dynamic>;
        for (var entry in categoryData.entries) {
          final recipientData = entry.value as Map<String, dynamic>;
          final String categoryName = recipientData.keys.first;
          categories.add(categoryName);

          final categoryNotices =
              recipientData[categoryName]['notices'] as List<dynamic>;
          for (var noticeData in categoryNotices) {
            final notice = Notice.fromJson(noticeData, category: categoryName);
            if (notice.isValid) notices.add(notice);
          }
        }
        break;
    }

    // Sort notices by last updated
    notices.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

    return (notices, categories.toList()..sort());
  }
}
