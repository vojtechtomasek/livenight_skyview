import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget trailing;

  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: LiquidGlass.withOwnLayer(
        settings: const LiquidGlassSettings(
          blur: 3.0,
          thickness: 4.0,
          refractiveIndex: 1.25,
          glassColor: Color(0x15FFFFFF),
          lightIntensity: 1.0,
          ambientStrength: 0.3,
          saturation: 1.0,
        ),
        shape: const LiquidRoundedSuperellipse(
          borderRadius: 14,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: CupertinoColors.white, fontWeight: FontWeight.w600)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: CupertinoColors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
