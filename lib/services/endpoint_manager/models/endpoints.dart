import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preference_keys.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preferences.dart';

enum Endpoint {
  login,
  logout,
  // Below endpoints are for teachers
  teacherAttendance,
  teacherMarkAttendance, // On saving attendance.
  teacherAllClasses, // For getting classes
  teacherHistoricalAttendance, // On saving attendance.
  teacherAttendancePercentage, // On saving attendance.
  // Below endpoints are for parents
  parentTodayAttendance,
  parentHistoricalAttendance,
  parentAttendancePercentage,
  // Attendance Module Common functionality
  attendanceSchoolCalendar,
  attendanceUpdateTimestamp,
  // User functionality
  userTypes,
  userRoles,
  userNotices,
}

/*
  Route::post('/user/teacher/get_teacher_classes', 'ApiController@getTeacherClasses');
  Route::post('/user/teacher/mark_attendance', 'ApiController@markAttendance');
  Route::post('/user/get_current_user_type', 'ApiController@get_cur_user_type');
  Route::post('/user/get_current_user_role', 'ApiController@getuserroles');
*/

extension EndpointDetails on Endpoint {
  String get endpointURL {
    String? url = AppPreferences().fetchStringSharedPref(
      AppPreferenceKeys.apiURL,
    );
    switch (this) {
      case Endpoint.login:
        return '$url/api/user/login';
      case Endpoint.logout:
        return '$url/api/user/logout';
      case Endpoint.teacherAttendance:
        return '$url/api/user/teacher/get_teacher_classes';
      case Endpoint.teacherMarkAttendance:
        return '$url/api/user/teacher/mark_attendance';
      case Endpoint.teacherAllClasses:
        return '$url/api/user/teacher/get_class_list';
      case Endpoint.teacherHistoricalAttendance:
        return '$url/api/user/teacher/attendance/stats/historical';
      case Endpoint.teacherAttendancePercentage:
        return '$url/api/user/teacher/attendance/stats/percentage';
      case Endpoint.parentTodayAttendance:
        return '$url/api/user/parent/attendance/stats/today';
      case Endpoint.parentHistoricalAttendance:
        return '$url/api/user/parent/attendance/stats/historical';
      case Endpoint.parentAttendancePercentage:
        return '$url/api/user/parent/attendance/stats/percentage';
      case Endpoint.attendanceSchoolCalendar:
        return '$url/api/attendance/school-calendar';
      case Endpoint.attendanceUpdateTimestamp:
        return '$url/api/attendance/school-calendar/get-last-updated-timestamp';
      case Endpoint.userTypes:
        return '$url/api/user/get_current_user_type';
      case Endpoint.userRoles:
        return '$url/api/user/get_current_user_roles';
      case Endpoint.userNotices:
        return '$url/api/user/notices';
      // ignore: unreachable_switch_default
      default:
        assert(false, "Endpoint not found");
        // We will never reach here
        return "/api/non_existent";
    }
  }
}
