import 'package:flutter/cupertino.dart';
import '../../../models/constellation_type.dart';
import 'settings_section_title.dart';
import 'settings_title.dart';

class ConstellationSettingsSection extends StatelessWidget {
  final ConstellationType selectedConstellation;
  final ValueChanged<ConstellationType> onConstellationChanged;

  const ConstellationSettingsSection({
    super.key,
    required this.selectedConstellation,
    required this.onConstellationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionTitle("Constellation Style"),
        const SizedBox(height: 8),
        SettingsTile(
          title: "Constellation Type",
          subtitle: "Choose cultural constellation pattern",
          trailing: GestureDetector(
            onTap: () => _showConstellationPicker(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedConstellation.displayName,
                  style: const TextStyle(
                    color: CupertinoColors.activeBlue,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  CupertinoIcons.chevron_right,
                  color: CupertinoColors.activeBlue,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showConstellationPicker(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const Text(
                      'Select Constellation',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
              Container(
                height: 0.5,
                color: CupertinoColors.separator,
              ),
              Expanded(
                child: CupertinoPicker(
                  magnification: 1.22,
                  squeeze: 1.2,
                  useMagnifier: true,
                  itemExtent: 32,
                  scrollController: FixedExtentScrollController(
                    initialItem: ConstellationType.values.indexOf(selectedConstellation),
                  ),
                  onSelectedItemChanged: (int selectedIndex) {
                    onConstellationChanged(ConstellationType.values[selectedIndex]);
                  },
                  children: ConstellationType.values
                      .map((type) => Center(
                            child: Text(
                              type.displayName,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}