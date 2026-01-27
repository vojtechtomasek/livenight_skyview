import 'package:flutter/cupertino.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import 'package:livenight_skyview/screens/sky_view/widgets/simple_sky_view.dart';
import '../../routes/app_router.dart';
import '../../services/location_permision_manager.dart';
import '../../services/star_search_service.dart';
import '../../services/star_display_service.dart';
import '../../services/star_names_service.dart';
import '../../providers/sky_view_provider.dart';
import '../../providers/location_provider.dart';
import '../../models/star.dart';
import '../../models/star_display.dart';
import 'widgets/sky_view_bottom_bar.dart';
import 'widgets/sky_view_top_bar.dart';

@RoutePage()
class SkyViewScreen extends StatefulWidget {
  const SkyViewScreen({super.key});

  @override
  State<SkyViewScreen> createState() => _SkyViewScreenState();
}

class _SkyViewScreenState extends State<SkyViewScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Star> _searchResults = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LocationPermissionManager.instance.maybeAskForLocationChoice(context);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _showSearch() {
    setState(() {
      _isSearching = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
  }

  void _hideSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _searchResults = [];
    });
    FocusScope.of(context).unfocus();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchResults = StarSearchService().searchStars(query);
    });
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
                      child: Container(
                        margin: const EdgeInsets.only(left: 16, right: 16, top: 70, bottom: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.star_fill,
                              color: CupertinoColors.activeBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                skyViewProvider.selectedStar!.commonName ??
                                    skyViewProvider.selectedStar!.mainId ??
                                    'HIP ${skyViewProvider.selectedStar!.hip}',
                                style: const TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => skyViewProvider.clearSelection(),
                              child: const Icon(
                                CupertinoIcons.clear_circled_solid,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ],
                        ),
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
                        ? Column(
                            children: [
                              // Search input
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: CupertinoSearchTextField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                  style: const TextStyle(color: CupertinoColors.white),
                                  placeholder: 'Search: name, HIP number, or ID...',
                                  placeholderStyle: const TextStyle(
                                    color: CupertinoColors.systemGrey,
                                  ),
                                  backgroundColor: CupertinoColors.black.withOpacity(0.3),
                                  onChanged: _onSearchChanged,
                                  onSuffixTap: _hideSearch,
                                ),
                              ),
                              
                              // Search results
                              if (_searchResults.isNotEmpty)
                                Container(
                                  constraints: const BoxConstraints(maxHeight: 300),
                                  color: CupertinoColors.black.withOpacity(0.9),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _searchResults.length,
                                    itemBuilder: (context, index) {
                                      final star = _searchResults[index];
                                      
                                      // Get common name from our database
                                      final commonName = StarNamesService().getNameByHip(star.hip);
                                      
                                      // Build display name: prefer common name, then SIMBAD data, then HIP
                                      final String displayName;
                                      if (commonName != null) {
                                        displayName = '$commonName (HIP ${star.hip})';
                                      } else if (star.commonName != null) {
                                        displayName = '${star.commonName} (HIP ${star.hip})';
                                      } else if (star.mainId != null) {
                                        displayName = '${star.mainId} (HIP ${star.hip})';
                                      } else {
                                        displayName = 'HIP ${star.hip}';
                                      }
                                      
                                      return CupertinoListTile(
                                        title: Text(
                                          displayName,
                                          style: const TextStyle(color: CupertinoColors.white),
                                        ),
                                        subtitle: Text(
                                          'Magnitude: ${star.mag.toStringAsFixed(2)}',
                                          style: const TextStyle(color: CupertinoColors.systemGrey),
                                        ),
                                        trailing: const Icon(
                                          CupertinoIcons.forward,
                                          color: CupertinoColors.systemGrey,
                                        ),
                                        onTap: () => _selectSearchResult(star),
                                      );
                                    },
                                  ),
                                ),
                            ],
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
