import 'package:hive/hive.dart';

part 'myplant.g.dart';

@HiveType(typeId: 1)
class MyPlant extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<int> scheduleIds; // daftar id notifikasi terkait tanaman ini

  @HiveField(3)
  DateTime addedAt; // kapan tanaman ini ditambahkan

  MyPlant({
    required this.name,
    required this.scheduleIds,
    required this.addedAt,
  });
}
