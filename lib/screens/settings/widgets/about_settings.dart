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
        const SettingsTile(
          title: "Data Source",
          subtitle: "VizieR TAP, SIMBAD TAP, Stellarium cultures",
          trailing: SizedBox(),
        ),
        const SettingsTile(
          title: "Version",
          subtitle: "0.1 (prototype)",
          trailing: SizedBox(),
        ),
        const SettingsTile(
          title: "Open Source License",
          subtitle: "MIT License",
          trailing: SizedBox(),
        ),
      ],
    );
  }
}