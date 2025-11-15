import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../providers/location_provider.dart';
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

class _CustomLocationFields extends StatefulWidget {
  const _CustomLocationFields();

  @override
  State<_CustomLocationFields> createState() => _CustomLocationFieldsState();
}

class _CustomLocationFieldsState extends State<_CustomLocationFields> {
  late TextEditingController _latController;
  late TextEditingController _lonController;

  @override
  void initState() {
    super.initState();
    final locationProvider = context.read<LocationProvider>();

    _latController = TextEditingController(
      text: locationProvider.latitude?.toString() ?? '',
    );
    _lonController = TextEditingController(
      text: locationProvider.longitude?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.read<LocationProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _LocationTextField(
            label: "Latitude",
            hint: "e.g. 50.0755",
            controller: _latController,
            onChanged: (value) {
              final lat = double.tryParse(value);
              // necháme existující lon tak jak je
              locationProvider.setManualCoordinates(
                latitude: lat,
                longitude: locationProvider.longitude,
              );
            },
          ),
          const SizedBox(height: 12),
          _LocationTextField(
            label: "Longitude",
            hint: "e.g. 14.4378",
            controller: _lonController,
            onChanged: (value) {
              final lon = double.tryParse(value);
              locationProvider.setManualCoordinates(
                latitude: locationProvider.latitude,
                longitude: lon,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LocationTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const _LocationTextField({
    required this.label,
    required this.hint,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      onChanged: onChanged,
      placeholder: hint,
      placeholderStyle: TextStyle(
        color: CupertinoColors.white.withValues(alpha: 0.4),
      ),
      style: const TextStyle(color: CupertinoColors.white),
      decoration: BoxDecoration(
        border: Border.all(
          color: CupertinoColors.white.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      prefix: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Text(
          label,
          style: TextStyle(
            color: CupertinoColors.white.withValues(alpha: 0.7),
          ),
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }
}
