import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/access_control_service.dart';
import '../../core/widgets/access_control.dart';
import '../../core/widgets/responsive_layout.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDesktop = !ResponsiveLayout.isMobile(context);

    final Widget sidebar = Container(
      width: 280,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(right: BorderSide(color: theme.colorScheme.outline, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Branding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: theme.colorScheme.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.local_shipping_outlined, color: theme.colorScheme.secondary, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('TransitOps', style: theme.textTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Smart Logistics Platform', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // User Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: theme.colorScheme.secondary.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    radius: 18,
                    child: Obx(() => Text(
                          AuthService.to.username.value?.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        )),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Obx(() => Text(AuthService.to.username.value ?? 'User Session', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                        Text(
                          AccessControlService.to.hasPermission('vehicle:create') ? 'Fleet Manager' : 'Driver',
                          style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Navigation Items
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                children: <Widget>[
                  _buildSidebarItem(context, label: 'Dashboard', route: '/dashboard/home', icon: Icons.dashboard_outlined),
                  AccessControl(
                    permission: 'vehicle:read',
                    child: _buildSidebarItem(context, label: 'Vehicles', route: '/dashboard/vehicles', icon: Icons.directions_bus_outlined),
                  ),
                  AccessControl(
                    permission: 'driver:read',
                    child: _buildSidebarItem(context, label: 'Drivers', route: '/dashboard/drivers', icon: Icons.people_outline),
                  ),
                  AccessControl(
                    permission: 'trip:read',
                    child: _buildSidebarItem(context, label: 'Trips', route: '/dashboard/trips', icon: Icons.add_road),
                  ),
                  AccessControl(
                    permission: 'maintenance:read',
                    child: _buildSidebarItem(context, label: 'Maintenance', route: '/dashboard/maintenance', icon: Icons.build_outlined),
                  ),
                  AccessControl(
                    permission: 'expense:create',
                    child: _buildSidebarItem(context, label: 'Expenses & Finance', route: '/dashboard/expenses', icon: Icons.account_balance_wallet_outlined),
                  ),
                  _buildSidebarItem(context, label: 'Announcements', route: '/dashboard/announcements', icon: Icons.campaign_outlined),
                  _buildSidebarItem(context, label: 'Developer & Audit', route: '/dashboard/dev-audit', icon: Icons.code_outlined),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Logout
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: controller.logout,
              icon: const Icon(Icons.logout_outlined, size: 18),
              label: const Text('Log Out'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text('TransitOps'),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
      drawer: isDesktop ? null : Drawer(child: sidebar),
      body: Row(
        children: <Widget>[
          if (isDesktop) sidebar,
          Expanded(
            child: Container(
              color: theme.colorScheme.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildWorkspaceHeader(context),
                  const Divider(height: 1),
                  Expanded(
                    child: Obx(() => controller.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : GetRouterOutlet(
                            initialRoute: '/dashboard/home',
                            anchorRoute: '/dashboard',
                          )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context, {
    required String label,
    required String route,
    required IconData icon,
  }) {
    final ThemeData theme = Theme.of(context);
    return GetRouterOutlet.builder(
      routerDelegate: Get.rootDelegate,
      builder: (BuildContext context, GetDelegate delegate, dynamic currentRoute) {
        final String? location = currentRoute?.location as String?;
        final bool isSelected = location != null && (location == route || location.startsWith('$route/'));
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: InkWell(
            onTap: () {
              delegate.toNamed<dynamic>(route);
              if (ResponsiveLayout.isMobile(context)) {
                Get.back<dynamic>();
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.secondary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: <Widget>[
                  Icon(icon, color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.7), size: 20),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 16, color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.3)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkspaceHeader(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: GetRouterOutlet.builder(
              routerDelegate: Get.rootDelegate,
              builder: (BuildContext context, GetDelegate delegate, dynamic currentRoute) {
                final String? location = currentRoute?.location as String?;
                final String moduleName = _routeToLabel(location ?? '/dashboard');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(moduleName, style: theme.textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Dashboard  >  $moduleName  /  Overview', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                  ],
                );
              },
            ),
          ),
          IconButton(icon: const Icon(Icons.sync), onPressed: controller.fetchDashboardData, tooltip: 'Sync Database'),
        ],
      ),
    );
  }

  String _routeToLabel(String route) {
    const Map<String, String> labels = <String, String>{
      '/dashboard/home':         'Dashboard',
      '/dashboard/vehicles':     'Vehicles',
      '/dashboard/drivers':      'Drivers',
      '/dashboard/trips':        'Trips',
      '/dashboard/maintenance':  'Maintenance',
      '/dashboard/expenses':     'Expenses & Finance',
      '/dashboard/announcements':'Announcements',
      '/dashboard/dev-audit':    'Developer & Audit',
    };
    return labels[route] ?? 'Dashboard';
  }
}
