import 'package:flutter/cupertino.dart';
import 'package:livenight_skyview/models/star.dart';

class ObjectDescription extends StatelessWidget {
  final Star star;
  const ObjectDescription({super.key, required this.star});

  @override
  Widget build(BuildContext context) {
    if (star.description == null || star.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Description",
          style: TextStyle(
            color: CupertinoColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          star.description!,
          style: TextStyle(
            color: CupertinoColors.white.withValues(alpha: 0.85),
            height: 1.5,
            fontSize: 14.5,
          ),
        ),
      ],
    );
  }
}
