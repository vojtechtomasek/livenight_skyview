import 'package:flutter/material.dart';

class SkyViewBottomBar extends StatelessWidget {
  const SkyViewBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        top: false,
        child: Container(
          height: 60,
          alignment: Alignment.center,
          color: Colors.black.withValues(alpha: 0.15),
          child: Text(
            "Compass Placeholder",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
