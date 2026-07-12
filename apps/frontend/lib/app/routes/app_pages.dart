import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_routes.dart';
import '../views/splash_view.dart';
import '../views/login_view.dart';
import '../views/dashboard_view.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/access_control_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';

class AppPages {
  AppPages._();

  static const String initial = AppRoutes.splash;

  static final List<GetPage<dynamic>> routes = <GetPage<dynamic>>[
    GetPage<dynamic>(
      name: AppRoutes.splash,
      page: () => const SplashView(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: BindingsBuilder<dynamic>(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage<dynamic>(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: BindingsBuilder<dynamic>(() {
        Get.lazyPut<DashboardController>(() => DashboardController());
      }),
      middlewares: <GetMiddleware>[
        AuthGuard(),
      ],
    ),
    GetPage<dynamic>(
      name: AppRoutes.unauthorized,
      page: () => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.lock_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('You do not have permission to view this page.'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.offAllNamed<dynamic>(AppRoutes.dashboard),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    ),
  ];
}

class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return AuthService.to.isLoggedIn.value
        ? null
        : const RouteSettings(name: AppRoutes.login);
  }
}

class PermissionGuard extends GetMiddleware {
  final String requiredPermission;

  PermissionGuard({required this.requiredPermission});

  @override
  RouteSettings? redirect(String? route) {
    if (!AccessControlService.to.hasPermission(requiredPermission)) {
      return const RouteSettings(name: AppRoutes.unauthorized);
    }
    return null;
  }
}
