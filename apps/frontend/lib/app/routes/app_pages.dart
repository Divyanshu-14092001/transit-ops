import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_routes.dart';
import '../views/splash_view.dart';
import '../views/login_view.dart';
import '../views/dashboard_view.dart';
import '../views/modules/home_view.dart';
import '../views/modules/vehicles_view.dart';
import '../views/modules/drivers_view.dart';
import '../views/modules/trips_view.dart';
import '../views/modules/maintenance_view.dart';
import '../views/modules/expenses_view.dart';
import '../views/modules/announcements_view.dart';
import '../views/modules/dev_audit_view.dart';
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
      participatesInRootNavigator: true,
    ),
    GetPage<dynamic>(
      name: AppRoutes.login,
      page: () => const LoginView(),
      participatesInRootNavigator: true,
      binding: BindingsBuilder<dynamic>(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage<dynamic>(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      // Keep the dashboard shell in the root navigator. Its children are
      // rendered by the GetRouterOutlet inside DashboardView.
      participatesInRootNavigator: true,
      binding: BindingsBuilder<dynamic>(() {
        Get.lazyPut<DashboardController>(() => DashboardController());
      }),
      middlewares: <GetMiddleware>[AuthGuard()],
      children: <GetPage<dynamic>>[
        // Default sub-route — matched when navigating to /dashboard/home
        GetPage<dynamic>(name: '/home', page: () => const HomeView()),
        GetPage<dynamic>(name: '/vehicles',      page: () => const VehiclesView(),      middlewares: <GetMiddleware>[PermissionGuard(requiredPermission: 'vehicle:read')]),
        GetPage<dynamic>(name: '/drivers',       page: () => const DriversView(),       middlewares: <GetMiddleware>[PermissionGuard(requiredPermission: 'driver:read')]),
        GetPage<dynamic>(name: '/trips',         page: () => const TripsView(),         middlewares: <GetMiddleware>[PermissionGuard(requiredPermission: 'trip:read')]),
        GetPage<dynamic>(name: '/maintenance',   page: () => const MaintenanceView(),   middlewares: <GetMiddleware>[PermissionGuard(requiredPermission: 'maintenance:read')]),
        GetPage<dynamic>(name: '/expenses',      page: () => const ExpensesView()),
        GetPage<dynamic>(name: '/announcements', page: () => const AnnouncementsView()),
        GetPage<dynamic>(name: '/dev-audit',     page: () => const DevAuditView()),
      ],
    ),
    GetPage<dynamic>(
      name: AppRoutes.unauthorized,
      participatesInRootNavigator: true,
      page: () => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.lock_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Access Denied', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('You do not have permission to view this page.'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => AppNavigator.replaceAllNamed<dynamic>(AppRoutes.dashboard),
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
