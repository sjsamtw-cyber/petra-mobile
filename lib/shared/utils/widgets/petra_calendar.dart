import 'package:flutter/material.dart';

/// Calendar selection mode
enum CalendarSelectionMode {
  /// No date selection allowed (display-only)
  none,

  /// Single date selection allowed
  single,

  /// Only current date can be selected
  currentDateOnly,
}

/// A reusable calendar widget for the Petra app
class PetraCalendar extends StatefulWidget {
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

  const PetraCalendar({
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
  });

  @override
  State<PetraCalendar> createState() => _PetraCalendarState();
}

class _PetraCalendarState extends State<PetraCalendar> {
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

  bool _isDateSelectable(DateTime date) {
    if (widget.minDate != null && date.isBefore(widget.minDate!)) return false;
    if (widget.maxDate != null && date.isAfter(widget.maxDate!)) return false;
    switch (widget.selectionMode) {
      case CalendarSelectionMode.none:
        return false;
      case CalendarSelectionMode.single:
        return true;
      case CalendarSelectionMode.currentDateOnly:
        final today = DateTime.now();
        return date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;
    }
  }

  void _onDateTap(DateTime date) {
    if (!_isDateSelectable(date)) return;
    widget.onDateChanged?.call(date);
  }

  List<Widget> _buildCalendarWeeks() {
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
    final firstWeekday = firstDayOfMonth.weekday % 7; // Make Sunday = 0

    List<Widget> allDays = [];

    // Add previous month's trailing days
    for (int i = 0; i < firstWeekday; i++) {
      final day = DateTime(
        _currentMonth.year,
        _currentMonth.month,
        1 - firstWeekday + i,
      );
      allDays.add(
        _buildCalendarDay(day.day.toString(), date: day, isOtherMonth: true),
      );
    }

    // Add current month's days
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final isSelected =
          date.year == widget.selectedDate.year &&
          date.month == widget.selectedDate.month &&
          date.day == widget.selectedDate.day;
      final isToday =
          date.year == DateTime.now().year &&
          date.month == DateTime.now().month &&
          date.day == DateTime.now().day;

      allDays.add(
        _buildCalendarDay(
          day.toString(),
          date: date,
          isSelected: isSelected,
          isToday: isToday,
        ),
      );
    }

    // Group days into weeks (rows of 7)
    List<Widget> weeks = [];
    for (int i = 0; i < allDays.length; i += 7) {
      List<Widget> weekDays = [];
      for (int j = 0; j < 7; j++) {
        if (i + j < allDays.length) {
          weekDays.add(allDays[i + j]);
        } else {
          // Fill empty spaces if needed
          weekDays.add(const SizedBox(width: 32, height: 32));
        }
      }
      weeks.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekDays
              .map((day) => Expanded(child: Center(child: day)))
              .toList(),
        ),
      );
    }

    return weeks;
  }

  Widget _buildCalendarDay(
    String dayText, {
    required DateTime date,
    bool isSelected = false,
    bool isToday = false,
    bool isOtherMonth = false,
  }) {
    final theme = Theme.of(context);
    final isSelectable = _isDateSelectable(date);

    return GestureDetector(
      key: Key(
        'calendarDay_${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      ),
      onTap: () => _onDateTap(date),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? theme.colorScheme.primary
              : isToday
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          border: isToday && !isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 1)
              : null,
        ),
        child: Center(
          child: Text(
            dayText,
            key: Key(
              'calendarDayText_${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isOtherMonth
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                  : isSelected
                  ? theme.colorScheme.onPrimary
                  : isToday
                  ? theme.colorScheme.primary
                  : !isSelectable &&
                        widget.selectionMode != CalendarSelectionMode.none
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                  : theme.colorScheme.onSurface,
              fontWeight: isSelected || isToday
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      key: const Key('petraCalendarContainer'),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        key: const Key('petraCalendarColumn'),
        children: [
          // Calendar Header
          Container(
            key: const Key('petraCalendarHeaderContainer'),
            padding: const EdgeInsets.all(16),
            child: Row(
              key: const Key('petraCalendarHeaderRow'),
              children: [
                if (widget.headerIcon != null) ...[
                  Icon(
                    widget.headerIcon,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                if (widget.headerTitle != null)
                  Text(
                    widget.headerTitle!,
                    key: const Key('petraCalendarHeaderTitle'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  )
                else ...[
                  if (widget.showNavigation)
                    GestureDetector(
                      key: const Key('petraCalendarPrevMonth'),
                      onTap: _previousMonth,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.chevron_left,
                          size: 20,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 28),
                  Expanded(
                    flex: 200,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Text(
                        '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                        key: const Key('petraCalendarMonthYear'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        softWrap: false,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  if (widget.showNavigation)
                    GestureDetector(
                      key: const Key('petraCalendarNextMonth'),
                      onTap: _nextMonth,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 28),
                ],
                if (widget.showSelectedDateIndicator) ...[
                  const Spacer(),
                  Container(
                    key: const Key('petraCalendarSelectedDateIndicator'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}',
                      key: const Key('petraCalendarSelectedDateText'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Calendar Days Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              key: const Key('petraCalendarDaysHeaderRow'),
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map(
                    (day) => Expanded(
                      child: Text(
                        day,
                        key: Key('petraCalendarDayHeader_$day'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Calendar Days Grid
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Column(
              key: const Key('petraCalendarGridColumn'),
              children: _buildCalendarWeeks(),
            ),
          ),
        ],
      ),
    );
  }
}
