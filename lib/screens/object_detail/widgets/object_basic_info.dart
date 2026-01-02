import 'package:flutter/cupertino.dart';
import 'package:livenight_skyview/models/star.dart';
import 'info_row.dart';

class ObjectBasicInfo extends StatelessWidget {
  final Star star;
  const ObjectBasicInfo({super.key, required this.star});

  String _formatCoordinate(double value, bool isRa) {
    if (isRa) {
      final hours = value / 15.0;
      final h = hours.floor();
      final m = ((hours - h) * 60).floor();
      final s = ((hours - h - m / 60) * 3600).toStringAsFixed(1);
      return '${h}h ${m}m ${s}s';
    } else {
      final sign = value >= 0 ? '+' : '-';
      final absValue = value.abs();
      final d = absValue.floor();
      final m = ((absValue - d) * 60).floor();
      final s = ((absValue - d - m / 60) * 3600).toStringAsFixed(1);
      return '$sign${d}° ${m}\' ${s}"';
    }
  }

  String? _calculateDistance() {
    if (star.parallaxMas == null || star.parallaxMas! <= 0) return null;
    final distanceParsecs = 1000 / star.parallaxMas!;
    final distanceLightYears = distanceParsecs * 3.26156;
    return '${distanceLightYears.toStringAsFixed(1)} ly';
  }

  @override
  Widget build(BuildContext context) {
    final distance = _calculateDistance();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Basic Info",
          style: TextStyle(
            color: CupertinoColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        InfoRow(label: "HIP ID", value: star.hip.toString()),
        InfoRow(
          label: "Magnitude", 
          value: (star.vMag ?? star.mag).toStringAsFixed(2),
        ),
        if (star.spectralType != null)
          InfoRow(label: "Spectral Type", value: star.spectralType!),
        InfoRow(
          label: "Right Ascension",
          value: _formatCoordinate(star.raDegDetail ?? star.raDeg, true),
        ),
        InfoRow(
          label: "Declination",
          value: _formatCoordinate(star.decDegDetail ?? star.decDeg, false),
        ),
        if (distance != null)
          InfoRow(label: "Distance", value: distance),
      ],
    );
  }
}
