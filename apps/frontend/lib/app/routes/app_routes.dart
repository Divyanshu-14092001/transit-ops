import 'package:get/get.dart';

abstract class AppRoutes {
  AppRoutes._();

  static const String splash        = '/splash';
  static const String login         = '/login';
  static const String dashboard     = '/dashboard';
  static const String unauthorized  = '/unauthorized';

  // Dashboard sub-routes — each maps to a module inside DashboardView
  static const String vehicles      = '/dashboard/vehicles';
  static const String drivers       = '/dashboard/drivers';
  static const String trips         = '/dashboard/trips';
  static const String maintenance   = '/dashboard/maintenance';
  static const String expenses      = '/dashboard/expenses';
  static const String announcements = '/dashboard/announcements';
  static const String devAudit      = '/dashboard/dev-audit';
}

/// Navigation actions which must not leave protected screens in web history.
///
/// `Get.offAllNamed` targets Navigator 1.0. This app uses GetX Router 2.0, so
/// reset the Router 2.0 delegate's history instead.
class AppNavigator {
  AppNavigator._();

  static Future<T> replaceAllNamed<T>(String route) async {
    final GetDelegate delegate = Get.rootDelegate;

    while (delegate.history.length > 1) {
      await delegate.popHistory();
    }

    if (delegate.history.isEmpty) {
      return delegate.toNamed<T>(route);
    }
    return delegate.offNamed<T>(route);
  }
}
