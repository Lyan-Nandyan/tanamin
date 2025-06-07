import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tanamin/core/service/convet_time_service.dart';
import 'package:timezone/timezone.dart' as tz;

class TestKonvertWaktu extends StatefulWidget {
  const TestKonvertWaktu({super.key});

  @override
  State<TestKonvertWaktu> createState() => _TestKonvertWaktuState();
}

class _TestKonvertWaktuState extends State<TestKonvertWaktu> {
  final ConvetTimeService convertService = ConvetTimeService();
  DateTime _currentTime = DateTime.now();
  Timer? _timer;
  final localZone = tz.local;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeMap = convertService.convertLocalToZones(_currentTime);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Konversi Waktu'),
      ),
      body: ListView.builder(
        itemCount: timeMap.length,
        itemBuilder: (context, index) {
          final key = timeMap.keys.elementAt(index);
          final value = timeMap[key];
          return ListTile(
            title: Text('$key: ${index != 0 ? value : '$value $localZone'} '),
          );
        },
      ),
    );
  }
}
