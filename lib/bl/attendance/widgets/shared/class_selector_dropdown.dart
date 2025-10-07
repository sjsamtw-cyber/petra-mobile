import 'package:flutter/material.dart';
import 'package:petrasoft_school_management_solutions/bl/attendance/models/petra_class.dart';
import 'package:petrasoft_school_management_solutions/l10n/app_localizations.dart';

class ClassSelectorDropdown extends StatelessWidget {
  final List<PetraClass> classes;
  final PetraClass? selectedClass;
  final Function(PetraClass?) onClassChanged;
  final bool isLoading;

  const ClassSelectorDropdown({
    super.key,
    required this.classes,
    required this.selectedClass,
    required this.onClassChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.surface,
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Material(
              color: Colors.transparent,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<PetraClass>(
                  value: selectedClass,
                  hint: Text(
                    l10n.selectClass,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  isExpanded: true,
                  items: classes.isEmpty
                      ? [
                          DropdownMenuItem<PetraClass>(
                            value: null,
                            child: Text(
                              'No classes available',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ),
                        ]
                      : classes.map((PetraClass petraClass) {
                          return DropdownMenuItem<PetraClass>(
                            value: petraClass,
                            child: Text(
                              petraClass.className,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          );
                        }).toList(),
                  onChanged: classes.isEmpty ? null : onClassChanged,
                ),
              ),
            ),
    );
  }
}
