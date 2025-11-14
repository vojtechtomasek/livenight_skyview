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
        SettingsTile(
          title: "App Store Link",
          subtitle: "Rate or review on the App Store",
          trailing: IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white70),
            onPressed: () {
              // TODO: open App Store listing
            },
          ),
        ),
        SettingsTile(
          title: "Data Source",
          subtitle: "Star catalog and ephemeris (placeholder)",
          trailing: IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white70),
            onPressed: () {
              // TODO: open data source link/details
            },
          ),
        ),
        const SettingsTile(
          title: "Version",
          subtitle: "0.1 (prototype)",
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
