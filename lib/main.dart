import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'providers/conpass_provider.dart';
import 'routes/app_router.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CompassProvider()..start(),
        ),
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
