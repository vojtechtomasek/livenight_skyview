import 'package:flutter/material.dart';

class SkyViewBackground extends StatelessWidget {
  const SkyViewBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo.shade900.withValues(alpha: 0.85),
            Colors.blueGrey.shade900.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: Center(
        child: Text(
          "Sky View Placeholder",
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 18,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
