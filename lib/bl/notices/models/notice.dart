import 'package:flutter/foundation.dart';

/// Notice model that replicates the petra_mobile notice functionality
class Notice {
  final int noticeId;
  final String noticeName;
  final String noticeDescription;
  final int acadYearId;
  final String startDate;
  final String endDate;
  final int recipientTypeId;
  final int updatedBy;
  final int createdBy;
  final String createdAt;
  final String updatedAt;
  final List<String> categories; // List of categories this notice belongs to

  Notice({
    required this.noticeId,
    required this.noticeName,
    required this.noticeDescription,
    required this.acadYearId,
    required this.startDate,
    required this.endDate,
    required this.recipientTypeId,
    required this.updatedBy,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.categories = const [], // Initialize with empty list
  });

  /// DateTime getter for the last update time
  DateTime get lastUpdated => DateTime.parse(updatedAt);

  /// Formatted timestamp for display
  String get formattedTimestamp {
    final date = DateTime.parse(updatedAt);
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  /// Validation check
  bool get isValid => noticeId > 0 && noticeName.isNotEmpty;

  /// Factory constructor for parsing notice from JSON
  /// Handles both direct notice object and nested notice object (for parents)
  factory Notice.fromJson(Map<String, dynamic> json, {String? category}) {
    // Handle parent response where notice is nested under 'notice' key
    final noticeData = json.containsKey('notice') ? json['notice'] : json;

    return Notice(
      noticeId: noticeData['notice_id'] as int,
      noticeName: noticeData['notice_nm'] as String,
      noticeDescription: noticeData['notice_desc'] as String,
      acadYearId: noticeData['acad_year_id'] as int,
      startDate: noticeData['start_dt'] as String,
      endDate: noticeData['end_dt'] as String,
      recipientTypeId: noticeData['recipient_type_id'] as int,
      updatedBy: noticeData['updated_by'] as int,
      createdBy: noticeData['created_by'] as int,
      createdAt: noticeData['created_at'] as String,
      updatedAt: noticeData['updated_at'] as String,
      categories: category != null ? [category] : const [], // Initialize with category if provided
    );
  }

  /// Convert notice to JSON
  Map<String, dynamic> toJson() {
    return {
      'notice_id': noticeId,
      'notice_nm': noticeName,
      'notice_desc': noticeDescription,
      'acad_year_id': acadYearId,
      'start_dt': startDate,
      'end_dt': endDate,
      'recipient_type_id': recipientTypeId,
      'updated_by': updatedBy,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'categories': categories,
    };
  }

  /// Method to create a copy of the notice with optional new values
  Notice copyWith({
    int? noticeId,
    String? noticeName,
    String? noticeDescription,
    int? acadYearId,
    String? startDate,
    String? endDate,
    int? recipientTypeId,
    int? updatedBy,
    int? createdBy,
    String? createdAt,
    String? updatedAt,
    List<String>? categories,
  }) {
    return Notice(
      noticeId: noticeId ?? this.noticeId,
      noticeName: noticeName ?? this.noticeName,
      noticeDescription: noticeDescription ?? this.noticeDescription,
      acadYearId: acadYearId ?? this.acadYearId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      recipientTypeId: recipientTypeId ?? this.recipientTypeId,
      updatedBy: updatedBy ?? this.updatedBy,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categories: categories ?? this.categories,
    );
  }

  /// Add a category to this notice
  Notice addCategory(String category) {
    if (!categories.contains(category)) {
      return copyWith(categories: [...categories, category]);
    }
    return this;
  }
}

/// Container class for parent notices with student information
@immutable
class ParentNoticeCategory {
  final String studentName;
  final List<Notice> notices;

  const ParentNoticeCategory({
    required this.studentName,
    required this.notices,
  });

  factory ParentNoticeCategory.fromJson(Map<String, dynamic> json) {
    final List<dynamic> noticesList = json['notices'] as List<dynamic>;

    return ParentNoticeCategory(
      studentName: json['student_name'] as String,
      notices: noticesList.map((item) => Notice.fromJson(item)).toList(),
    );
  }
}

/// Container class for admin notices with category information
@immutable
class AdminNoticeCategory {
  final String categoryName;
  final List<Notice> notices;

  const AdminNoticeCategory({
    required this.categoryName,
    required this.notices,
  });

  factory AdminNoticeCategory.fromJson(
    String categoryName,
    Map<String, dynamic> json,
  ) {
    final List<dynamic> noticesList = json['notices'] as List<dynamic>;

    return AdminNoticeCategory(
      categoryName: categoryName,
      notices: noticesList.map((item) => Notice.fromJson(item)).toList(),
    );
  }
}

/// Main container for all notice data regardless of user type
@immutable
class NoticeResponse {
  final List<Notice>? allNotices;
  final List<String>? allCategories;
  final Map<int, List<String>>?
  noticeCategories; // Added to track multiple categories per notice
  final Map<int, ParentNoticeCategory>? parentCategories;
  final Map<int, AdminNoticeCategory>? adminCategories;
  final List<Notice>? teacherNotices;

  const NoticeResponse({
    this.allNotices,
    this.allCategories,
    this.noticeCategories,
    this.parentCategories,
    this.adminCategories,
    this.teacherNotices,
  });

  bool get isEmpty {
    return (parentCategories?.isEmpty ?? true) &&
        (adminCategories?.isEmpty ?? true) &&
        (teacherNotices?.isEmpty ?? true);
  }

  /// Get a flattened list of all notices
  List<Notice> get notices {
    if (teacherNotices != null) return teacherNotices!;

    if (parentCategories != null) {
      return parentCategories!.values
          .expand((category) => category.notices)
          .toList();
    }

    if (adminCategories != null) {
      return adminCategories!.values
          .expand((category) => category.notices)
          .toList();
    }

    return const [];
  }

  /// Get a list of category names if applicable
  List<String>? get categories {
    if (parentCategories != null) {
      return parentCategories!.values
          .map((category) => category.studentName)
          .toList();
    }

    if (adminCategories != null) {
      return adminCategories!.values
          .map((category) => category.categoryName)
          .toList();
    }

    return null;
  }
}
