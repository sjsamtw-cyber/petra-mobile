import 'package:flutter/foundation.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/models/petra_day.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/models/petra_student.dart';

class PetraClass {
  // This is a conclusive field in determining a class with its division
  final int classDetailID;
  // Every class will have a class teacher ID.
  final int classTeacherID;
  // The human readable name of the class like 'LKG', 'IV' etc
  final String humanReadableName;
  // Class Divisions are like 'A', 'B' etc
  final String division;
  // A class should have students
  final List<PetraStudent> students;
  // Information about the current day, this is useful for purposes like marking attendance.
  final PetraDay? petraDay;

  PetraClass({
    required this.classDetailID,
    required this.classTeacherID,
    required this.humanReadableName,
    required this.division,
    required this.students,
    this.petraDay,
  });

  String get className {
    return '$humanReadableName $division';
  }

  /// Factory constructor to create PetraClass from API response
  factory PetraClass.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print('Debug: PetraClass.fromJson - Input JSON: $json');
    }

    // Handle missing or null fields with defaults
    final classDetailID = json['class_detail_id'] as int? ?? 0;
    final classTeacherID = json['class_teacher_id'] as int? ?? 0;
    final humanReadableName = json['hr_name'] as String? ?? 'Unknown Class';
    final division = json['division'] as String? ?? 'A';

    if (kDebugMode) {
      print(
        'Debug: Parsed basic fields - ID: $classDetailID, Teacher: $classTeacherID, Name: $humanReadableName, Division: $division',
      );
    }

    // Handle students list
    List<PetraStudent> students = [];
    if (json['students'] != null && json['students'] is List) {
      try {
        students = (json['students'] as List<dynamic>).map((studentJson) {
          if (kDebugMode) {
            print('Debug: Parsing student: $studentJson');
          }
          studentJson['class_detail_id'] = classDetailID;
          studentJson['class_hr_name'] = humanReadableName;
          studentJson['class_division'] = division;
          studentJson['class_teacher_id'] = classTeacherID;
          return PetraStudent.fromJson(studentJson as Map<String, dynamic>);
        }).toList();
        if (kDebugMode) {
          print('Debug: Successfully parsed ${students.length} students');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Debug: Error parsing students: $e');
        }
        students = [];
      }
    } else {
      if (kDebugMode) {
        print('Debug: No students data or invalid format');
      }
    }

    final parsedClass = PetraClass(
      classDetailID: classDetailID,
      classTeacherID: classTeacherID,
      humanReadableName: humanReadableName,
      division: division,
      students: students,
      petraDay: json['petra_day'] != null
          ? PetraDay.fromJson(json['petra_day'])
          : null,
    );

    if (kDebugMode) {
      print(
        'Debug: Created PetraClass: ${parsedClass.className} with ${parsedClass.students.length} students',
      );
    }
    return parsedClass;
  }

  /// Convert PetraClass to JSON
  Map<String, dynamic> toJson() {
    return {
      'class_detail_id': classDetailID,
      'class_teacher_id': classTeacherID,
      'hr_name': humanReadableName,
      'division': division,
      'students': students.map((student) => student.toJson()).toList(),
      'petra_day': petraDay?.toJson(),
    };
  }

  /// Validate if a map contains valid PetraClass data
  static bool isValidJson(Map<String, dynamic> json) {
    return json.containsKey('class_detail_id') &&
        json['class_detail_id'] is int &&
        json.containsKey('class_teacher_id') &&
        json['class_teacher_id'] is int &&
        json.containsKey('hr_name') &&
        json['hr_name'] is String &&
        json.containsKey('division') &&
        json['division'] is String &&
        json.containsKey('students') &&
        json['students'] is List;
  }

  /// Create a copy with updated students (useful for attendance marking)
  PetraClass copyWith({
    int? classDetailID,
    int? classTeacherID,
    String? humanReadableName,
    String? division,
    List<PetraStudent>? students,
    PetraDay? petraDay,
  }) {
    return PetraClass(
      classDetailID: classDetailID ?? this.classDetailID,
      classTeacherID: classTeacherID ?? this.classTeacherID,
      humanReadableName: humanReadableName ?? this.humanReadableName,
      division: division ?? this.division,
      students: students ?? this.students,
      petraDay: petraDay ?? this.petraDay,
    );
  }

  @override
  String toString() {
    return 'PetraClass{classDetailID: $classDetailID, className: $className, studentsCount: ${students.length}}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PetraClass && other.classDetailID == classDetailID;
  }

  @override
  int get hashCode => classDetailID.hashCode;
}
