import 'dart:convert';

import 'package:petrasoft_school_management_solutions/bl/attendance/models/petra_class.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/models/petra_day.dart';
import 'package:petrasoft_school_management_solutions/bl/calendar/models/school_calendar_day.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preferences.dart';

class SchoolCalendarData {
  final Map<DateTime, SchoolCalendarDay> calendarDays;
  final Map<String, String> classMap;  // class_id -> class_name
  final String? lastUpdated;
  final DateTime? cacheTimestamp;

  SchoolCalendarData({
    required this.calendarDays,
    required this.classMap,
    this.lastUpdated,
    this.cacheTimestamp,
  });

  /// Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'calendar_days': calendarDays.map(
        (key, value) => MapEntry(key.toIso8601String(), value.toJson()),
      ),
      'class_map': classMap,
      'last_updated': lastUpdated,
      'cache_timestamp': cacheTimestamp?.toIso8601String(),
    };
  }

  /// Create from JSON (for loading from cache)
  factory SchoolCalendarData.fromJson(Map<String, dynamic> json) {
    final Map<DateTime, SchoolCalendarDay> calendarDays = {};
    final calendarDaysJson =
        json['calendar_days'] as Map<String, dynamic>? ?? {};

    for (final entry in calendarDaysJson.entries) {
      try {
        final date = DateTime.parse(entry.key);
        final dayData = entry.value as Map<String, dynamic>;
        calendarDays[date] = SchoolCalendarDay.fromJson(
          entry.key,
          dayData['class_data'] as Map<String, dynamic>,
        );
      } catch (e) {
        // Skip invalid entries
        continue;
      }
    }

    final Map<String, String> classMap = {};
    final classMapJson = json['class_map'] as Map<String, dynamic>? ?? {};
    for (final entry in classMapJson.entries) {
      classMap[entry.key] = entry.value.toString();
    }

    return SchoolCalendarData(
      calendarDays: calendarDays,
      classMap: classMap,
      lastUpdated: json['last_updated'] as String?,
      cacheTimestamp: json['cache_timestamp'] != null
          ? DateTime.parse(json['cache_timestamp'] as String)
          : null,
    );
  }

  /// Check if cache is valid (less than 1 hour old)
  bool get isCacheValid {
    if (cacheTimestamp == null) return false;
    final now = DateTime.now();
    final difference = now.difference(cacheTimestamp!);
    return difference.inHours < 1;
  }

  /// Create a copy with updated data
  SchoolCalendarData copyWith({
    Map<DateTime, SchoolCalendarDay>? calendarDays,
    Map<String, String>? classMap,
    String? lastUpdated,
    DateTime? cacheTimestamp,
  }) {
    return SchoolCalendarData(
      calendarDays: calendarDays ?? this.calendarDays,
      classMap: classMap ?? this.classMap,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      cacheTimestamp: cacheTimestamp ?? this.cacheTimestamp,
    );
  }
}

class CalendarData {
  final Map<DateTime, PetraDay> calendarDays;
  final List<PetraClass> classes;
  final String? lastUpdated;
  final DateTime? cacheTimestamp;

  CalendarData({
    required this.calendarDays,
    required this.classes,
    this.lastUpdated,
    this.cacheTimestamp,
  });

