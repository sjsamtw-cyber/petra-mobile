import 'package:flutter/material.dart';
import 'package:petrasoft_school_management_solutions/shared/utils/widgets/petra_calendar.dart';

/// Enhanced PetraCalendar with holiday highlighting support
class EnhancedPetraCalendar extends StatefulWidget {
  /// The currently selected date
  final DateTime selectedDate;

  /// Calendar selection mode
  final CalendarSelectionMode selectionMode;

  /// Callback when a date is selected (only called if selection is enabled)
  final ValueChanged<DateTime>? onDateChanged;

  /// Whether to show navigation controls (previous/next month)
  final bool showNavigation;

  /// Whether to show the selected date indicator in header
  final bool showSelectedDateIndicator;

  /// Custom header title (if null, uses month/year)
  final String? headerTitle;

  /// Custom header icon
  final IconData? headerIcon;

  /// Minimum selectable date
  final DateTime? minDate;

  /// Maximum selectable date
  final DateTime? maxDate;

  /// Set of dates that are holidays (will be highlighted in red)
  final Set<DateTime>? holidayDates;

  /// Set of dates that are working days (will be highlighted in green)
  final Set<DateTime>? workingDates;

  const EnhancedPetraCalendar({
    super.key,
    required this.selectedDate,
    this.selectionMode = CalendarSelectionMode.none,
    this.onDateChanged,
    this.showNavigation = true,
    this.showSelectedDateIndicator = false,
    this.headerTitle,
    this.headerIcon,
    this.minDate,
    this.maxDate,
    this.holidayDates,
    this.workingDates,
  });

  @override
  State<EnhancedPetraCalendar> createState() => _EnhancedPetraCalendarState();
}

class _EnhancedPetraCalendarState extends State<EnhancedPetraCalendar> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
    );
  }

  void _previousMonth() {
    if (!widget.showNavigation) return;
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    if (!widget.showNavigation) return;
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: [_buildHeader(theme), _buildCalendarGrid(theme)]),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      key: const Key('calendarHeader'),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Month and year
          Row(
            children: [
              if (widget.headerIcon != null) ...[
                Icon(
                  widget.headerIcon,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 20,
                ),
                const SizedBox(width: 8),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.headerTitle != null)
                    Text(
                      widget.headerTitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                  Text(
                    '${_getMonthName(_currentMonth.month).substring(0, 3)} ${_currentMonth.year}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Selected date indicator and navigation
          Row(
            children: [
              if (widget.showSelectedDateIndicator)
                Container(
                  key: const Key('selectedDateIndicator'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${widget.selectedDate.day}/${widget.selectedDate.month}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (widget.showNavigation) ...[
                const SizedBox(width: 8),
                IconButton(
                  key: const Key('previousMonthButton'),
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                  color: theme.colorScheme.onPrimaryContainer,
                  iconSize: 20,
                ),
                IconButton(
                  key: const Key('nextMonthButton'),
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                  color: theme.colorScheme.onPrimaryContainer,
                  iconSize: 20,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        key: const Key('calendarGrid'),
        children: [
          // Weekday headers
          Row(
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map(
                  (day) => Flexible(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: Text(
                          day,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),

          // Calendar days
          ..._buildCalendarWeeks(theme),
        ],
      ),
    );
  }

  List<Widget> _buildCalendarWeeks(ThemeData theme) {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final firstWeekday = firstDayOfMonth.weekday == 7
        ? 0
        : firstDayOfMonth.weekday;

    List<Widget> weeks = [];
    List<Widget> currentWeek = [];

    // Add previous month's trailing days
    for (int i = 0; i < firstWeekday; i++) {
      final prevMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month - 1,
        1,
      );
      final lastDayPrevMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month,
        0,
      );
      final day = DateTime(
        prevMonth.year,
        prevMonth.month,
        lastDayPrevMonth.day - firstWeekday + i + 1,
      );
      currentWeek.add(_buildCalendarDay(day, theme, isOtherMonth: true));
    }

    // Add current month's days
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      currentWeek.add(_buildCalendarDay(date, theme));

      if (currentWeek.length == 7) {
        weeks.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: currentWeek,
          ),
        );
        currentWeek = [];
      }
    }

    // Add next month's leading days to complete the last week
    if (currentWeek.isNotEmpty) {
      int day = 1;
      while (currentWeek.length < 7) {
        final date = DateTime(_currentMonth.year, _currentMonth.month + 1, day);
        currentWeek.add(_buildCalendarDay(date, theme, isOtherMonth: true));
        day++;
      }
      weeks.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: currentWeek,
        ),
      );
    }

    return weeks
        .map(
          (week) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: week,
          ),
        )
        .toList();
  }

  Widget _buildCalendarDay(
    DateTime date,
    ThemeData theme, {
    bool isOtherMonth = false,
  }) {
    final isSelected = _isSameDay(date, widget.selectedDate);
    final isToday = _isSameDay(date, DateTime.now());
    final isDisabled = _isDateDisabled(date);
    final normalizedDate = _normalizeDate(date);

    final isHoliday = widget.holidayDates?.contains(normalizedDate) ?? false;
    final isWorkingDay = widget.workingDates?.contains(normalizedDate) ?? false;

    Color? backgroundColor;
    Color? borderColor;
    Color textColor = theme.colorScheme.onSurface;

    if (isSelected) {
      backgroundColor = theme.colorScheme.primary;
      textColor = theme.colorScheme.onPrimary;
    } else if (isToday) {
      borderColor = theme.colorScheme.primary;
    }

    // Holiday highlighting (red)
    if (!isSelected && isHoliday) {
      backgroundColor = theme.colorScheme.errorContainer.withValues(alpha: 0.3);
      textColor = theme.colorScheme.onErrorContainer;
    }
    // Working day highlighting (green) - less prominent than holidays
    else if (!isSelected && !isHoliday && isWorkingDay) {
      backgroundColor = theme.colorScheme.primaryContainer.withValues(
        alpha: 0.2,
      );
      textColor = theme.colorScheme.onPrimaryContainer;
    }

    if (isDisabled) {
      textColor = theme.colorScheme.onSurface.withValues(alpha: 0.3);
      backgroundColor = null;
      borderColor = null;
    }

    if (isOtherMonth) {
      textColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);
      backgroundColor = backgroundColor?.withValues(alpha: 0.2);
    }

    final dayWidget = Flexible(
      child: Container(
        key: Key('calendarDay_${date.year}_${date.month}_${date.day}'),
        height: 40,
        width: 40,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          border: borderColor != null
              ? Border.all(color: borderColor, width: 1.5)
              : null,
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: isSelected || isToday
                  ? FontWeight.w600
                  : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );

    // Make day tappable if not disabled and selection is enabled
    if (!isDisabled && widget.selectionMode != CalendarSelectionMode.none) {
      return GestureDetector(
        onTap: () {
          if (widget.selectionMode == CalendarSelectionMode.currentDateOnly) {
            final today = DateTime.now();
            final isToday = _isSameDay(date, today);
            if (!isToday) return;
          }

          widget.onDateChanged?.call(date);
        },
        child: dayWidget,
      );
    }

    return dayWidget;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isDateDisabled(DateTime date) {
    if (widget.minDate != null && date.isBefore(widget.minDate!)) {
      return true;
    }
    if (widget.maxDate != null && date.isAfter(widget.maxDate!)) {
      return true;
    }
    return false;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
