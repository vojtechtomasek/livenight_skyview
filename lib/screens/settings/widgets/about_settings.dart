import 'package:flutter/material.dart';
import 'settings_section_title.dart';
import 'settings_title.dart';

class AboutSettingsSection extends StatelessWidget {
  const AboutSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionTitle("About"),
        const SizedBox(height: 8),
        const SettingsTile(
          title: "Version",
          subtitle: "0.1 (Prototype)",
          trailing: SizedBox(),
        ),
        SettingsTile(
          title: "Open Source License",
          subtitle: "View license details",
          trailing: IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white70),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
