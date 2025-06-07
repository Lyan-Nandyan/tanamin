import 'package:hive/hive.dart';
part 'schedule.g.dart';

@HiveType(typeId: 0)
class PlantSchedule extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int hour;

  @HiveField(2)
  int minute;

  @HiveField(3)
  List<int> repeatDays;

  @HiveField(4)
  String title;

  @HiveField(5)
  String body;

  PlantSchedule({
    required this.id,
    required this.hour,
    required this.minute,
    required this.repeatDays,
    required this.title,
    required this.body,
  });
}
