import 'package:flutter/material.dart';
import 'package:petrasoft_school_management_solutions/bl/notices/models/notice.dart';
import 'package:petrasoft_school_management_solutions/bl/notices/services/notice_service.dart';
import 'package:petrasoft_school_management_solutions/bl/notices/widgets/notice_card.dart';
import 'package:petrasoft_school_management_solutions/shared/utils/widgets/loading_widget.dart';

class NoticesScreen extends StatefulWidget {
  static const String page = '/notices';
  const NoticesScreen({super.key});

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  String? _selectedCategory;
  NoticeResult? _noticeResult;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  Future<void> _loadNotices() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await NoticeService.fetchNotices();
      if (!mounted) return;

      setState(() {
        _noticeResult = result;
        _isLoading = false;
        // Set default category if available
        if (result.isSuccess && result.categories.isNotEmpty) {
          _selectedCategory = result.categories.first;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Notice> _getFilteredNotices() {
    if (_noticeResult == null || !_noticeResult!.isSuccess) return [];

    if (_selectedCategory == null) return _noticeResult!.notices;

    return _noticeResult!.notices
        .where((notice) => notice.categories.contains(_selectedCategory))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _isLoading
        ? const LoadingWidget(key: Key('noticesLoadingWidget'))
        : RefreshIndicator(
            key: const Key('noticesRefreshIndicator'),
            onRefresh: _loadNotices,
            child: _error != null
                ? SingleChildScrollView(
                    key: const Key('noticesErrorScroll'),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height:
                          MediaQuery.of(context).size.height - kToolbarHeight,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            key: const Key('noticesErrorColumn'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                key: const Key('noticesErrorIcon'),
                                size: 48,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _error!,
                                key: const Key('noticesErrorText'),
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : CustomScrollView(
                    key: const Key('noticesScrollView'),
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      if (_noticeResult != null &&
                          _noticeResult!.categories.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: DropdownButtonFormField<String>(
                              key: const Key('noticesCategoryDropdown'),
                              value: _selectedCategory,
                              decoration: InputDecoration(
                                labelText:
                                    _noticeResult?.dropdownTitle ?? 'Filter',
                                border: const OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('All'),
                                ),
                                ..._noticeResult!.categories.map((category) {
                                  return DropdownMenuItem(
                                    value: category,
                                    child: Text(category),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              },
                            ),
                          ),
                        ),
                      SliverPadding(
                        padding: const EdgeInsets.all(16.0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final notices = _getFilteredNotices();
                              if (notices.isEmpty) {
                                return Center(
                                  key: const Key('noticesEmptyCenter'),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'No notices found',
                                      key: const Key('noticesEmptyText'),
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ),
                                );
                              }
                              return NoticeCard(
                                key: Key(
                                  'noticeCard_${notices[index].noticeId}',
                                ),
                                notice: notices[index],
                              );
                            },
                            childCount: _getFilteredNotices().isEmpty
                                ? 1
                                : _getFilteredNotices().length,
                          ),
                        ),
                      ),
                    ],
                  ),
          );
  }
}
