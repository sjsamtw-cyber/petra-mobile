/// School calendar day data model
class SchoolCalendarDay {
  final DateTime date;
  final Map<int, String> classData; // classId -> "W" or "N|reason"

  SchoolCalendarDay({required this.date, required this.classData});

  /// Check if this day is a working day for the given class
  bool isWorkingDayForClass(int classId) {
    final data = classData[classId];
    return data == 'W';
  }

  /// Check if this day is a non-working day for the given class
  bool isNonWorkingDayForClass(int classId) {
    final data = classData[classId];
    return data != null && data.startsWith('N|');
  }

  /// Get the holiday reason for the given class
  String? getHolidayReasonForClass(int classId) {
    final data = classData[classId];
    if (data != null && data.startsWith('N|')) {
      return data.substring(2); // Remove "N|" prefix
    }
    return null;
  }

  /// Check if this day has any non-working classes
  bool get hasAnyNonWorkingClass {
    return classData.values.any((value) => value.startsWith('N|'));
  }

  /// Check if this day has any working classes
  bool get hasAnyWorkingClass {
    return classData.values.any((value) => value == 'W');
  }

  /// Create from API response
  factory SchoolCalendarDay.fromJson(
    String dateStr,
    Map<String, dynamic> dayData,
  ) {
    final date = DateTime.parse(dateStr);
    final Map<int, String> classData = {};

    for (final entry in dayData.entries) {
      final classId = int.tryParse(entry.key);
      if (classId != null) {
        classData[classId] = entry.value as String;
      }
    }

    return SchoolCalendarDay(date: date, classData: classData);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'class_data': classData.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
    };
  }
}
