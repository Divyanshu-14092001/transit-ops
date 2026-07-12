import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../controllers/dashboard_controller.dart';
import 'dashboard_helpers.dart';

class HomeView extends GetView<DashboardController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildFiltersBar(context),
              const SizedBox(height: 20),
              Text(
                'Operational Key Performance Indicators (KPIs)',
                style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
              ),
              const SizedBox(height: 12),
              _buildKPIsGrid(context),
              const SizedBox(height: 24),
              _buildUtilizationChart(context),
            ],
          )),
    );
  }

  Widget _buildFiltersBar(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.filter_list, size: 20, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  'Operations Filters',
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ResponsiveLayout(
              mobile: Column(
                children: <Widget>[
                  _buildFilterDropdown(
                    label: 'Vehicle Type',
                    value: controller.selectedVehicleType.value,
                    items: <String>['All', 'Cargo Trucks', 'Delivery Vans', 'Tippers'],
                    onChanged: (String? val) => controller.updateFilters(type: val),
                  ),
                  const SizedBox(height: 12),
                  _buildFilterDropdown(
                    label: 'Vehicle Status',
                    value: controller.selectedStatus.value,
                    items: <String>['All', 'Active', 'Maintenance', 'Out of Service'],
                    onChanged: (String? val) => controller.updateFilters(status: val),
                  ),
                  const SizedBox(height: 12),
                  _buildFilterDropdown(
                    label: 'Operations Region',
                    value: controller.selectedRegion.value,
                    items: <String>['All', 'West Region', 'North Region', 'South Region', 'East Region'],
                    onChanged: (String? val) => controller.updateFilters(region: val),
                  ),
                ],
              ),
              tablet: Row(
                children: <Widget>[
                  Expanded(
                    child: _buildFilterDropdown(
                      label: 'Vehicle Type',
                      value: controller.selectedVehicleType.value,
                      items: <String>['All', 'Cargo Trucks', 'Delivery Vans', 'Tippers'],
                      onChanged: (String? val) => controller.updateFilters(type: val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFilterDropdown(
                      label: 'Vehicle Status',
                      value: controller.selectedStatus.value,
                      items: <String>['All', 'Active', 'Maintenance', 'Out of Service'],
                      onChanged: (String? val) => controller.updateFilters(status: val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFilterDropdown(
                      label: 'Operations Region',
                      value: controller.selectedRegion.value,
                      items: <String>['All', 'West Region', 'North Region', 'South Region', 'East Region'],
                      onChanged: (String? val) => controller.updateFilters(region: val),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items
          .map((String val) => DropdownMenuItem<String>(
                value: val,
                child: Text(val),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildKPIsGrid(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 1200;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: ResponsiveLayout.isMobile(context)
          ? 2
          : (isSmallScreen ? 2 : 4),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: ResponsiveLayout.isMobile(context)
          ? 2.2
          : (isSmallScreen ? 2.5 : 2.8),
      children: <Widget>[
        StatisticTile(
          label: 'Active Vehicles',
          value: '${controller.activeVehicles.value}',
          icon: Icons.directions_bus_outlined,
          iconColor: theme.colorScheme.secondary,
        ),
        StatisticTile(
          label: 'Available Vehicles',
          value: '${controller.availableVehicles.value}',
          icon: Icons.check_circle_outline,
          iconColor: Colors.teal,
        ),
        StatisticTile(
          label: 'Vehicles in Maintenance',
          value: '${controller.downVehicles.value}',
          icon: Icons.build_outlined,
          iconColor: Colors.orange,
        ),
        StatisticTile(
          label: 'Active Trips',
          value: '${controller.activeTrips.value}',
          icon: Icons.play_arrow_outlined,
          iconColor: Colors.green,
        ),
        StatisticTile(
          label: 'Pending Trips',
          value: '${controller.pendingTrips.value}',
          icon: Icons.pending_actions_outlined,
          iconColor: Colors.blue,
        ),
        StatisticTile(
          label: 'Drivers On Duty',
          value: '${controller.driversOnDuty.value}',
          icon: Icons.people_outline,
          iconColor: Colors.indigo,
        ),
        StatisticTile(
          label: 'Fleet Utilization',
          value: '${controller.fleetUtilization.value.toStringAsFixed(1)}%',
          icon: Icons.pie_chart_outline,
          iconColor: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildUtilizationChart(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DashboardCard(
      title: 'Fleet Utilization Trends',
      trailing: const Icon(Icons.show_chart),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text('Active Allocation Efficiency'),
              Text(
                '${controller.fleetUtilization.value.toStringAsFixed(1)}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: controller.fleetUtilization.value / 100.0,
            backgroundColor: theme.colorScheme.outline.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: controller.utilizationTrends.map((Map<String, dynamic> trend) {
                final String day = trend['day']?.toString() ?? '';
                final double val = double.tryParse(trend['value']?.toString() ?? '') ?? 0.0;
                return _buildBar(context, day: day, value: val);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(BuildContext context, {required String day, required double value}) {
    final ThemeData theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text('${value.toInt()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: 24,
          height: value,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withOpacity(0.8),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 11)),
      ],
    );
  }
}
