import 'package:flutter/foundation.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/models/petra_day.dart';
import 'package:petrasoft_school_management_solutions/bl/calendar/models/school_calendar_day.dart';
import 'package:petrasoft_school_management_solutions/services/endpoint_manager/local_utils/petra_http.service.dart';
import 'package:petrasoft_school_management_solutions/services/endpoint_manager/models/endpoint_manager.dart';
import 'package:petrasoft_school_management_solutions/services/endpoint_manager/models/endpoints.dart';

class CalendarService {
  static final _http = PetraHttp();

  /// Get school calendar data
  static Future<Map<String, dynamic>> getSchoolCalendar(String apiToken) async {
    try {
      final url = EndPointManager.getEndpoint(
        Endpoint.attendanceSchoolCalendar,
      );
      final response = await _http.post(
        url,
        {},
        headers: {'authorization': 'Bearer $apiToken', 'x-api-token': apiToken},
      );

      return response.data;
    } catch (e) {
      return {'status_code': 408, 'message': 'Connection Timed Out'};
    }
  }

  /// Get last updated timestamp for calendar data
  static Future<Map<String, dynamic>> getLastUpdatedTimestamp(
    String apiToken,
  ) async {
    try {
      final url = EndPointManager.getEndpoint(
        Endpoint.attendanceUpdateTimestamp,
      );
      final response = await _http.post(
        url,
        {},
        headers: {'authorization': 'Bearer $apiToken', 'x-api-token': apiToken},
      );

      return response.data;
    } catch (e) {
      return {'status_code': 408, 'message': 'Connection Timed Out'};
    }
  }

  /// Parse last updated timestamp response
  static String? parseLastUpdatedTimestamp(Map<String, dynamic> response) {
    if (response['status_code'] == 200 && response['message'] != null) {
      final data = response['message'] as Map<String, dynamic>;
      final ts = data['calendar_last_updated_timestamp'];
      if (ts == null) return null;
      return ts.toString();
    }
    return null;
  }

  /// Parse school calendar response into map of classes and calendar data
  static (Map<String, String>, Map<DateTime, SchoolCalendarDay>)
  parseSchoolCalendarData(Map<String, dynamic> response) {
    final Map<String, String> classMap = {};
    final Map<DateTime, SchoolCalendarDay> calendarData = {};

    if (response['status_code'] == 200 &&
        response['message'] != null &&
        response['message']['calendar_data'] != null) {
      // Parse class name map
      if (response['message']['calendar_data']['class_name_id_map'] != null) {
        final classNameIdMap =
            response['message']['calendar_data']['class_name_id_map']
                as Map<String, dynamic>;
        for (final entry in classNameIdMap.entries) {
          classMap[entry.key] = entry.value.toString();
        }
      }

      // Parse calendar dates
      // Each entry in dates is a map like:
      // "2022-06-04": {
      //    "1": "N|Weekly Holiday",
      //    "2": "N|Weekly Holiday",
      //    "3": "N|Weekly Holiday",
      //    "4": "W",
      // }
      if (response['message']['calendar_data']['dates'] != null) {
        final dates =
            response['message']['calendar_data']['dates']
                as Map<String, dynamic>;
        for (final entry in dates.entries) {
          try {
            final dateStr = entry.key;
            // The value is already our class status map - no need to unwrap further
            final dayData = entry.value as Map<String, dynamic>;
            final schoolCalendarDay = SchoolCalendarDay.fromJson(
              dateStr,
              dayData,
            );
            calendarData[schoolCalendarDay.date] = schoolCalendarDay;
          } catch (e, stackTrace) {
            if (kDebugMode) {
              print('Error parsing calendar day ${entry.key}: $e\n$stackTrace');
            }
            continue;
          }
        }
      }
    }
    return (classMap, calendarData);
  }

  /// Parse calendar response into a map of DateTime to PetraDay objects
  static Map<DateTime, PetraDay> parseCalendarData(
    Map<String, dynamic> response,
  ) {
    final Map<DateTime, PetraDay> calendarData = {};

    if (response['status_code'] == 200 && response['data'] != null) {
      final data = response['data'] as Map<String, dynamic>;

      for (final entry in data.entries) {
        try {
          final date = DateTime.parse(entry.key);
          final dayData = entry.value as Map<String, dynamic>;

          calendarData[date] = PetraDay.fromJson({
            'date': entry.key,
            'is_working_day': dayData['is_working_day'] ?? false,
            'is_attendance_taken': dayData['is_attendance_taken'] ?? false,
            'working_hours': dayData['working_hours'] ?? 'holiday',
          });
        } catch (e) {
          // Skip invalid date entries
          continue;
        }
      }
    }

    return calendarData;
  }
}
