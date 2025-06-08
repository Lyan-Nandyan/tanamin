import 'dart:async';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:tanamin/core/service/convet_time_service.dart';

class TimeConvert extends StatefulWidget {
  const TimeConvert({super.key});

  @override
  State<TimeConvert> createState() => _TimeConvertState();
}

class _TimeConvertState extends State<TimeConvert> {
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
        title: const Text('Konversi Waktu'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Container(
        color: Colors.green[50],
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        const Text(
                          'Waktu Saat Ini',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}:${_currentTime.second.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.green),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Zona Lokal: $localZone',
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: timeMap.length,
                itemBuilder: (context, index) {
                  final key = timeMap.keys.elementAt(index);
                  final value = timeMap[key];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[200],
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        key,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        index != 0 ? '$value' : '$value $localZone',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
