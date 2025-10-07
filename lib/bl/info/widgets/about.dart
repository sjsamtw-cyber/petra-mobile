import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:petrasoft_school_management_solutions/services/firebase/local_utils/firebase.service.dart';
import 'package:petrasoft_school_management_solutions/shared/utils/widgets/branding.dart';
import 'package:petrasoft_school_management_solutions/shared/utils/widgets/loading_widget.dart';

class About extends StatefulWidget {
  static const String page = '/about';

  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  late FirebaseAnalytics analytics;
  late TextStyle textStyle;
  late List<String> aboutUsParagraphs;
  late bool firstTime;

  @override
  void initState() {
    super.initState();
    analytics = FirebaseAnalytics.instance;
    firstTime = true;
    aboutUsParagraphs = [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (firstTime) {
      // Setting the styles once and for all.
      textStyle =
          theme.textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.5) ??
          const TextStyle();

      firstTime = false;
    }

    return FutureBuilder<List<String>>(
      future: FirebaseService().getAboutUsContent(),
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        return !snapshot.hasData
            ? const LoadingWidget(key: Key('aboutLoadingWidget'))
            : SingleChildScrollView(
                key: const Key('aboutScrollView'),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Dynamically loaded content from Firebase
                    ...List.generate(
                      snapshot.data!.length,
                      (index) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data![index],
                            key: Key('aboutParagraph_$index'),
                            style: textStyle,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36), // Extra space before logo
                    // Logo and company name section
                    Center(
                      child: PetrasoftBranding(
                        key: const Key('aboutBranding'),
                        logoSize: 42.0,
                        spacing: 8.0,
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              );
      },
    );
  }
}
