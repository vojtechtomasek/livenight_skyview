import 'package:flutter/material.dart';
import 'settings_section_title.dart';
import 'settings_title.dart';


class DisplaySettingsSection extends StatelessWidget {
  final bool darkMode;
  final bool showConstellationLines;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<bool> onShowConstellationLinesChanged;

  const DisplaySettingsSection({
    super.key,
    required this.darkMode,
    required this.showConstellationLines,
    required this.onDarkModeChanged,
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
          title: "Dark Mode",
          subtitle: "Use darker theme for night viewing",
          trailing: Switch(value: darkMode, onChanged: onDarkModeChanged),
        ),
        SettingsTile(
          title: "Show Constellation Lines",
          subtitle: "Display lines connecting stars",
          trailing: Switch(
              value: showConstellationLines,
              onChanged: onShowConstellationLinesChanged),
        ),
      ],
    );
  }
}
