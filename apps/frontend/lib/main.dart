import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/bindings/initial_binding.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The dashboard uses GetRouterOutlet, which is a Navigator 2.0 widget.
    // Use GetX's Router 2.0 app so the delegate owns the web URL and browser
    // history as well as the visible nested route.
    return GetMaterialApp.router(
      title: 'TransitOps',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      getPages: AppPages.routes,
      routeInformationParser: GetInformationParser(
        initialRoute: AppPages.initial,
      ),
      initialBinding: InitialBinding(),
    );
  }
}
