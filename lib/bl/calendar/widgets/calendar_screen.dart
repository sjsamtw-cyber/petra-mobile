import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:petrasoft_school_management_solutions/bl/auth/models/user.dart';
import 'package:petrasoft_school_management_solutions/bl/calendar/models/calendar_data.dart';
import 'package:petrasoft_school_management_solutions/bl/calendar/models/school_calendar_day.dart';
import 'package:petrasoft_school_management_solutions/bl/calendar/services/calendar_service.dart';
import 'package:petrasoft_school_management_solutions/bl/calendar/widgets/enhanced_petra_calendar.dart';
import 'package:petrasoft_school_management_solutions/l10n/app_localizations.dart';
import 'package:petrasoft_school_management_solutions/shared/utils/widgets/petra_calendar.dart';

class CalendarScreen extends StatefulWidget {
  // Add page route for navigation
  static const String page = '/calendar';
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // State for calendar data, classes, and selection
  DateTime _selectedDate = DateTime.now();
  Map<String, String> _classMap = {}; // class_id -> class_name
  String? _selectedClassId;
  Map<DateTime, SchoolCalendarDay> _calendarData = {};
  String? _lastUpdated;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCalendarData();
  }

  Future<void> _loadCalendarData() async {
    if (kDebugMode) {
      print('Debug: Starting calendar data load...');
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = PetraUser.instance;
      final apiToken = user.apiToken;

      if (kDebugMode) {
        print('Debug: API token length: ${apiToken.length}');
      }

      if (apiToken.isEmpty) {
        if (kDebugMode) {
          print('Debug: No API token available');
        }
        setState(() {
          _error = 'Authentication required';
          _loading = false;
        });
        return;
      }

      // Try to load from cache first
      SchoolCalendarData? cachedData =
          await SchoolCalendarDataManager.loadFromCache();

      if (kDebugMode) {
        print('Debug: Cached data exists: ${cachedData != null}');
        if (cachedData != null) {
          print('Debug: Cache is valid: ${cachedData.isCacheValid}');
        }
      }

      // Check if we need to refresh data
      bool needsRefresh = true;
      if (cachedData != null && cachedData.isCacheValid) {
        // Check if server has newer data
        final timestampResponse = await CalendarService.getLastUpdatedTimestamp(
          apiToken,
        );
        final serverTimestamp = CalendarService.parseLastUpdatedTimestamp(
          timestampResponse,
        );

        if (kDebugMode) {
          print('Debug: Server timestamp: $serverTimestamp');
          print('Debug: Cached timestamp: ${cachedData.lastUpdated}');
        }

        if (serverTimestamp != null &&
            serverTimestamp == cachedData.lastUpdated) {
          // Cache is up to date
          needsRefresh = false;
          _loadDataFromCache(cachedData);
        }
      }

      if (needsRefresh) {
        if (kDebugMode) {
          print('Debug: Need to refresh data from server');
        }
        await _loadDataFromServer(apiToken);
      } else {
        if (kDebugMode) {
          print('Debug: Using cached data');
        }
      }

      setState(() {
        _loading = false;
      });

      if (kDebugMode) {
        print('Debug: Calendar data load completed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Debug: Error loading calendar data: $e');
      }
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _loadDataFromCache(SchoolCalendarData cachedData) {
    if (kDebugMode) {
      print('Debug: Loading data from cache...');
    }
    _classMap = cachedData.classMap;
    _selectedClassId = _classMap.isNotEmpty ? _classMap.keys.first : null;
    _calendarData = cachedData.calendarDays;
    _lastUpdated = cachedData.lastUpdated;

    if (kDebugMode) {
      print('Debug: Cache - calendar data count: ${_calendarData.length}');
      print('Debug: Cache - class map count: ${_classMap.length}');
      print('Debug: Cache - last updated: $_lastUpdated');
    }
  }

  Future<void> _loadDataFromServer(String apiToken) async {
    if (kDebugMode) {
      print('Debug: Loading data from server...');
    }

    // Load calendar data and timestamp
    final futures = await Future.wait([
      CalendarService.getSchoolCalendar(apiToken),
      CalendarService.getLastUpdatedTimestamp(apiToken),
    ]);

    final calendarResponse = futures[0];
    final timestampResponse = futures[1];

    if (kDebugMode) {
      print('Debug: Calendar response: $calendarResponse');
      print('Debug: Timestamp response: $timestampResponse');
    }

    // Parse responses
    final (newClassMap, newCalendarData) =
        CalendarService.parseSchoolCalendarData(calendarResponse);
    _classMap = newClassMap;
    _calendarData = newCalendarData;
    _selectedClassId = _classMap.isNotEmpty ? _classMap.keys.first : null;
    _lastUpdated = CalendarService.parseLastUpdatedTimestamp(timestampResponse);

    if (kDebugMode) {
      print('Debug: Parsed calendar data count: ${_calendarData.length}');
      print('Debug: Parsed class map count: ${_classMap.length}');
      print('Debug: Last updated: $_lastUpdated');
    }

    // Save to cache
    final newCacheData = SchoolCalendarData(
      calendarDays: _calendarData,
      classMap: _classMap,
      lastUpdated: _lastUpdated,
      cacheTimestamp: DateTime.now(),
    );

    await SchoolCalendarDataManager.saveToCache(newCacheData);
    if (_lastUpdated != null) {
      await SchoolCalendarDataManager.saveLastUpdatedTimestamp(_lastUpdated!);
    }
  }

  Future<void> _refreshCalendarData() async {
    // Clear cache and force reload from server
    await SchoolCalendarDataManager.clearCache();
    await _loadCalendarData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(key: Key('calendarLoadingIndicator')),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
              key: const Key('calendarErrorIcon'),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.calendarLoadError,
              key: const Key('calendarErrorText'),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('calendarRetryButton'),
              onPressed: _refreshCalendarData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      key: const Key('calendarScreenScroll'),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar Section
            _buildCalendarSection(theme, l10n),

            const SizedBox(height: 24),

            // Class Selector Section
            _buildClassSelectorSection(theme, l10n),

            const SizedBox(height: 24),

            // Day details section
            _buildDayDetailsSection(theme, l10n),

            // Last updated section
            if (_lastUpdated != null) ...[
              const SizedBox(height: 16),
              _buildLastUpdatedSection(theme, l10n),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClassSelectorSection(ThemeData theme, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.selectClass,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  key: const Key('refreshButton'),
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshCalendarData,
                  tooltip: l10n.refreshCalendarTooltip,
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_classMap.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    l10n.noClassesAvailable,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              DropdownButton<String>(
                key: const Key('classSelectorDropdown'),
                value: _selectedClassId,
                isExpanded: true,
                onChanged: (value) {
                  setState(() {
                    _selectedClassId = value;
                  });
                },
                items: _classMap.entries
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection(ThemeData theme, AppLocalizations l10n) {
    if (kDebugMode) {
      print('Debug: Building calendar section...');
      print('Debug: Calendar data entries: ${_calendarData.length}');
      print(
        'Debug: Selected class: ${_selectedClassId != null ? _classMap[_selectedClassId] : "none"}',
      );
    }

    // Convert SchoolCalendarDay data to sets for EnhancedPetraCalendar highlighting
    final Set<DateTime> holidayDates = {};
    final Set<DateTime> workingDates = {};

    if (_selectedClassId != null) {
      final classId = int.tryParse(_selectedClassId!) ?? 0;
      if (kDebugMode) {
        print('Debug: Processing calendar data for class ID: $classId');
      }

      for (final entry in _calendarData.entries) {
        final date = entry.key;
        final dayData = entry.value;

        if (dayData.isWorkingDayForClass(classId)) {
          workingDates.add(date);
        } else if (dayData.isNonWorkingDayForClass(classId)) {
          holidayDates.add(date);
        }
      }
    } else {
      if (kDebugMode) {
        print('Debug: No class selected, showing general patterns');
      }
      // If no class selected, show general holiday/working day patterns
      for (final entry in _calendarData.entries) {
        final date = entry.key;
        final dayData = entry.value;

        if (dayData.hasAnyWorkingClass) {
          workingDates.add(date);
        }
        if (dayData.hasAnyNonWorkingClass) {
          holidayDates.add(date);
        }
      }
    }

    if (kDebugMode) {
      print('Debug: Holiday dates count: ${holidayDates.length}');
      print('Debug: Working dates count: ${workingDates.length}');
    }

    try {
      return EnhancedPetraCalendar(
        key: const Key('calendarWidget'),
        selectedDate: _selectedDate,
        selectionMode: CalendarSelectionMode.single,
        onDateChanged: (date) {
          setState(() {
            _selectedDate = date;
          });
        },
        showNavigation: true,
        showSelectedDateIndicator: true,
        headerTitle: l10n.calendarTitle,
        headerIcon: Icons.calendar_today,
        holidayDates: holidayDates,
        workingDates: workingDates,
      );
    } catch (e) {
      if (kDebugMode) {
        print(
          'Debug: Error with EnhancedPetraCalendar, falling back to PetraCalendar: $e',
        );
      }
      // Fallback to regular PetraCalendar if EnhancedPetraCalendar has issues
      return PetraCalendar(
        selectedDate: _selectedDate,
        selectionMode: CalendarSelectionMode.single,
        onDateChanged: (date) {
          setState(() {
            _selectedDate = date;
          });
        },
        showNavigation: true,
        showSelectedDateIndicator: true,
        headerTitle: l10n.calendarTitle,
        headerIcon: Icons.calendar_today,
      );
    }
  }

  Widget _buildDayDetailsSection(ThemeData theme, AppLocalizations l10n) {
    final dayData = _calendarData[_normalizeDate(_selectedDate)];

    return Container(
      key: const Key('dayDetailsSection'),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.dayDetailsTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDayDetails(dayData, theme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdatedSection(ThemeData theme, AppLocalizations l10n) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        _formatLastUpdated(_lastUpdated!),
        key: const Key('lastUpdatedText'),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildDayDetails(
    SchoolCalendarDay? dayData,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    if (dayData == null) {
      return Center(
        child: Text(
          l10n.calendarDayDetailsPlaceholder,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final classId = _selectedClassId != null
        ? int.tryParse(_selectedClassId!)
        : null;
    final isWorkingDay = classId != null
        ? dayData.isWorkingDayForClass(classId)
        : dayData.hasAnyWorkingClass;
    final holidayReason = classId != null
        ? dayData.getHolidayReasonForClass(classId)
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWorkingDay
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWorkingDay
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : theme.colorScheme.error.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isWorkingDay ? Icons.work : Icons.event_busy,
                color: isWorkingDay
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isWorkingDay
                    ? l10n.calendarWorkingDayLabel
                    : l10n.calendarHolidayLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isWorkingDay
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isWorkingDay) ...[
            Text(
              l10n.regularWorkingDay,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (_selectedClassId != null) ...[
              const SizedBox(height: 8),
              Text(
                '${l10n.classLabel}: ${_classMap[_selectedClassId!]}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ] else ...[
            if (holidayReason != null) ...[
              Text(
                '${l10n.reasonLabel}$holidayReason',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ] else ...[
              Text(
                'Holiday',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            if (_selectedClassId != null) ...[
              const SizedBox(height: 8),
              Text(
                '${l10n.classLabel}: ${_classMap[_selectedClassId!]}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _formatLastUpdated(String timestamp) {
    try {
      if (kDebugMode) {
        print('Debug: Raw timestamp from server: $timestamp');
      }

      // Parse as Unix timestamp (seconds)
      final seconds = int.parse(timestamp);
      final date = DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000,
      ); // Convert seconds to milliseconds

      if (kDebugMode) {
        print('Debug: Parsed date: $date');
      }

      return 'Last updated on: ${date.day} ${_getMonthName(date.month)} ${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      if (kDebugMode) {
        print('Debug: Error formatting timestamp: $e');
        print('Debug: Failed to parse timestamp: $timestamp');
      }
      return 'Last updated: (invalid date)';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
