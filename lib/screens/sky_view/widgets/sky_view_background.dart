import 'package:flutter/material.dart';

class SkyViewBackground extends StatelessWidget {
  const SkyViewBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0F2C),
            Color(0xFF0E1B47),
          ],
        ),
      ),
    );
  }
}
