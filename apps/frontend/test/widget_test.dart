import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:transitops_frontend/app/routes/app_pages.dart';
import 'package:transitops_frontend/app/routes/app_routes.dart';
import 'package:transitops_frontend/main.dart';

void main() {
  testWidgets('App configures GetX Router 2.0 navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(Router<Object>), findsOneWidget);
  });

  test('dashboard module paths are declared as nested routes', () {
    final GetPage<dynamic> dashboard = AppPages.routes.firstWhere(
      (GetPage<dynamic> page) => page.name == AppRoutes.dashboard,
    );
    final Set<String> paths = dashboard.children
        .map((GetPage<dynamic> page) => '${AppRoutes.dashboard}${page.name}')
        .toSet();

    expect(paths, containsAll(<String>[
      AppRoutes.vehicles,
      AppRoutes.drivers,
      AppRoutes.trips,
      AppRoutes.maintenance,
      AppRoutes.expenses,
      AppRoutes.announcements,
      AppRoutes.devAudit,
    ]));
  });
}
