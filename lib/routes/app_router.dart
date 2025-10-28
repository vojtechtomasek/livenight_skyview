import 'package:auto_route/auto_route.dart';
import '../screens/sky_view/sky_view_screen.dart';
import '../screens/object_detail/object_detail_screen.dart';
import '../screens/settings/settings_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SkyViewRoute.page, initial: true),
    AutoRoute(page: ObjectDetailRoute.page),
    AutoRoute(page: SettingsRoute.page),
  ];
}