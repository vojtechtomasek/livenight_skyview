import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../providers/location_provider.dart';
import 'dart:async';

class SkyViewTopBar extends StatefulWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onSettingsTap;

  const SkyViewTopBar({
    super.key,
    this.onSearchTap,
    this.onSettingsTap,
  });

  @override
  State<SkyViewTopBar> createState() => _SkyViewTopBarState();
}

class _SkyViewTopBarState extends State<SkyViewTopBar> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();

    // Aktualizace času každou sekundu
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final day = time.day;
    final month = time.month;
    return "$day.$month • $hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    final lat = locationProvider.latitude;
    final lon = locationProvider.longitude;

    String locationText;

    if (lat == null || lon == null) {
      locationText = "Location unavailable";
    } else {
      final ns = lat >= 0 ? "N" : "S";
      final ew = lon >= 0 ? "E" : "W";
      locationText =
          "${lat.toStringAsFixed(2)}°$ns, ${lon.toStringAsFixed(2)}°$ew";
    }

    final timeText = _formatTime(_now);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: CupertinoColors.transparent,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // LEFT SIDE — dynamic location + time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locationText,
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .textStyle
                        .copyWith(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "$timeText • Local",
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .textStyle
                        .copyWith(
                          color: CupertinoColors.systemGrey,
                          fontSize: 14,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // SEARCH
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: widget.onSearchTap,
              child: const Icon(
                CupertinoIcons.search,
                color: CupertinoColors.white,
                size: 24,
              ),
            ),

            // SETTINGS
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: widget.onSettingsTap,
              child: const Icon(
                CupertinoIcons.settings,
                color: CupertinoColors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
