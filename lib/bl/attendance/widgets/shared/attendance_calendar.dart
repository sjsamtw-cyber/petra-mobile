import 'package:flutter/material.dart';

class AttendanceCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final Set<DateTime>? highlightedDates; // Days with attendance data
  final Set<DateTime>? presentDates; // Days marked present
  final Set<DateTime>? absentDates; // Days marked absent
  final bool isDisplayOnly; // New parameter to control interactivity
  final Function(DateTime)? onDateChanged; // Callback for date selection
  final bool onlyCurrentDate; // New parameter to restrict to current date only

  const AttendanceCalendar({
    super.key,
    required this.selectedDate,
    this.highlightedDates,
    this.presentDates,
    this.absentDates,
    this.isDisplayOnly = true, // Default to display-only
    this.onDateChanged,
    this.onlyCurrentDate = false, // Default to allow all dates
  });

  @override
  State<AttendanceCalendar> createState() => _AttendanceCalendarState();
}

class _AttendanceCalendarState extends State<AttendanceCalendar> {
  late DateTime currentMonth;
  late DateTime selectedDate; // Internal state for selected date
  bool isExpanded = false; // Track if calendar is expanded to show full month

  @override
  void initState() {
    super.initState();
    selectedDate =
        widget.selectedDate; // Initialize with widget's selected date
    currentMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
    );
  }

  @override
  void didUpdateWidget(AttendanceCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update internal state if the widget's selectedDate changes
    if (oldWidget.selectedDate != widget.selectedDate) {
      selectedDate = widget.selectedDate;
      currentMonth = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
      );
    }
  }

  void _toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  void _previousMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    });
  }

  void _previousWeek() {
    setState(() {
      final currentWeekStart = _getWeekStart(selectedDate);
      final previousWeekStart = currentWeekStart.subtract(
        const Duration(days: 7),
      );
      selectedDate = previousWeekStart;
      currentMonth = DateTime(previousWeekStart.year, previousWeekStart.month);
    });
    // Notify parent of date change
    widget.onDateChanged?.call(selectedDate);
  }

  void _nextWeek() {
    setState(() {
      final currentWeekStart = _getWeekStart(selectedDate);
      final nextWeekStart = currentWeekStart.add(const Duration(days: 7));
      selectedDate = nextWeekStart;
      currentMonth = DateTime(nextWeekStart.year, nextWeekStart.month);
    });
    // Notify parent of date change
    widget.onDateChanged?.call(selectedDate);
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday == 7 ? 0 : date.weekday;
    return date.subtract(Duration(days: weekday));
  }

  void _showMonthYearSelector() {
    showDialog(
      context: context,
      builder: (context) => _MonthYearSelectorDialog(
        initialMonth: currentMonth.month,
        initialYear: currentMonth.year,
        onConfirm: (month, year) {
          setState(() {
            currentMonth = DateTime(year, month);
          });
        },
      ),
    );
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

  List<Widget> _buildCalendarDays() {
    if (isExpanded) {
      return _buildFullMonthCalendar();
    } else {
      return _buildCurrentWeekCalendar();
    }
  }

  List<Widget> _buildFullMonthCalendar() {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      0,
    );

    // Fix weekday calculation: Sunday = 0, Monday = 1, ..., Saturday = 6
    final firstWeekday = firstDayOfMonth.weekday == 7
        ? 0
        : firstDayOfMonth.weekday;

    List<Widget> days = [];

    // Add weekday headers
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    for (String weekday in weekdays) {
      days.add(_buildWeekdayHeader(weekday));
    }

    // Add previous month's trailing days
    for (int i = 0; i < firstWeekday; i++) {
      final prevMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
      final lastDayPrevMonth = DateTime(
        currentMonth.year,
        currentMonth.month,
        0,
      );
      final day = DateTime(
        prevMonth.year,
        prevMonth.month,
        lastDayPrevMonth.day - firstWeekday + i + 1,
      );
      days.add(_buildCalendarDay(day, isOtherMonth: true));
    }

    // Add current month's days
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(currentMonth.year, currentMonth.month, day);
      days.add(_buildCalendarDay(date));
    }

    // Add next month's leading days to complete the grid
    final totalCells = days.length - 7; // Subtract weekday headers
    final remainingCells = (7 - (totalCells % 7)) % 7;
    for (int day = 1; day <= remainingCells; day++) {
      final date = DateTime(currentMonth.year, currentMonth.month + 1, day);
      days.add(_buildCalendarDay(date, isOtherMonth: true));
    }

    return days;
  }

  List<Widget> _buildCurrentWeekCalendar() {
    List<Widget> days = [];

    // Add weekday headers
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    for (String weekday in weekdays) {
      days.add(_buildWeekdayHeader(weekday));
    }

    // Find the start of the week (Sunday) containing the selected date
    final weekdayOfSelected = selectedDate.weekday == 7
        ? 0
        : selectedDate.weekday;
    final startOfWeek = selectedDate.subtract(
      Duration(days: weekdayOfSelected),
    );

    // Add the 7 days of the current week
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final isOtherMonth = date.month != selectedDate.month;
      days.add(_buildCalendarDay(date, isOtherMonth: isOtherMonth));
    }

    return days;
  }

  Widget _buildWeekdayHeader(String weekday) {
    final theme = Theme.of(context);
    return Container(
      alignment: Alignment.center,
      child: Text(
        weekday,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildCalendarDay(DateTime date, {bool isOtherMonth = false}) {
    final theme = Theme.of(context);
    final today = DateTime.now();

    final isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    final isSelected =
        date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;

    // Check if date is disabled (when onlyCurrentDate is true, disable all except today)
    final isDisabled = widget.onlyCurrentDate && !isToday;

    // Check attendance status
    final isPresent =
        widget.presentDates?.any(
          (d) =>
              d.year == date.year && d.month == date.month && d.day == date.day,
        ) ??
        false;

    final isAbsent =
        widget.absentDates?.any(
          (d) =>
              d.year == date.year && d.month == date.month && d.day == date.day,
        ) ??
        false;

    final hasData =
        widget.highlightedDates?.any(
          (d) =>
              d.year == date.year && d.month == date.month && d.day == date.day,
        ) ??
        false;

    Color? backgroundColor;
    Color? borderColor;
    Color textColor = theme.colorScheme.onSurface;

    // Apply disabled styling for past dates or disabled dates
    if (isDisabled) {
      textColor = theme.colorScheme.onSurface.withValues(alpha: 0.3);
      backgroundColor = null;
    } else if (isSelected) {
      backgroundColor = theme.colorScheme.primary;
      textColor = theme.colorScheme.onPrimary;
    } else if (isPresent) {
      backgroundColor = theme.colorScheme.primary.withValues(alpha: 0.2);
      borderColor = theme.colorScheme.primary;
    } else if (isAbsent) {
      backgroundColor = theme.colorScheme.error.withValues(alpha: 0.2);
      borderColor = theme.colorScheme.error;
    } else if (isToday) {
      borderColor = theme.colorScheme.primary;
    } else if (hasData) {
      backgroundColor = theme.colorScheme.surfaceContainerHighest;
    }

    if (isOtherMonth) {
      textColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);
    }

    final dayWidget = Container(
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
    );

    // Make day tappable if not in display-only mode and not disabled
    if (!widget.isDisplayOnly && !isDisabled) {
      return GestureDetector(
        onTap: () {
          setState(() {
            selectedDate = date; // Update internal selected date
            // Update current month if the selected date is in a different month
            if (date.month != currentMonth.month ||
                date.year != currentMonth.year) {
              currentMonth = DateTime(date.year, date.month);
            }
          });

          // Call the callback if provided
          widget.onDateChanged?.call(date);
        },
        child: dayWidget,
      );
    }

    return dayWidget;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Calendar Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: isExpanded ? _previousMonth : _previousWeek,
                  icon: const Icon(Icons.chevron_left),
                  style: IconButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface,
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(32, 32),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: GestureDetector(
                          onTap: _showMonthYearSelector,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    isExpanded
                                        ? '${_getMonthName(currentMonth.month)} ${currentMonth.year}'
                                        : _getWeekDisplayText(),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.primary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: theme.colorScheme.primary,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Expand/Collapse Toggle
                      GestureDetector(
                        onTap: _toggleExpanded,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                          ),
                          child: Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: theme.colorScheme.primary,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: isExpanded ? _nextMonth : _nextWeek,
                  icon: const Icon(Icons.chevron_right),
                  style: IconButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface,
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(32, 32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Calendar Grid
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.0,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              children: _buildCalendarDays(),
            ),
          ],
        ),
      ),
    );
  }

  String _getWeekDisplayText() {
    final selectedDate = widget.selectedDate;
    final weekdayOfSelected = selectedDate.weekday == 7
        ? 0
        : selectedDate.weekday;
    final startOfWeek = selectedDate.subtract(
      Duration(days: weekdayOfSelected),
    );
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    if (startOfWeek.month == endOfWeek.month) {
      return '${_getMonthName(startOfWeek.month)} ${startOfWeek.day}-${endOfWeek.day}, ${startOfWeek.year}';
    } else {
      return '${_getMonthName(startOfWeek.month)} ${startOfWeek.day} - ${_getMonthName(endOfWeek.month)} ${endOfWeek.day}, ${startOfWeek.year}';
    }
  }
}

