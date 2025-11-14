import 'package:auto_route/annotations.dart';
import 'package:flutter/cupertino.dart';

@RoutePage()
class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a237e), // tmavě modrá
              Color(0xFF0d1a4a), // ještě tmavší modrá
            ],
          ),
        ),
        child: Center(
          child: Image.asset(
            'lib/assets/images/logo.png',
            width: 350,
            height: 350,
          ),
        ),
      ),
    );
  }
}
