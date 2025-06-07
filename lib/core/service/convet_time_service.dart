import 'package:timezone/timezone.dart' as tz;

class ConvetTimeService {
  Map<String, String> convertLocalToZones(DateTime localTime) {
    final localZone =
        tz.local; // zona waktu yang sedang aktif (set dari setLocalLocation)

    // Buat waktu lokal dalam TZDateTime
    final tzLocalTime = tz.TZDateTime.from(localTime, localZone);

    // Konversi ke zona lain
    final wib = tz.TZDateTime.from(tzLocalTime, tz.getLocation('Asia/Jakarta'));
    final wita =
        tz.TZDateTime.from(tzLocalTime, tz.getLocation('Asia/Makassar'));
    final wit =
        tz.TZDateTime.from(tzLocalTime, tz.getLocation('Asia/Jayapura'));
    final london =
        tz.TZDateTime.from(tzLocalTime, tz.getLocation('Europe/London'));

    return {
      'Lokal': _formatTime(tzLocalTime),
      'WIB (Jakarta)': _formatTime(wib),
      'WITA (Makassar)': _formatTime(wita),
      'WIT (Jayapura)': _formatTime(wit),
      'London': _formatTime(london),
    };
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
