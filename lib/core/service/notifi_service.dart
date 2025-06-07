import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hive/hive.dart';
import 'package:tanamin/data/models/schedule.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotifiService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Inisialisasi zona waktu hanya sekali
    initializeTimeZones();

    await _setupTimeZone();
    await _initializeNotifications();
    await _requestPermissions();
  }

  Future<void> _setupTimeZone() async {
    try {
      final deviceTimeZone = await FlutterTimezone.getLocalTimezone();
      final location = getLocation(deviceTimeZone);
      setLocalLocation(location);
      debugPrint("Zona waktu berhasil di-set: $deviceTimeZone");

      // Simpan zona waktu ke shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_timezone', deviceTimeZone);
    } catch (e) {
      debugPrint(
          "Gagal set zona waktu perangkat, fallback ke Asia/Jakarta: $e");
      setLocalLocation(getLocation('Asia/Jakarta'));
    }
  }

  Future<void> _initializeNotifications() async {
    const androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(
      android: androidSetting,
    );
    await notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _requestPermissions() async {
    // Minta izin notifikasi dasar
    final granted = await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    debugPrint(granted == true
        ? "Izin notifikasi diberikan"
        : "Izin notifikasi ditolak atau tidak diminta");

    // Cek izin exact alarm jika Android 12+ (API 31+)
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      if (deviceInfo.version.sdkInt >= 31) {
        final plugin =
            notificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        final exactAlarmPermitted =
            await plugin?.canScheduleExactNotifications() ?? false;

        if (!exactAlarmPermitted) {
          debugPrint("Izin exact alarm belum diberikan. Membuka pengaturan...");
          final intent = AndroidIntent(
            action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
            flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
          );
          await intent.launch();
        } else {
          debugPrint("Izin exact alarm sudah diberikan");
        }
      }
    }
  }

  Future<void> showInstantNotification(
      {required int id, required String title, required String body}) async {
    await notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_notification_channel_id',
          'Instant Notifications',
          channelDescription: 'instant notifications channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
  }) async {
    TZDateTime now = TZDateTime.now(local);
    TZDateTime scheduledDate = now.add(
      Duration(seconds: 3),
    );

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel_id', // A unique ID to group notifications together.
          'Daily Reminders', // A human-readable name shown to users in their notification settings.
          channelDescription: 'Reminder to complete daily habits',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.dayOfWeekAndTime, // or dateAndTime
    );
  }

  Future<void> scheduleRepeatedReminder(PlantSchedule schedule) async {
    for (var weekday in schedule.repeatDays) {
      final scheduledDate =
          _nextInstanceOfWeekdayTime(weekday, schedule.hour, schedule.minute);

      await notificationsPlugin.zonedSchedule(
        int.parse('${schedule.id}$weekday'), // agar unik tiap hari
        schedule.title,
        schedule.body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'plant_schedule_channel_id',
            'Plant Care Schedule',
            channelDescription: 'Schedule reminders for watering/fertilizing',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  TZDateTime _nextInstanceOfWeekdayTime(int weekday, int hour, int minute) {
    final now = TZDateTime.now(local);
    TZDateTime scheduledDate =
        TZDateTime(local, now.year, now.month, now.day, hour, minute);

    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    return scheduledDate;
  }

  Future<void> deleteScheduleWithNotification(PlantSchedule schedule) async {
    final notificationsPlugin = FlutterLocalNotificationsPlugin();

    for (int weekday in schedule.repeatDays) {
      await notificationsPlugin.cancel(
          int.parse('${schedule.id}$weekday')); // cancel notifikasi spesifik
      debugPrint(
          "Notifikasi dengan ID ${int.parse('${schedule.id}$weekday')} dibatalkan");
    }

    final scheduleBox = Hive.box<PlantSchedule>('plant_schedules');
    await scheduleBox.delete(schedule.id); // hapus dari Hive
    debugPrint("Jadwal dengan ID ${schedule.id} dihapus dari Hive");
  }
}
