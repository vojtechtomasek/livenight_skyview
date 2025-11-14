import 'package:flutter/cupertino.dart';
import 'settings_section_title.dart';
import 'settings_title.dart';


class DisplaySettingsSection extends StatelessWidget {
  final bool showConstellationLines;
  final ValueChanged<bool> onShowConstellationLinesChanged;

  const DisplaySettingsSection({
    super.key,
    required this.showConstellationLines,
    required this.onShowConstellationLinesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionTitle("Display"),
        const SizedBox(height: 8),
        SettingsTile(
          title: "Show Constellation Lines",
          subtitle: "Display lines connecting stars",
          trailing: CupertinoSwitch(
              value: showConstellationLines,
              activeTrackColor: CupertinoColors.activeBlue,
              onChanged: onShowConstellationLinesChanged),
        ),
      ],
    );
  }
}
