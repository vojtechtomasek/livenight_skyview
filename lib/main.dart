import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'routes/app_router.dart';

import 'providers/conpass_provider.dart';
import 'providers/location_provider.dart';
import 'providers/sky_view_provider.dart';
import 'services/star_catalog_service.dart';
import 'services/constellation_catalog_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load star catalog before app starts
  await StarCatalogService().loadStars(maxMagnitude: 8.5);
  
  // Load constellation catalog after stars are loaded
  await ConstellationCatalogService().loadConstellations();
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CompassProvider()..start()),
        ChangeNotifierProvider(
          create: (_) {
            final provider = LocationProvider();
            provider.loadFromPrefs();
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => SkyViewProvider()),
      ],
      child: CupertinoApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter.config(),
        theme: const CupertinoThemeData(
          brightness: Brightness.dark,
        ),
      ),
    );
  }
}
