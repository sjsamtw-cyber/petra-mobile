import 'package:petrasoft_school_management_solutions/bl/auth/models/petra_student.dart';

class AttendanceStats {
  final String acadYear;
  final int totalWorkingDays;
  final int totalPresentDays;
  final int totalAbsentDays;
  final double attendancePercentage;
  final Map<String, bool> dailyAttendance; // Date string -> present/absent

  AttendanceStats({
    required this.acadYear,
    required this.totalWorkingDays,
    required this.totalPresentDays,
    required this.totalAbsentDays,
    required this.attendancePercentage,
    required this.dailyAttendance,
  });

  /// Factory constructor for creating AttendanceStats from API response
  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    final dailyAttendanceMap = <String, bool>{};
    if (json['daily_attendance'] != null) {
      final dailyData = json['daily_attendance'] as Map<String, dynamic>;
      dailyData.forEach((key, value) {
        dailyAttendanceMap[key] = value as bool;
      });
    }

    return AttendanceStats(
      acadYear: json['acad_year'] as String? ?? '',
      totalWorkingDays: json['total_working_days'] as int? ?? 0,
      totalPresentDays: json['total_present_days'] as int? ?? 0,
      totalAbsentDays: json['total_absent_days'] as int? ?? 0,
      attendancePercentage:
          (json['attendance_percentage'] as num?)?.toDouble() ?? 0.0,
      dailyAttendance: dailyAttendanceMap,
    );
  }

  /// Convert AttendanceStats to JSON
  Map<String, dynamic> toJson() {
    return {
      'acad_year': acadYear,
      'total_working_days': totalWorkingDays,
      'total_present_days': totalPresentDays,
      'total_absent_days': totalAbsentDays,
      'attendance_percentage': attendancePercentage,
      'daily_attendance': dailyAttendance,
    };
  }

  /// Get attendance status for a specific date
  bool? getAttendanceForDate(DateTime date) {
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return dailyAttendance[dateString];
  }

  /// Check if attendance is marked for a specific date
  bool isAttendanceMarkedForDate(DateTime date) {
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return dailyAttendance.containsKey(dateString);
  }

  @override
  String toString() {
    return 'AttendanceStats{acadYear: $acadYear, percentage: $attendancePercentage%, present: $totalPresentDays/$totalWorkingDays}';
  }
}

/// Class to hold attendance data for a specific student
class StudentAttendanceData {
  final PetraStudent student;
  final AttendanceStats stats;

  StudentAttendanceData({required this.student, required this.stats});

  factory StudentAttendanceData.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceData(
      student: PetraStudent.fromJson(json['student']),
      stats: AttendanceStats.fromJson(json['stats']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'student': student.toJson(), 'stats': stats.toJson()};
  }
}

/// Class to hold class-wise attendance summary
class ClassAttendanceSummary {
  final int classDetailId;
  final String className;
  final DateTime date;
  final int totalStudents;
  final int presentStudents;
  final int absentStudents;
  final bool isAttendanceTaken;

  ClassAttendanceSummary({
    required this.classDetailId,
    required this.className,
    required this.date,
    required this.totalStudents,
    required this.presentStudents,
    required this.absentStudents,
    required this.isAttendanceTaken,
  });

  double get attendancePercentage {
    if (totalStudents == 0) return 0.0;
    return (presentStudents / totalStudents) * 100;
  }

  factory ClassAttendanceSummary.fromJson(Map<String, dynamic> json) {
    return ClassAttendanceSummary(
      classDetailId: json['class_detail_id'] as int,
      className: json['class_name'] as String,
      date: DateTime.parse(json['date'] as String),
      totalStudents: json['total_students'] as int,
      presentStudents: json['present_students'] as int,
      absentStudents: json['absent_students'] as int,
      isAttendanceTaken: json['is_attendance_taken'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_detail_id': classDetailId,
      'class_name': className,
      'date': date.toIso8601String(),
      'total_students': totalStudents,
      'present_students': presentStudents,
      'absent_students': absentStudents,
      'is_attendance_taken': isAttendanceTaken,
    };
  }
}
