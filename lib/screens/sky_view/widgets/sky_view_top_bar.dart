import 'package:flutter/cupertino.dart';

class SkyViewTopBar extends StatelessWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onSettingsTap;

  const SkyViewTopBar({
    super.key,
    this.onSearchTap,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: CupertinoColors.transparent,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Praha • 50.08°N, 14.43°E",
                    style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "29 Oct 22:15 • Local",
                    style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                          color: CupertinoColors.systemGrey,
                          fontSize: 14,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onSearchTap,
              child: const Icon(
                CupertinoIcons.search,
                color: CupertinoColors.white,
                size: 24,
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onSettingsTap,
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
