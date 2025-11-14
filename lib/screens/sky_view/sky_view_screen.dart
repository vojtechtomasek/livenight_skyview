import 'package:flutter/cupertino.dart';
import 'package:auto_route/auto_route.dart';
import '../../routes/app_router.dart';
import '../object_detail/object_detail_screen.dart';
import 'widgets/sky_view_background.dart';
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
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: GestureDetector(
        onTap: () {
          if (_isSearching) {
            FocusScope.of(context).unfocus();
            _hideSearch();
          }
        },
        child: Stack(
          children: [
            const SkyViewBackground(),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: _isSearching
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: GestureDetector(
                          onTap: () {},
                          child: CupertinoSearchTextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            style: const TextStyle(color: CupertinoColors.white),
                            placeholder: 'Search objects...',
                            placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey),
                            backgroundColor: CupertinoColors.white.withValues(alpha: 0.15),
                            onChanged: (value) {
                              setState(() {});
                            },
                            onSuffixTap: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          ),
                        ),
                      )
                    : SkyViewTopBar(
                        onSettingsTap: () {
                          context.router.push(const SettingsRoute());
                        },
                        onSearchTap: _showSearch,
                      ),
              ),
            ),

            const SkyViewBottomBar(),

            // Tlačítko jako POSLEDNÍ vrstva (nejvyšší z-index)
            Center(
              child: CupertinoButton(
                onPressed: () {
                  showObjectDetailSheet(context);
                },
                color: CupertinoColors.white.withValues(alpha: 0.22),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                borderRadius: BorderRadius.circular(16),
                child: const Text(
                  'Otevřít sheet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}