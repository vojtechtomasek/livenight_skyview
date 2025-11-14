import 'package:flutter/cupertino.dart';

class ObjectDescription extends StatelessWidget {
  const ObjectDescription({super.key});

  @override
  Widget build(BuildContext context) {
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
          "This is a placeholder description for the selected object. ",
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
