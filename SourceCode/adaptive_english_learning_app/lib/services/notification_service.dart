import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int streakReminderId = 1001;
  static const int lessonReminderId = 1002;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tz.initializeTimeZones();

    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await _plugin.initialize(initializationSettings);
    _initialized = true;
  }

  Future<bool> ensurePermissions() async {
    await initialize();

    final androidGranted =
        await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission() ??
        true;

    final iOSGranted =
        await _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true) ??
        true;

    return androidGranted && iOSGranted;
  }

  Future<void> scheduleStreakReminder() async {
    await _scheduleDailyNotification(
      streakReminderId,
      'Keep your streak going',
      'Open the app today to protect your learning streak.',
      20,
      0,
      'streak_reminders',
      'Streak reminders',
      'Reminders to keep your streak active.',
    );
  }

  Future<void> scheduleLessonReminder() async {
    await _scheduleDailyNotification(
      lessonReminderId,
      'Ready for your next lesson?',
      'Come back to continue your English learning progress.',
      18,
      0,
      'lesson_reminders',
      'Lesson reminders',
      'Reminders to continue lessons.',
    );
  }

  Future<void> cancelStreakReminder() async {
    await initialize();
    await _plugin.cancel(streakReminderId);
  }

  Future<void> cancelLessonReminder() async {
    await initialize();
    await _plugin.cancel(lessonReminderId);
  }

  Future<void> _scheduleDailyNotification(
    int id,
    String title,
    String body,
    int hour,
    int minute,
    String channelId,
    String channelName,
    String channelDescription,
  ) async {
    await initialize();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
