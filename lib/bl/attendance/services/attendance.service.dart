import 'package:flutter/foundation.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/models/petra_class.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/models/petra_student.dart';
import 'package:petrasoft_school_management_solutions/services/endpoint_manager/local_utils/petra_http.service.dart';
import 'package:petrasoft_school_management_solutions/services/endpoint_manager/models/endpoint_manager.dart';
import 'package:petrasoft_school_management_solutions/services/endpoint_manager/models/endpoints.dart';

class AttendanceService {
  static final _http = PetraHttp();

  /// Get teacher's classes for attendance marking
  static Future<Map<String, dynamic>> getTeacherClasses(String apiToken) async {
    try {
      final url = EndPointManager.getEndpoint(Endpoint.teacherAttendance);
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

  /// Mark attendance for a class
  static Future<Map<String, dynamic>> markAttendance({
    required String apiToken,
    required int classDetailId,
    required DateTime date,
    required List<PetraStudent> students,
  }) async {
    try {
      final url = EndPointManager.getEndpoint(Endpoint.teacherMarkAttendance);

      // Build students_map according to backend expectations
      // Format: "StudentName_[p/a]|remark"
      final studentsMap = <String, String>{};

      for (final student in students) {
        final studentId = student.studentDetailId.toString();
        final studentName = student.fullName;
        final attendanceStatus = student.attendanceStatus == true ? 'p' : 'a';
        final remarks = student.remarks ?? '';

        // Format: "StudentName_[p/a]|remark"
        studentsMap[studentId] = '${studentName}_$attendanceStatus|$remarks';
      }

      final requestBody = {
        'class_detail_id': classDetailId,
        'students_map': studentsMap,
        'date':
            '${date.month}/${date.day}/${date.year}', // MM/DD/YYYY format as expected by backend
      };

      final response = await _http.post(
        url,
        requestBody,
        headers: {
          'authorization': 'Bearer $apiToken',
          'x-api-token': apiToken,
          'Content-Type': 'application/json',
        },
      );

      return response.data;
    } catch (e) {
      return {'status_code': 408, 'message': 'Connection Timed Out'};
    }
  }

  /// Get today's attendance for parents
  static Future<Map<String, dynamic>> getParentTodayAttendance(
    String apiToken,
  ) async {
    try {
      final url = EndPointManager.getEndpoint(Endpoint.parentTodayAttendance);
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

  /// Get historical attendance data
  static Future<Map<String, dynamic>> getHistoricalAttendance({
    required String apiToken,
    required DateTime fromDate,
    required DateTime toDate,
    int? classDetailId,
    int? studentId,
    DateTime? selectedDate, // Add optional selected date parameter
  }) async {
    try {
      final url = EndPointManager.getEndpoint(
        Endpoint.teacherHistoricalAttendance,
      );

      final requestBody = <String, dynamic>{
        'from_date': fromDate.toIso8601String().split('T')[0],
        'to_date': toDate.toIso8601String().split('T')[0],
        if (classDetailId != null) 'class_detail_id': classDetailId,
        if (studentId != null) 'student_id': studentId,
        // Include date_selected if provided for per-date requests
        if (selectedDate != null)
          'date_selected':
              "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
      };

      final response = await _http.post(
        url,
        requestBody,
        headers: {
          'authorization': 'Bearer $apiToken',
          'x-api-token': apiToken,
          'Content-Type': 'application/json',
        },
      );

      return response.data;
    } catch (e) {
      return {'status_code': 408, 'message': 'Connection Timed Out'};
    }
  }

  /// Get attendance percentage/statistics
  static Future<Map<String, dynamic>> getAttendancePercentage({
    required String apiToken,
    required DateTime fromDate,
    required DateTime toDate,
    int? classDetailId,
    int? studentId,
  }) async {
    try {
      final url = EndPointManager.getEndpoint(
        Endpoint.teacherAttendancePercentage,
      );

      final requestBody = {
        'from_date': fromDate.toIso8601String().split('T')[0],
        'to_date': toDate.toIso8601String().split('T')[0],
        if (classDetailId != null) 'class_detail_id': classDetailId,
        if (studentId != null) 'student_id': studentId,
      };

      final response = await _http.post(
        url,
        requestBody,
        headers: {
          'authorization': 'Bearer $apiToken',
          'x-api-token': apiToken,
          'Content-Type': 'application/json',
        },
      );

      return response.data;
    } catch (e) {
      return {'status_code': 408, 'message': 'Connection Timed Out'};
    }
  }

  /// Get parent's children for attendance viewing
  static Future<Map<String, dynamic>> getParentChildren(String apiToken) async {
    try {
      // Use parent today attendance endpoint to get children list
      final url = EndPointManager.getEndpoint(Endpoint.parentTodayAttendance);
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

  /// Get attendance records for a specific class and date
  static Future<Map<String, dynamic>> getAttendanceByClassAndDate(
    String apiToken,
    int classId,
    DateTime date,
  ) async {
    try {
      // Use teacher historical attendance endpoint with class and date filter
      // The backend now returns data for the specific selected date only
      final url = EndPointManager.getEndpoint(
        Endpoint.teacherHistoricalAttendance,
      );
      final dateSelected =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final response = await _http.post(
        url,
        {
          'class_detail_id': classId,
          'date_selected': dateSelected, // Send specific date to backend
        },
        headers: {'authorization': 'Bearer $apiToken', 'x-api-token': apiToken},
      );

      return response.data;
    } catch (e) {
      return {'status_code': 408, 'message': 'Connection Timed Out'};
    }
  }

  /// Get student attendance for a specific date
  static Future<Map<String, dynamic>> getStudentAttendanceByDate(
    String apiToken,
    int studentId,
    DateTime date,
  ) async {
    try {
      // Use parent historical attendance endpoint with date filter
      final url = EndPointManager.getEndpoint(
        Endpoint.parentHistoricalAttendance,
      );
      final response = await _http.post(
        url,
        {
          'student_id': studentId,
          'date': date.toIso8601String().substring(0, 10), // YYYY-MM-DD format
        },
        headers: {'authorization': 'Bearer $apiToken', 'x-api-token': apiToken},
      );

      return response.data;
    } catch (e) {
      return {'status_code': 408, 'message': 'Connection Timed Out'};
    }
  }

  /// Get parent's historical attendance data for all children
  static Future<Map<String, dynamic>> getParentHistoricalAttendance(
    String apiToken,
  ) async {
    try {
      final url = EndPointManager.getEndpoint(
        Endpoint.parentHistoricalAttendance,
      );
      final response = await _http.post(
        url,
        {}, // No parameters needed - backend returns all children for the parent
        headers: {'authorization': 'Bearer $apiToken', 'x-api-token': apiToken},
      );

      return response.data;
    } catch (e) {
      return {'status_code': 408, 'message': 'Connection Timed Out'};
    }
  }

  /// Get attendance percentage for parents
  static Future<Map<String, dynamic>> getParentAttendancePercentage(
    String apiToken,
  ) async {
    try {
      final url = EndPointManager.getEndpoint(
        Endpoint.parentAttendancePercentage,
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

  /// Parse classes from API response
  static List<PetraClass> parseClassesFromResponse(
    Map<String, dynamic> response,
  ) {
    final classes = <PetraClass>[];

    if (kDebugMode) {
      print('Debug: parseClassesFromResponse - Starting to parse');
    }
    if (kDebugMode) {
      print('Debug: Response status_code: ${response['status_code']}');
    }

    if (response['status_code'] == 200 && response['message'] != null) {
      final classData = response['message'];
      if (kDebugMode) {
        print('Debug: Class data type: ${classData.runtimeType}');
      }

      if (classData is Map<String, dynamic> && classData['classes'] != null) {
        final classesMap = classData['classes'] as Map<String, dynamic>;
        if (kDebugMode) {
          print('Debug: Found ${classesMap.length} classes in response');
        }

        classesMap.forEach((key, value) {
          if (kDebugMode) print('Debug: Processing class with key: $key');
          try {
            final classJson = value as Map<String, dynamic>;
            if (kDebugMode) {
              print('Debug: Class JSON for key $key: $classJson');
            }

            // Ensure class_detail_id is set correctly
            // Backend provides it, but let's ensure it's the right type
            if (!classJson.containsKey('class_detail_id')) {
              classJson['class_detail_id'] = int.parse(key);
            }

            // Ensure all required fields are proper types for PetraClass.fromJson()
            // Convert string numbers to integers where needed
            if (classJson['class_teacher_id'] is String) {
              classJson['class_teacher_id'] =
                  int.tryParse(classJson['class_teacher_id'].toString()) ?? 0;
            }
            if (classJson['working_day'] is String) {
              classJson['working_day'] =
                  int.tryParse(classJson['working_day'].toString()) ?? 0;
            }
            if (classJson['attendance_taken'] is String) {
              classJson['attendance_taken'] =
                  int.tryParse(classJson['attendance_taken'].toString()) ?? 0;
            }

            // Always create petra_day object from backend data
            // The backend may or may not include petra_day, so we'll create it from the individual fields
            classJson['petra_day'] = {
              'is_working_day': (classJson['working_day'] == 1),
              'is_attendance_taken': (classJson['attendance_taken'] == 1),
              'working_hours':
                  classJson['working_hours'] ?? 'holiday', // Keep as string
              'date': DateTime.now().toIso8601String(),
            };

            if (kDebugMode) {
              print(
                'Debug: Created petra_day object: ${classJson['petra_day']}',
              );
            }

            // Check required fields
            final hrName = classJson['hr_name'];
            final division = classJson['division'];
            final classTeacherId = classJson['class_teacher_id'];

            if (kDebugMode) {
              print(
                'Debug: hr_name: $hrName, division: $division, class_teacher_id: $classTeacherId',
              );
            }

            // Ensure students list is properly formatted
            if (classJson['students'] is List) {
              final students = (classJson['students'] as List).map((
                studentData,
              ) {
                final student = studentData as Map<String, dynamic>;

                // Ensure student fields have correct data types
                if (student['user_id'] is String) {
                  student['user_id'] =
                      int.tryParse(student['user_id'].toString()) ?? 0;
                }
                if (student['class_teacher_id'] is String) {
                  student['class_teacher_id'] =
                      int.tryParse(student['class_teacher_id'].toString()) ?? 0;
                }
                if (student['class_detail_id'] is String) {
                  student['class_detail_id'] =
                      int.tryParse(student['class_detail_id'].toString()) ?? 0;
                }
                if (student['gender'] is String) {
                  student['gender'] =
                      int.tryParse(student['gender'].toString()) ?? -1;
                }

                // Ensure required string fields exist
                student['first_name'] = student['first_name'] ?? '';
                student['middle_name'] = student['middle_name'] ?? '';
                student['last_name'] = student['last_name'] ?? '';
                student['father_first_nm'] = student['father_first_nm'] ?? '';
                student['father_middle_nm'] = student['father_middle_nm'] ?? '';
                student['father_last_nm'] = student['father_last_nm'] ?? '';
                student['admission_no'] = student['admission_no'] ?? '';
                student['photo_url'] = student['photo_url'] ?? '';

                // Map class-level fields to student fields that PetraStudent.fromJson expects
                student['class_hr_name'] = classJson['hr_name'] ?? '';
                student['class_division'] = classJson['division'] ?? '';

                // Ensure class_detail_id is set for student if not present
                if (!student.containsKey('class_detail_id') ||
                    student['class_detail_id'] == null) {
                  student['class_detail_id'] = classJson['class_detail_id'];
                }

                return student;
              }).toList();
              classJson['students'] = students;
              if (kDebugMode) {
                print('Debug: Class $key has ${students.length} students');
              }
            } else {
              if (kDebugMode) {
                print(
                  'Debug: Class $key has no students or invalid student data',
                );
              }
              classJson['students'] = <Map<String, dynamic>>[];
            }

            final parsedClass = PetraClass.fromJson(classJson);
            classes.add(parsedClass);
            if (kDebugMode) {
              print(
                'Debug: Successfully parsed class: ${parsedClass.className} with ${parsedClass.students.length} students',
              );
              print(
                'Debug: Class details - ID: ${parsedClass.classDetailID}, Teacher: ${parsedClass.classTeacherID}',
              );
              print(
                'Debug: Working day: ${parsedClass.petraDay?.isWorkingDay}, Attendance taken: ${parsedClass.petraDay?.isAttendanceTaken}',
              );
              print(
                'Debug: Working hours: "${parsedClass.petraDay?.workingHours}"',
              );
            }
          } catch (e, stackTrace) {
            if (kDebugMode) {
              print('Debug: Failed to parse class with key $key: $e');
              print('Debug: Stack trace: $stackTrace');
            }
            // Skip invalid class data
            // Log error if needed but don't break the flow
          }
        });
      } else {
        if (kDebugMode) {
          print('Debug: Invalid class data structure or no classes found');
          print(
            'Debug: classData is Map: ${classData is Map<String, dynamic>}',
          );
          print(
            'Debug: classData[\'classes\'] exists: ${classData['classes'] != null}',
          );
        }
      }
    } else {
      if (kDebugMode) print('Debug: Invalid response or status code');
    }

    if (kDebugMode) {
      print('Debug: Total classes parsed: ${classes.length}');
    }
    return classes;
  }

  /// Validate API response and handle common error scenarios
  static bool isValidResponse(Map<String, dynamic> response) {
    return response['status_code'] == 200;
  }

  /// Get error message from API response
  static String getErrorMessage(Map<String, dynamic> response) {
    return response['message'] ?? 'An unknown error occurred';
  }

  /// Parse children from API response
  static List<PetraStudent> parseChildrenFromResponse(
    Map<String, dynamic> response,
  ) {
    final List<PetraStudent> children = [];

    try {
      if (response['data'] != null && response['data'] is Map) {
        final data = response['data'] as Map<String, dynamic>;

        // Handle different possible response structures
        if (data['children'] != null && data['children'] is List) {
          final childrenList = data['children'] as List;
          for (final child in childrenList) {
            if (child is Map<String, dynamic>) {
              children.add(PetraStudent.fromJson(child));
            }
          }
        } else if (data['students'] != null && data['students'] is List) {
          final studentsList = data['students'] as List;
          for (final student in studentsList) {
            if (student is Map<String, dynamic>) {
              children.add(PetraStudent.fromJson(student));
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing children from response: $e');
      }
    }

    return children;
  }

  /// Parse attendance records from API response
  static List<Map<String, dynamic>> parseAttendanceRecordsFromResponse(
    Map<String, dynamic> response,
  ) {
    final List<Map<String, dynamic>> records = [];

    try {
      // Check if response has valid status and message
      if (response['status_code'] == 200 &&
          response['message'] != null &&
          response['message'] is Map<String, dynamic>) {
        final message = response['message'] as Map<String, dynamic>;

        // Extract dates data from the message
        if (message['dates'] != null &&
            message['dates'] is Map<String, dynamic>) {
          final dates = message['dates'] as Map<String, dynamic>;

          // Process each date entry
          dates.forEach((dateStr, dateData) {
            if (dateData is Map && dateData['classes'] is Map) {
              final classes = dateData['classes'] as Map<String, dynamic>;

              // Process each class for this date
              classes.forEach((classId, classData) {
                if (classData is Map && classData['students'] is List) {
                  final students = classData['students'] as List;

                  // Add student attendance records for this class and date
                  for (final student in students) {
                    if (student is Map<String, dynamic>) {
                      // Add date and class info to each student record
                      final enrichedRecord = Map<String, dynamic>.from(student);
                      enrichedRecord['date'] = dateStr;
                      enrichedRecord['class_id'] = int.tryParse(classId) ?? 0;
                      enrichedRecord['working_day'] = classData['working_day'];
                      enrichedRecord['attendance_taken'] =
                          classData['attendance_taken'];

                      records.add(enrichedRecord);
                    }
                  }
                }
              });
            }
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing attendance records from response: $e');
        print('Error details: $e');
      }
    }

    return records;
  }

  /// Parse student attendance from API response
  static Map<String, dynamic>? parseStudentAttendanceFromResponse(
    Map<String, dynamic> response,
  ) {
    try {
      if (response['data'] != null && response['data'] is Map) {
        final data = response['data'] as Map<String, dynamic>;

        if (data['attendance'] != null && data['attendance'] is Map) {
          return data['attendance'] as Map<String, dynamic>;
        } else if (data['student'] != null && data['student'] is Map) {
          return data['student'] as Map<String, dynamic>;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing student attendance from response: $e');
      }
    }

    return null;
  }

  /// Extract attendance records for a specific date from full API response
  /// This method processes the full academic year response and extracts only
  /// the records for the requested date
  static List<Map<String, dynamic>> extractAttendanceRecordsForDate(
    Map<String, dynamic> response,
    String dateStr,
  ) {
    final List<Map<String, dynamic>> records = [];

    try {
      if (response['status_code'] == 200 &&
          response['message'] != null &&
          response['message'] is Map<String, dynamic>) {
        final message = response['message'] as Map<String, dynamic>;

        // Extract dates data from the message
        if (message['dates'] != null &&
            message['dates'] is Map<String, dynamic>) {
          final dates = message['dates'] as Map<String, dynamic>;

          // Look for the specific date in the dates map
          if (dates.containsKey(dateStr) && dates[dateStr] is Map) {
            final dateData = dates[dateStr] as Map<String, dynamic>;

            if (dateData['classes'] is Map) {
              final classes = dateData['classes'] as Map<String, dynamic>;

              // Process each class for this date
              classes.forEach((classId, classData) {
                if (classData is Map && classData['students'] is List) {
                  final students = classData['students'] as List;

                  // Add student attendance records for this class and date
                  for (final student in students) {
                    if (student is Map<String, dynamic>) {
                      // Add date and class info to each student record
                      final enrichedRecord = Map<String, dynamic>.from(student);
                      enrichedRecord['date'] = dateStr;
                      enrichedRecord['class_id'] = int.tryParse(classId) ?? 0;
                      enrichedRecord['working_day'] = classData['working_day'];
                      enrichedRecord['attendance_taken'] =
                          classData['attendance_taken'];

                      records.add(enrichedRecord);
                    }
                  }
                }
              });
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error extracting attendance records for date $dateStr: $e');
      }
    }

    return records;
  }

  /// Build a structured cache from the full API response
  /// Updated to handle single-date responses from the optimized backend
  static Map<String, List<Map<String, dynamic>>>
  buildDateBasedCacheFromResponse(Map<String, dynamic> response) {
    final Map<String, List<Map<String, dynamic>>> dateCache = {};

    try {
      if (response['status_code'] == 200 &&
          response['message'] != null &&
          response['message'] is Map<String, dynamic>) {
        final message = response['message'] as Map<String, dynamic>;

        // Extract dates data from the message
        if (message['dates'] != null &&
            message['dates'] is Map<String, dynamic>) {
          final dates = message['dates'] as Map<String, dynamic>;

          // Process each date entry (now typically just one date due to backend optimization)
          dates.forEach((dateStr, dateData) {
            if (dateData is Map && dateData['classes'] is Map) {
              final classes = dateData['classes'] as Map<String, dynamic>;
              final List<Map<String, dynamic>> dateRecords = [];

              // Process each class for this date
              classes.forEach((classId, classData) {
                if (classData is Map && classData['students'] is List) {
                  final students = classData['students'] as List;

                  // Add student attendance records for this class and date
                  for (final student in students) {
                    if (student is Map<String, dynamic>) {
                      // Add date and class info to each student record
                      final enrichedRecord = Map<String, dynamic>.from(student);
                      enrichedRecord['date'] = dateStr;
                      enrichedRecord['class_id'] = int.tryParse(classId) ?? 0;
                      enrichedRecord['working_day'] = classData['working_day'];
                      enrichedRecord['attendance_taken'] =
                          classData['attendance_taken'];

                      dateRecords.add(enrichedRecord);
                    }
                  }
                }
              });

              // Store records for this date
              dateCache[dateStr] = dateRecords;
            }
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error building date-based cache from response: $e');
      }
    }

    return dateCache;
  }
}
