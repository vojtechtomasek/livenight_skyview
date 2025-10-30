import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../../routes/app_router.dart';
import 'widgets/sky_view_background.dart';
import 'widgets/sky_view_bottom_bar.dart';
import 'widgets/sky_view_top_bar.dart';

@RoutePage()
class SkyViewScreen extends StatelessWidget {
  const SkyViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0F2C),
              Color(0xFF0E1B47),
            ],
          ),
        ),
        child: Stack(
          children: [
            const SkyViewBackground(),
            SafeArea(
              bottom: false,
              child: SkyViewTopBar(
                onSettingsTap: () {
                  context.router.push(const SettingsRoute());
                },
                onSearchTap: () {
                  // TODO:
                },
              ),
            ),
            const SkyViewBottomBar(),
          ],
        ),
      ),
    );
  }
}