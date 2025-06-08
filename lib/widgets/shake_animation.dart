import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeAnimation extends StatefulWidget {
  const ShakeAnimation({super.key});

  @override
  State<ShakeAnimation> createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<ShakeAnimation> {
  double shakeThreshold = 15.0;
  DateTime? lastShakeTime;
  bool isShowingAnimation = false;

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen(_onAccelerometerEvent);
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    final acceleration =
        sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    final now = DateTime.now();

    if (acceleration > shakeThreshold &&
        (lastShakeTime == null ||
            now.difference(lastShakeTime!) > const Duration(seconds: 2))) {
      lastShakeTime = now;
      _showLottieOverlay();
    }
  }

  void _showLottieOverlay() {
    if (isShowingAnimation) return;

    setState(() {
      isShowingAnimation = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6),
              child: Center(
                child: Lottie.asset(
                  'assets/animation/leaf_fall.json',
                  repeat: false,
                  onLoaded: (composition) {
                    Future.delayed(composition.duration, () {
                      if (mounted) {
                        Navigator.of(context).pop();
                        setState(() {
                          isShowingAnimation = false;
                        });
                      }
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // Ini cukup ditaruh di halaman utama
  }
}
