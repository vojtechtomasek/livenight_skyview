import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'widgets/display_settings.dart';
import 'widgets/location_settings.dart';
import 'widgets/about_settings.dart';

@RoutePage()
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showConstellationLines = false;
  bool _useCurrentLocation = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0F2C), Color(0xFF0E1B47)],
          ),
        ),
        child: CupertinoPageScaffold(
          backgroundColor: CupertinoColors.transparent,
          navigationBar: const CupertinoNavigationBar(
            backgroundColor: CupertinoColors.transparent,
            border: null,
            middle: Text(
              "Settings",
              style: TextStyle(color: CupertinoColors.white),
            ),
          ),
          child: SafeArea(
            top: true,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DisplaySettingsSection(
                  showConstellationLines: _showConstellationLines,
                  onShowConstellationLinesChanged: (v) =>
                      setState(() => _showConstellationLines = v),
                ),

                const SizedBox(height: 20),
                
                LocationSettingsSection(
                  useCurrentLocation: _useCurrentLocation,
                  onUseCurrentLocationChanged: (v) =>
                      setState(() => _useCurrentLocation = v),
                ),

                const SizedBox(height: 20),
                
                const AboutSettingsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
