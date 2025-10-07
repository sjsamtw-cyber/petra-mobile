import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  static const String page = '/error';

  const ErrorPage({super.key});
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontSize: 20);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        key: const Key('errorPageColumn'),
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Oops! Page not found',
            key: const Key('errorPageText'),
            style: textStyle,
          ),
        ],
      ),
    );
  }
}
