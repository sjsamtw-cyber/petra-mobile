/*
 * One place for all Firebase related stuff.
 */
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:petrasoft_school_management_solutions/flavors.dart';
import 'package:petrasoft_school_management_solutions/services/app_preferences/model/app_preferences.dart';
import 'package:petrasoft_school_management_solutions/services/firebase/models/firebase_options.dart';
import 'package:petrasoft_school_management_solutions/services/firebase/models/notification_event.dart';

class FirebaseService {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  static late FirebaseService _instance;
  late FirebaseMessaging firebaseMessaging;
  late FirebaseFirestore firebaseFirestore;

  // Notification related fields
  final _notificationController =
      StreamController<NotificationEvent>.broadcast();
  NotificationEvent? _pendingInitialEvent;
  bool _hasListener = false;

  Stream<NotificationEvent> get notificationStream {
    // Custom stream that emits the pending event to the first subscriber
    return Stream<NotificationEvent>.multi((controller) {
      _hasListener = true;
      // Emit pending event if present
      if (_pendingInitialEvent != null) {
        controller.add(_pendingInitialEvent!);
        _pendingInitialEvent = null;
      }
      final sub = _notificationController.stream.listen(controller.add);
      controller.onCancel = () {
        sub.cancel();
        _hasListener = false;
      };
    });
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late AndroidNotificationChannel channel;

  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    // Honour flavour-based Firebase setup
    if (!Firebase.apps.any((app) => app.name == F.appFlavor.name)) {
      await Firebase.initializeApp(
        /*
        name: F.appFlavor.name,
        options: DefaultFirebaseOptions.currentPlatform,
        */
      );
    }

    if (kDebugMode) {
      print('Handling a background message with id : ${message.messageId}');
      print(
        'Showing local notification and emitting event in background handler.',
      );
    }

    // Show a local notification using flutter_local_notifications
    final FlutterLocalNotificationsPlugin notificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const InitializationSettings initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await notificationsPlugin.initialize(initSettings);

    String title = message.notification?.title ?? 'Notification';
    String body = message.notification?.body ?? 'You have a new message.';
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'petra_notifications',
          'Petra Notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          playSound: true,
        );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );
    await notificationsPlugin.show(
      message.hashCode,
      title,
      body,
      notificationDetails,
      payload: message.data['petra_notification_type'],
    );

    // Emit navigation event (if possible)
    // Note: In background isolate, you can't access the main app's event stream directly.
    // But you can use a callback or persistent storage if needed for advanced use cases.
    // For now, notification tap will be handled when app resumes via getInitialMessage/onMessageOpenedApp.
  }

  /*
   * Initialize Firebase with the given build variant.
   * Run this in main function before using any Firebase related services.
   */
  static Future<void> init() async {
    late FirebaseApp firebaseApp;
    if (!Firebase.apps.any((app) => app.name == F.appFlavor.name)) {
      firebaseApp = await Firebase.initializeApp(
        name: F.appFlavor.name,
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      firebaseApp = Firebase.apps.firstWhere(
        (app) => app.name == F.appFlavor.name,
      );
    }

    bool realDevice = false;

    if (Platform.isAndroid) {
      var androidInfo = await deviceInfoPlugin.androidInfo;
      realDevice = androidInfo.isPhysicalDevice;
    }

    if (Platform.isIOS) {
      var iDeviceInfo = await deviceInfoPlugin.iosInfo;
      realDevice = iDeviceInfo.isPhysicalDevice;
    }
    _instance = FirebaseService._init(firebaseApp);

    // Initialize notifications
    await _instance._setupNotifications();

    switch (F.appFlavor.name) {
      case "dev":
        {
          if (!realDevice) {
            // Parse host and port
            final parts = AppPreferences().firestoreDebugHost.split(':');
            final host = parts[0]; // 10.0.2.2 or localhost
            final port = int.parse(parts[1]); // 63421

            if (!kReleaseMode) {
              debugPrint(
                "🔌 Explicitly connecting to Firestore emulator at $host:$port",
              );
            }
            _instance.firebaseFirestore.useFirestoreEmulator(host, port);

            // Also set settings
            _instance.firebaseFirestore.settings = Settings(
              sslEnabled: false,
              persistenceEnabled: true,
              cacheSizeBytes: 50000000,
            );
          }
        }
        break;
      default:
        // staging, qa and prod
        {
          _instance.firebaseFirestore.settings = const Settings(
            persistenceEnabled: true,
            cacheSizeBytes: 50000000,
          );
        }
        break;
    }

    // Update the iOS foreground notification presentation options to allow heads up notifications.
    await _instance.firebaseMessaging
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Set up FCM message handlers
    await _instance._initializeFCM();
  }

  Future<void> _initializeFCM() async {
    // Get initial message (app opened from terminated state)
    final initialMessage = await firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      final event = NotificationEvent.fromMessage(initialMessage.data);
      // If no listeners yet, buffer the event
      if (!_hasListener || !_notificationController.hasListener) {
        _pendingInitialEvent = event;
      } else {
        _notificationController.add(event);
      }
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle messages when app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Handling FCM message: ${message.data}');
    }

    final event = NotificationEvent.fromMessage(message.data);
    _notificationController.add(event);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    final imageUrl =
        message.notification?.android?.imageUrl ??
        message.data['image_url'] ??
        message.notification?.apple?.imageUrl;

    if (notification != null) {
      final NotificationDetails notificationDetails;

      if (Platform.isAndroid) {
        final styleInformation = imageUrl != null
            ? BigPictureStyleInformation(
                FilePathAndroidBitmap(imageUrl),
                hideExpandedLargeIcon: true,
              )
            : null;

        notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            styleInformation: styleInformation,
            importance: Importance.high,
            icon: '@mipmap/ic_launcher',
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            playSound: true,
          ),
        );
      } else if (Platform.isIOS) {
        // For iOS, we use DarwinNotificationDetails
        notificationDetails = NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            attachments: imageUrl != null
                ? [DarwinNotificationAttachment(imageUrl)]
                : null,
          ),
        );
      } else {
        notificationDetails = const NotificationDetails();
      }

      await flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        notificationDetails,
        payload: message.data['petra_notification_type'],
      );
    }
    // Do NOT call _handleMessage here. Navigation should only happen when notification is tapped.
  }

  Future<void> _setupNotifications() async {
    if (Platform.isAndroid) {
      channel = const AndroidNotificationChannel(
        'petra_notifications', // same ID as used in express_controller.js
        'Petra Notifications', // Channel name
        description:
            'Notifications from Petra School Management', // Channel description
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
        showBadge: true,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }

    // Initialize local notifications with tap callback
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null) {
          _notificationController.add(
            NotificationEvent(
              type: payload,
              data: {'petra_notification_type': payload},
            ),
          );
        }
      },
    );
  }

  FirebaseService._init(FirebaseApp fbApp) {
    //Set a message handler function which is called when the app is in the background or terminated.
    FirebaseMessaging.onBackgroundMessage(
      FirebaseService._firebaseMessagingBackgroundHandler,
    );

    // These instances are later modified in the static init
    firebaseMessaging = FirebaseMessaging.instance;
    firebaseFirestore = FirebaseFirestore.instance;
  }

  factory FirebaseService() {
    // Returning the Singleton instance henceforth
    // We will rarely be using this as we can directly access the static instance which is more convenient.
    return FirebaseService._instance;
  }

  Future<String> get fcmDeviceToken async {
    return (await firebaseMessaging.getToken()) ?? '';
  }

  Future<List<String>> getAboutUsContent() async {
    List<String> paragraphs = [];
    var docSnapshot = await FirebaseService._instance.firebaseFirestore
        // This will have the about us content in the test flight.
        .doc('/about_us/content') // TO DO : Update this is node seeder.
        .get(const GetOptions(source: Source.serverAndCache));
    if (docSnapshot.exists) {
      paragraphs = List<String>.from(
        docSnapshot.get('matter'),
      ); // docSnapshot.get('matter') ?? [];
      if (!kReleaseMode) {
        debugPrint(paragraphs.toString());
      }
    }
    return paragraphs;
  }

  Future<List<String>> getPrivacyPolicyContent() async {
    List<String> paragraphs = [];
    var docSnapshot = await FirebaseService._instance.firebaseFirestore
        .doc('/privacy_policy/content')
        .get(const GetOptions(source: Source.serverAndCache));
    if (docSnapshot.exists) {
      paragraphs = List<String>.from(docSnapshot.get('matter'));
      if (!kReleaseMode) {
        debugPrint(paragraphs.toString());
      }
    }
    return paragraphs;
  }

  Future<String> getTestGreeting() async {
    var docSnapshot = await FirebaseService._instance.firebaseFirestore
        .doc('/message_test/content')
        .get(const GetOptions(source: Source.serverAndCache));
    if (docSnapshot.exists) {
      return docSnapshot.get('value') ?? '';
    }
    return '';
  }

  Future<bool> checkIfSchoolCodeIsValid(String schoolCode) async {
    // Fill in the school codes
    var docSnapshot = await FirebaseService._instance.firebaseFirestore
        .doc('/school_codes/codes')
        .get(const GetOptions(source: Source.serverAndCache));
    var isSchoolCodesSetInFirebase = docSnapshot.exists;
    if (!isSchoolCodesSetInFirebase) {
      return false;
    }
    List<dynamic> validSchoolCodes = docSnapshot.get('codes') ?? [];
    return validSchoolCodes.contains(schoolCode);
  }

  void dispose() {
    _notificationController.close();
  }
}
