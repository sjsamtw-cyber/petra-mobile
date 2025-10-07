# Calendar Module

## Overview

The Calendar module provides a comprehensive school calendar interface for the Petra mobile app. It displays working days, holidays, and class-specific information with offline caching support.

## Features

- **School Calendar Display**: Shows working days and holidays based on school calendar data
- **Class Filtering**: Dropdown selector to filter calendar view by class
- **Academic Year Support**: Automatically sets date range from June to March
- **Day Details**: Displays working hours, class information, and attendance status
- **Offline Caching**: Caches calendar data locally for offline access
- **Real-time Sync**: Checks for server updates using last-updated timestamps
- **Localization**: Supports multiple languages (English and Hindi)
- **Refresh Capability**: Manual refresh option to force data update

## Files Structure

```
lib/bl/calendar/
├── calendar_screen.dart          # Main calendar screen widget
├── models/
│   └── calendar_data.dart        # Data models and caching logic
└── services/
    └── calendar_service.dart     # API service for calendar data
```

## API Integration

The module integrates with the following backend endpoints:

- `attendanceSchoolCalendar` - Retrieves school calendar data
- `attendanceUpdateTimestamp` - Gets last updated timestamp
- `teacherAllClasses` - Fetches available classes

## Data Flow

1. **Load**: Check cache validity and compare with server timestamp
2. **Fetch**: If needed, fetch fresh data from backend APIs
3. **Cache**: Store data locally for offline access
4. **Display**: Present calendar with interactive date selection
5. **Details**: Show day-specific information when date is selected

## Usage

```dart
// Navigate to calendar screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const CalendarScreen()),
);
```

## Dependencies

- `petra_calendar.dart` - Reusable calendar widget
- `petra_day.dart` - Day data model from attendance module
- `petra_class.dart` - Class data model from attendance module
- Authentication service for API tokens
- App preferences for local caching

## Localization Keys

- `calendarTitle` - Screen title
- `calendarDayDetailsPlaceholder` - No date selected message
- `calendarHolidayLabel` - Holiday indicator
- `calendarWorkingDayLabel` - Working day indicator
- `calendarLastUpdated` - Last updated timestamp
- `calendarLoadError` - Error message for failed data load