class _MonthYearSelectorDialog extends StatefulWidget {
  final int initialMonth;
  final int initialYear;
  final Function(int month, int year) onConfirm;

  const _MonthYearSelectorDialog({
    required this.initialMonth,
    required this.initialYear,
    required this.onConfirm,
  });

  @override
  State<_MonthYearSelectorDialog> createState() =>
      _MonthYearSelectorDialogState();
}

class _MonthYearSelectorDialogState extends State<_MonthYearSelectorDialog> {
  late int selectedMonth;
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    selectedMonth = widget.initialMonth;
    selectedYear = widget.initialYear;
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

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Select Month & Year',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: Row(
          children: [
            // Month selection
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Month',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final monthIndex = index + 1;
                        final isSelected = monthIndex == selectedMonth;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedMonth = monthIndex;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primaryContainer
                                  : theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getMonthName(monthIndex),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isSelected
                                    ? theme.colorScheme.onPrimaryContainer
                                    : theme.colorScheme.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Year selection
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Year',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 11, // 2020 to 2030
                      itemBuilder: (context, index) {
                        final year = 2020 + index;
                        final isSelected = year == selectedYear;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedYear = year;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primaryContainer
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              year.toString(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isSelected
                                    ? theme.colorScheme.onPrimaryContainer
                                    : theme.colorScheme.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Cancel',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onConfirm(selectedMonth, selectedYear);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'OK',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
