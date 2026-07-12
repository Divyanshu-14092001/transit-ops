import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../../core/services/auth_service.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Standard boot load time
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    if (AuthService.to.isLoggedIn.value) {
      Get.offAllNamed<dynamic>(AppRoutes.dashboard);
    } else {
      Get.offAllNamed<dynamic>(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.local_shipping_outlined,
              size: 72,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(height: 24),
            Text(
              'TransitOps',
              style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 28,
                    letterSpacing: 1.2,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Smart Transport Operations Platform',
              style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 140,
              child: LinearProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
