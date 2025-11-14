import 'package:flutter/cupertino.dart';
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
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              // TODO: open App Store listing
            },
            child: const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey,
              size: 20,
            ),
          ),
        ),
        SettingsTile(
          title: "Data Source",
          subtitle: "Star catalog and ephemeris (placeholder)",
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              // TODO: open data source link/details
            },
            child: const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey,
              size: 20,
            ),
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
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {},
            child: const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
