import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';

class LocationPermissionManager {
  LocationPermissionManager._();

  static final LocationPermissionManager instance = LocationPermissionManager._();

  Future<void> maybeAskForLocationChoice(BuildContext context) async {
    final locationProvider = context.read<LocationProvider>();

    if (locationProvider.hasUserChoice) {
      if (locationProvider.useCurrentLocation) {
        await locationProvider.fetchCurrentLocation();
      }
      return;
    }

    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Use Current Location?"),
        content: const Text(
          "Do you want the app to use your current GPS position?",
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("No"),
            onPressed: () {
              locationProvider.setUseCurrentLocation(false);
              context.router.maybePop();
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text("Yes"),
            onPressed: () async {
              locationProvider.setUseCurrentLocation(true);

              await locationProvider.fetchCurrentLocation();

              context.router.maybePop();
            },
          ),
        ],
      ),
    );
  }
}
