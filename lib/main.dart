import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://crypxajpalxvnyhkjqza.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNyeXB4YWpwYWx4dm55aGtqcXphIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg4OTgzMTUsImV4cCI6MjA4NDQ3NDMxNX0.79hUL4kybyAhImwCQloq6NXupE130kKREYymhOAs8oc',
  );

  await _setupNotifications();

  bool hasShownError = false;

  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (!hasShownError) {
      hasShownError = true;
      Future.delayed(Duration(seconds: 5), () => hasShownError = false);
      return CustomErrorWidget(errorDetails: details);
    }
    return SizedBox.shrink();
  };

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    value,
  ) {
    runApp(MyApp());
  });
}

Future<void> _setupNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Define the high-importance channel WITH CUSTOM SOUND
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'dryce_alerts_channel',
    'DryCe Critical Alerts',
    description: 'Notifications for high temperature and moisture targets',
    importance: Importance.max,
    playSound: true,
    // Reference the file in res/raw/dryce_alarm.mp3 (don't include .mp3)
    sound: RawResourceAndroidNotificationSound('dryce_alarm'),
    enableVibration: true,
    showBadge: true,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);
}

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false, // We only start it when they click START in the app
      isForegroundMode: true,
      notificationChannelId: 'dryce_alerts_channel',
      initialNotificationTitle: 'DryCe Monitoring',
      initialNotificationContent: 'System is running in background',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  // Re-initialize Supabase because this runs in an isolated background thread
  await Supabase.initialize(
    url: 'https://crypxajpalxvnyhkjqza.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNyeXB4YWpwYWx4dm55aGtqcXphIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg4OTgzMTUsImV4cCI6MjA4NDQ3NDMxNX0.79hUL4kybyAhImwCQloq6NXupE130kKREYymhOAs8oc',
  );

  final backgroundNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // To prevent notification spam, keep track of when we last notified for an issue
  Map<String, DateTime> lastNotified = {};

  Supabase.instance.client
      .from('sensors') // Make sure this matches your actual table name
      .stream(primaryKey: ['id'])
      .listen((List<Map<String, dynamic>> sensors) {
        final now = DateTime.now();

        for (var s in sensors) {
          // Adjust these keys based on your actual Supabase columns
          if (s['is_active'] == true) {
            double m = (s['moisture_percentage'] as num? ?? 0).toDouble();
            double t = (s['temperature'] as num? ?? 0).toDouble();
            String id = s['id']?.toString() ?? "Unknown";

            String? alertMessage;

            // Check conditions
            if (m <= 12.4) {
              alertMessage =
                  "Target moisture reached: ${m.toStringAsFixed(1)}%";
            } else if (m <= 13.5) {
              alertMessage =
                  "Approaching target moisture: ${m.toStringAsFixed(1)}%";
            }

            if (t > 45.0) {
              alertMessage = "LIMIT REACHED: ${t.toStringAsFixed(1)}°C";
            } else if (t > 40.0 && t <= 45.0) {
              alertMessage =
                  "Approaching temperature limit: ${t.toStringAsFixed(1)}°C";
            }

            // Trigger notification if there's an alert and 5 mins have passed since last one
            if (alertMessage != null) {
              String cacheKey = "$id-$alertMessage";
              if (!lastNotified.containsKey(cacheKey) ||
                  now.difference(lastNotified[cacheKey]!).inMinutes >= 5) {
                lastNotified[cacheKey] = now;

                backgroundNotificationsPlugin.show(
                  now.millisecond, // Random ID so they don't overwrite each other
                  "DryCe Alert: $id",
                  alertMessage,
                  const NotificationDetails(
                    android: AndroidNotificationDetails(
                      'dryce_alerts_channel',
                      'DryCe Critical Alerts',
                      importance: Importance.max,
                      priority: Priority.high,
                      playSound: true,
                      sound: RawResourceAndroidNotificationSound('dryce_alarm'),
                      enableVibration: true,
                      fullScreenIntent: true,
                    ),
                  ),
                );
              }
            }
          }
        }
      });

  // Listen for the stop command from the UI
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          title: 'dryce_monitoring_system',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.0)),
              child: child!,
            );
          },
          debugShowCheckedModeBanner: false,
          routes: AppRoutes.routes,
          initialRoute: AppRoutes.initial,
        );
      },
    );
  }
}
