import 'package:flutter/cupertino.dart';
import 'settings_section_title.dart';
import 'settings_title.dart';

class LocationSettingsSection extends StatelessWidget {
  final bool useCurrentLocation;
  final ValueChanged<bool> onUseCurrentLocationChanged;

  const LocationSettingsSection({
    super.key,
    required this.useCurrentLocation,
    required this.onUseCurrentLocationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionTitle("Location & Time"),
        const SizedBox(height: 8),
        SettingsTile(
          title: "Use Current Location",
          subtitle: "Automatically detect position using GPS",
          trailing: CupertinoSwitch(
            value: useCurrentLocation,
            activeTrackColor: CupertinoColors.activeBlue,
            onChanged: onUseCurrentLocationChanged,
          ),
        ),
        if (!useCurrentLocation) ...[
          const SettingsTile(
            title: "Custom Location",
            subtitle: "Set manual coordinates",
            trailing: SizedBox(),
          ),
          _CustomLocationFields(),
        ],
      ],
    );
  }
}

class _CustomLocationFields extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.white.withOpacity(0.1)),
      ),
      child: const Column(
        children: [
          _LocationTextField(label: "Latitude", hint: "e.g. 50.0755"),
          SizedBox(height: 12),
          _LocationTextField(label: "Longitude", hint: "e.g. 14.4378"),
        ],
      ),
    );
  }
}

class _LocationTextField extends StatelessWidget {
  final String label;
  final String hint;
  const _LocationTextField({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      placeholder: hint,
      placeholderStyle: TextStyle(color: CupertinoColors.white.withOpacity(0.4)),
      style: const TextStyle(color: CupertinoColors.white),
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.white.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      prefix: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Text(
          label,
          style: TextStyle(color: CupertinoColors.white.withOpacity(0.7)),
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }
}
