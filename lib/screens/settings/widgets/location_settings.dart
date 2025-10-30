import 'package:flutter/material.dart';
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
          trailing: Switch(
            value: useCurrentLocation,
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
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
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
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white30),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white70),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }
}
