import 'package:flutter/material.dart';
import 'info_row.dart';

class ObjectBasicInfo extends StatelessWidget {
  const ObjectBasicInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Basic Info",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
        InfoRow(label: "info1", value: "value1"),
        InfoRow(label: "info2", value: "value2"),
        InfoRow(label: "info3", value: "value3"),
        InfoRow(label: "info4", value: "value4"),
        InfoRow(label: "info5", value: "value5"),
      ],
    );
  }
}
