import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../../routes/app_router.dart';
import '../object_detail/object_detail_screen.dart';
import 'widgets/sky_view_background.dart';
import 'widgets/sky_view_bottom_bar.dart';
import 'widgets/sky_view_top_bar.dart';

@RoutePage()
class SkyViewScreen extends StatelessWidget {
  const SkyViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const SkyViewBackground(),

          SafeArea(
            bottom: false,
            child: SkyViewTopBar(
              onSettingsTap: () {
                context.router.push(const SettingsRoute());
              },
              onSearchTap: () {
                // TODO: search
              },
            ),
          ),

          const SkyViewBottomBar(),

          // Tlačítko jako POSLEDNÍ vrstva (nejvyšší z-index)
          Center(
            child: ElevatedButton(
              onPressed: () {
                showObjectDetailSheet(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.22),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Otevřít sheet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