  /// Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'calendar_days': calendarDays.map(
        (key, value) => MapEntry(key.toIso8601String(), value.toJson()),
      ),
      'classes': classes.map((c) => c.toJson()).toList(),
      'last_updated': lastUpdated,
      'cache_timestamp': cacheTimestamp?.toIso8601String(),
    };
  }

  /// Create from JSON (for loading from cache)
  factory CalendarData.fromJson(Map<String, dynamic> json) {
    final Map<DateTime, PetraDay> calendarDays = {};
    final calendarDaysJson =
        json['calendar_days'] as Map<String, dynamic>? ?? {};

    for (final entry in calendarDaysJson.entries) {
      try {
        final date = DateTime.parse(entry.key);
        final dayData = entry.value as Map<String, dynamic>;
        calendarDays[date] = PetraDay.fromJson(dayData);
      } catch (e) {
        // Skip invalid entries
        continue;
      }
    }

    final List<PetraClass> classes = [];
    final classesJson = json['classes'] as List<dynamic>? ?? [];

    for (final classData in classesJson) {
      try {
        classes.add(PetraClass.fromJson(classData as Map<String, dynamic>));
      } catch (e) {
        // Skip invalid entries
        continue;
      }
    }

    return CalendarData(
      calendarDays: calendarDays,
      classes: classes,
      lastUpdated: json['last_updated'] as String?,
      cacheTimestamp: json['cache_timestamp'] != null
          ? DateTime.parse(json['cache_timestamp'] as String)
          : null,
    );
  }

  /// Check if cache is valid (less than 1 hour old)
  bool get isCacheValid {
    if (cacheTimestamp == null) return false;
    final now = DateTime.now();
    final difference = now.difference(cacheTimestamp!);
    return difference.inHours < 1;
  }

  /// Create a copy with updated data
  CalendarData copyWith({
    Map<DateTime, PetraDay>? calendarDays,
    List<PetraClass>? classes,
    String? lastUpdated,
    DateTime? cacheTimestamp,
  }) {
    return CalendarData(
      calendarDays: calendarDays ?? this.calendarDays,
      classes: classes ?? this.classes,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      cacheTimestamp: cacheTimestamp ?? this.cacheTimestamp,
    );
  }
}

class SchoolCalendarDataManager {
  static const String _cacheKey = 'school_calendar_data_cache';
  static const String _lastUpdatedKey = 'school_calendar_last_updated_cache';

  /// Save school calendar data to cache
  static Future<void> saveToCache(SchoolCalendarData data) async {
    final prefs = AppPreferences();
    final jsonString = jsonEncode(data.toJson());
    await prefs.changeStringSharedPref(_cacheKey, jsonString);
  }

  /// Load school calendar data from cache
  static Future<SchoolCalendarData?> loadFromCache() async {
    try {
      final prefs = AppPreferences();
      final jsonString = prefs.fetchStringSharedPref(_cacheKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return SchoolCalendarData.fromJson(json);
      }
    } catch (e) {
      // Cache is corrupted, ignore
    }
    return null;
  }

  /// Clear school calendar cache
  static Future<void> clearCache() async {
    final prefs = AppPreferences();
    await prefs.changeStringSharedPref(_cacheKey, '');
    await prefs.changeStringSharedPref(_lastUpdatedKey, '');
  }

  /// Save last updated timestamp separately for quick comparison
  static Future<void> saveLastUpdatedTimestamp(String timestamp) async {
    final prefs = AppPreferences();
    await prefs.changeStringSharedPref(_lastUpdatedKey, timestamp);
  }

  /// Get cached last updated timestamp
  static String? getCachedLastUpdatedTimestamp() {
    final prefs = AppPreferences();
    return prefs.fetchStringSharedPref(_lastUpdatedKey);
  }
}

class CalendarDataManager {
  static const String _cacheKey = 'calendar_data_cache';
  static const String _lastUpdatedKey = 'calendar_last_updated_cache';

  /// Save calendar data to cache
  static Future<void> saveToCache(CalendarData data) async {
    final prefs = AppPreferences();
    final jsonString = jsonEncode(data.toJson());
    await prefs.changeStringSharedPref(_cacheKey, jsonString);
  }

  /// Load calendar data from cache
  static Future<CalendarData?> loadFromCache() async {
    try {
      final prefs = AppPreferences();
      final jsonString = prefs.fetchStringSharedPref(_cacheKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return CalendarData.fromJson(json);
      }
    } catch (e) {
      // Cache is corrupted, ignore
    }
    return null;
  }

  /// Clear calendar cache
  static Future<void> clearCache() async {
    final prefs = AppPreferences();
    await prefs.changeStringSharedPref(_cacheKey, '');
    await prefs.changeStringSharedPref(_lastUpdatedKey, '');
  }

  /// Save last updated timestamp separately for quick comparison
  static Future<void> saveLastUpdatedTimestamp(String timestamp) async {
    final prefs = AppPreferences();
    await prefs.changeStringSharedPref(_lastUpdatedKey, timestamp);
  }

  /// Get cached last updated timestamp
  static String? getCachedLastUpdatedTimestamp() {
    final prefs = AppPreferences();
    return prefs.fetchStringSharedPref(_lastUpdatedKey);
  }
}
