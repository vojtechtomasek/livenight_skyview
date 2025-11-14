import 'package:flutter/cupertino.dart';

class ObjectHeader extends StatelessWidget {
  const ObjectHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Object Name",
          style: TextStyle(
            color: CupertinoColors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Type • Constellation",
          style: TextStyle(
            color: CupertinoColors.white.withOpacity(0.75),
            fontSize: 14,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: CupertinoColors.systemGrey,
            boxShadow: const [
              BoxShadow(
                color: Color(0x8A000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              CupertinoIcons.photo,
              size: 48,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ),
      ],
    );
  }
}
