import 'package:flutter/cupertino.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import 'package:livenight_skyview/screens/sky_view/widgets/simple_sky_view.dart';
import '../../routes/app_router.dart';
import '../../services/location_permision_manager.dart';
import '../../services/star_display_service.dart';
import '../../providers/sky_view_provider.dart';
import '../../providers/location_provider.dart';
import '../../models/star.dart';
import '../../models/star_display.dart';
import 'widgets/sky_view_bottom_bar.dart';
import 'widgets/sky_view_top_bar.dart';
import 'widgets/selected_star_banner.dart';
import 'widgets/star_search_widget.dart';

@RoutePage()
class SkyViewScreen extends StatefulWidget {
  const SkyViewScreen({super.key});

  @override
  State<SkyViewScreen> createState() => _SkyViewScreenState();
}

class _SkyViewScreenState extends State<SkyViewScreen> {
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LocationPermissionManager.instance.maybeAskForLocationChoice(context);
    });
  }

  void _showSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _hideSearch() {
    setState(() {
      _isSearching = false;
    });
    FocusScope.of(context).unfocus();
  }

  void _selectSearchResult(Star star) {
    final provider = context.read<SkyViewProvider>();
    
    print('Selected star: ${star.commonName ?? star.mainId ?? 'HIP ${star.hip}'} (mag: ${star.mag})');
    
    // Find the star's current display data to get its azimuth/altitude
    final starDisplayData = _findStarDisplay(star.hip);
    
    provider.selectStar(
      star,
      azimuth: starDisplayData?.azimuth,
      altitude: starDisplayData?.altitude,
    );
    
    _hideSearch();
  }
  
  StarDisplay? _findStarDisplay(int hip) {
    // Access the star display service to find the star's current position
    final locationProvider = context.read<LocationProvider>();
    final stars = StarDisplayService().getDisplayStars(
      latitude: locationProvider.latitude ?? 50.0,
      longitude: locationProvider.longitude ?? 14.0,
      dateTime: DateTime.now().toUtc(),
      maxDisplayMagnitude: 8.5,
    );
    
    try {
      return stars.firstWhere((s) => s.hip == hip);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SkyViewProvider>(
      builder: (context, skyViewProvider, child) {
        return CupertinoPageScaffold(
          child: Stack(
              children: [
                SimpleSkyView(
                  onInteraction: () {
                    if (_isSearching) {
                      _hideSearch();
                    }
                  },
                ),
                
                // Show selected star banner when star is selected and not searching
                if (skyViewProvider.selectedStar != null && !_isSearching)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      bottom: false,
                      child: SelectedStarBanner(
                        star: skyViewProvider.selectedStar!,
                        onClear: () => skyViewProvider.clearSelection(),
                      ),
                    ),
                  ),
                
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: _isSearching
                        ? StarSearchWidget(
                            onClose: _hideSearch,
                            onStarSelected: _selectSearchResult,
                          )
                        : SkyViewTopBar(
                            onSettingsTap: () {
                              context.router.push(const SettingsRoute());
                            },
                            onSearchTap: _showSearch,
                            onToggleTap: () {
                              skyViewProvider.toggleControlMode();
                            },
                            isSensorMode: skyViewProvider.controlMode == ControlMode.sensor,
                          ),
                  ),
                ),
                const SkyViewBottomBar(),
              ],
            ),
      );
      },
    );
  }
}
