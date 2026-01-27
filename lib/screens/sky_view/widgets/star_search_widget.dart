import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../../../models/star.dart';
import '../../../services/star_search_service.dart';
import '../../../services/star_names_service.dart';

class StarSearchWidget extends StatefulWidget {
  final VoidCallback onClose;
  final Function(Star) onStarSelected;

  const StarSearchWidget({
    super.key,
    required this.onClose,
    required this.onStarSelected,
  });

  @override
  State<StarSearchWidget> createState() => _StarSearchWidgetState();
}

class _StarSearchWidgetState extends State<StarSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Star> _searchResults = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchResults = StarSearchService().searchStars(query);
    });
  }

  void _onStarTap(Star star) {
    widget.onStarSelected(star);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search input
        Padding(
          padding: const EdgeInsets.all(16),
          child: LiquidGlass.withOwnLayer(
            settings: const LiquidGlassSettings(
              blur: 2.0,
              thickness: 3.0,
              refractiveIndex: 1.2,
              glassColor: Color(0x04000000),
              lightIntensity: 1.0,
              ambientStrength: 0.2,
              saturation: 1.0,
            ),
            shape: const LiquidRoundedSuperellipse(
              borderRadius: 16,
            ),
            child: CupertinoSearchTextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontWeight: FontWeight.w500,
              ),
              placeholder: 'Search: name, HIP number, or ID...',
              placeholderStyle: TextStyle(
                color: CupertinoColors.white.withOpacity(0.5),
              ),
              decoration: const BoxDecoration(
                color: CupertinoColors.transparent,
              ),
              onChanged: _onSearchChanged,
              onSuffixTap: widget.onClose,
            ),
          ),
        ),
        
        // Search results
        if (_searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            constraints: const BoxConstraints(maxHeight: 300),
            child: LiquidGlass.withOwnLayer(
              settings: const LiquidGlassSettings(
                blur: 3.0,
                thickness: 4.0,
                refractiveIndex: 1.25,
                glassColor: Color(0x08000000),
                lightIntensity: 1.0,
                ambientStrength: 0.2,
                saturation: 1.0,
              ),
              shape: const LiquidRoundedSuperellipse(
                borderRadius: 16,
              ),
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
                
                return Container(
                  decoration: BoxDecoration(
                    border: index < _searchResults.length - 1
                        ? Border(
                            bottom: BorderSide(
                              color: CupertinoColors.white.withOpacity(0.1),
                              width: 0.5,
                            ),
                          )
                        : null,
                  ),
                  child: CupertinoListTile(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    title: Text(
                      displayName,
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Magnitude: ${star.mag.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: CupertinoColors.white.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.chevron_right,
                        color: CupertinoColors.white.withOpacity(0.8),
                        size: 16,
                      ),
                    ),
                    onTap: () => _onStarTap(star),
                  ),
                );
              },
            ),
            ),
          ),
      ],
    );
  }
}
