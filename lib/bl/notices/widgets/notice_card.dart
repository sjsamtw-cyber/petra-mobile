import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../models/notice.dart';

/// Widget that displays a single notice card
/// Replicates the functionality from the old petra_mobile Notice widget
class NoticeCard extends StatelessWidget {
  final Notice notice;

  const NoticeCard({super.key, required this.notice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      key: Key('noticeCard_${notice.noticeId}'),
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha((255 * 0.1).round()),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notice title
          Text(
            notice.noticeName,
            key: Key('noticeTitle_${notice.noticeId}'),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 5.0),

          // Notice description with link support
          _buildNoticeDescription(
            context,
            notice.noticeDescription,
            notice.noticeId,
          ),

          const SizedBox(height: 10.0),

          // Date range
          if (notice.startDate.isNotEmpty && notice.endDate.isNotEmpty)
            Row(
              children: [
                Icon(
                  Icons.date_range,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${notice.startDate} - ${notice.endDate}',
                  key: Key('noticeDateRange_${notice.noticeId}'),
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 10.0),

          // Last updated timestamp
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              'Last updated: ${notice.formattedTimestamp} IST',
              key: Key('noticeLastUpdated_${notice.noticeId}'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds notice description with clickable links
  /// Replicates the LinkRichText functionality from the old app
  Widget _buildNoticeDescription(
    BuildContext context,
    String description,
    int noticeId,
  ) {
    final theme = Theme.of(context);

    // Simple implementation - you might want to add a proper rich text parser
    // For now, just display as regular text with tap-to-launch URL support
    return GestureDetector(
      onTap: () {
        _handleTextTap(description);
      },
      child: Text(
        description,
        key: Key('noticeDescription_$noticeId'),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  /// Handles tapping on text to launch URLs
  void _handleTextTap(String text) {
    // Simple URL detection - you might want to use a more sophisticated parser
    final urlRegex = RegExp(r'https?://[^\s]+');
    final match = urlRegex.firstMatch(text);

    if (match != null) {
      final url = match.group(0)!;
      launchUrlString(url);
    }
  }
}
