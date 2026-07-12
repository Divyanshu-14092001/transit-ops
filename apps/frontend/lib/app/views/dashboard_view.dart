import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/access_control_service.dart';
import '../../core/widgets/access_control.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/responsive_layout.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDesktop = !ResponsiveLayout.isMobile(context);

    // Sidebar navigation panel
    final Widget sidebar = Container(
      width: 280,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(color: theme.colorScheme.outline, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Sidebar Header / Branding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_shipping_outlined,
                    color: theme.colorScheme.secondary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'TransitOps',
                        style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Smart Logistics Platform',
                        style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 11,
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // User Info Banner
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    radius: 18,
                    child: Text(
                      AuthService.to.username.value?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Obx(() => Text(
                              AuthService.to.username.value ?? 'User Session',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            )),
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

          // Navigation List Items
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                children: <Widget>[
                  _buildSidebarItem(context, label: 'Dashboard', icon: Icons.dashboard_outlined),
                  
                  AccessControl(
                    permission: 'vehicle:read',
                    child: _buildSidebarItem(context, label: 'Vehicles', icon: Icons.directions_bus_outlined),
                  ),
                  
                  AccessControl(
                    permission: 'trip:read',
                    child: _buildSidebarItem(context, label: 'Dispatched Trips', icon: Icons.add_road),
                  ),
                  
                  AccessControl(
                    permission: 'maintenance:read',
                    child: _buildSidebarItem(context, label: 'Maintenance Scheduled', icon: Icons.build_outlined),
                  ),
                  
                  AccessControl(
                    permission: 'expense:create',
                    child: _buildSidebarItem(context, label: 'Expenses & Finance', icon: Icons.account_balance_wallet_outlined),
                  ),
                  
                  _buildSidebarItem(context, label: 'Announcements', icon: Icons.campaign_outlined),
                  
                  _buildSidebarItem(context, label: 'Developer & Audit', icon: Icons.code_outlined),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Logout Button at footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: controller.logout,
              icon: const Icon(Icons.logout_outlined, size: 18),
              label: const Text('Log Out'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
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
                  // Breadcrumb/Header Area
                  _buildWorkspaceHeader(context),
                  const Divider(height: 1),

                  // Dynamic Body Pane
                  Expanded(
                    child: Obx(() => controller.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: _buildDynamicBody(context),
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
    required IconData icon,
  }) {
    final ThemeData theme = Theme.of(context);
    return Obx(() {
      final bool isSelected = controller.selectedModule.value == label;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: InkWell(
          onTap: () {
            controller.selectModule(label);
            if (!ResponsiveLayout.isMobile(context)) {
              // Close drawer if it was open on mobile
            } else {
              Get.back<dynamic>(); // Dismiss mobile drawer
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
                Icon(
                  icon,
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.7),
                  size: 20,
                ),
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
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildWorkspaceHeader(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      controller.selectedModule.value,
                      style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dashboard  >  ${controller.selectedModule.value}  /  Overview',
                      style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                    ),
                  ],
                )),
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: controller.fetchDashboardData,
            tooltip: 'Sync Database',
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicBody(BuildContext context) {
    final String selected = controller.selectedModule.value;
    switch (selected) {
      case 'Vehicles':
        return _buildFleetSection(context);
      case 'Dispatched Trips':
        return _buildTripsSection(context);
      case 'Maintenance Scheduled':
        return _buildMaintenanceSection(context);
      case 'Expenses & Finance':
        return _buildExpensesSection(context);
      case 'Announcements':
        return _buildAnnouncementsSection(context);
      case 'Developer & Audit':
        return _buildDeveloperSection(context);
      case 'Dashboard':
      default:
        return _buildDashboardSection(context);
    }
  }

  // --- Dynamic Modules Render functions ---

  Widget _buildDashboardSection(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Obx(() => Column(
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
        ));
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

  Widget _buildKPIsGrid(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: ResponsiveLayout.isMobile(context) ? 1 : 4,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.5,
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
          // Simple custom bar graph containers
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                _buildBar(context, day: 'Mon', value: 82),
                _buildBar(context, day: 'Tue', value: 80),
                _buildBar(context, day: 'Wed', value: 85),
                _buildBar(context, day: 'Thu', value: 88),
                _buildBar(context, day: 'Fri', value: 83),
                _buildBar(context, day: 'Sat', value: 75),
                _buildBar(context, day: 'Sun', value: 70),
              ],
            ),
          ),
        ],
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

  Widget _buildBar(BuildContext context, {required String day, required double value}) {
    final ThemeData theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          '${value.toInt()}%',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
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
        Text(
          day,
          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildFleetSection(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Obx(() => DashboardCard(
          title: 'Registered Vehicle Inventory',
          trailing: AccessControl(
            permission: 'vehicle:create',
            child: AppButton(
              label: 'Register Vehicle',
              icon: Icons.add,
              onPressed: () => _showRegisterVehicleDialog(context),
            ),
          ),
          child: controller.vehiclesList.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No vehicles registered yet.'),
                  ),
                )
              : SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    dataRowMinHeight: 52,
                    dataRowMaxHeight: 64,
                    columns: const <DataColumn>[
                      DataColumn(label: Text('S.L')),
                      DataColumn(label: Text('Vehicle Details')),
                      DataColumn(label: Text('Identifiers')),
                      DataColumn(label: Text('Specs & Type')),
                      DataColumn(label: Text('Usage & Cost')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: List<DataRow>.generate(controller.vehiclesList.length, (int index) {
                      final VehicleModel item = controller.vehiclesList[index];
                      Color statusColor;
                      switch (item.status) {
                        case VehicleStatus.Available:
                          statusColor = Colors.green;
                          break;
                        case VehicleStatus.OnTrip:
                          statusColor = Colors.blue;
                          break;
                        case VehicleStatus.InShop:
                          statusColor = Colors.orange;
                          break;
                        case VehicleStatus.Retired:
                          statusColor = Colors.grey;
                          break;
                      }

                      String typeString = item.type == VehicleType.MiniTruck ? 'Mini Truck' : (item.type == VehicleType.MiniVan ? 'Mini Van' : item.type.name);
                      String unitString = item.capacityUnit == CapacityUnit.Kg ? 'Kg' : 'Litres';

                      return DataRow(cells: <DataCell>[
                        DataCell(Text('${index + 1}')),
                        // Combined Name & Plate Number
                        DataCell(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(item.number, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                          ],
                        )),
                        // Combined Registration & Chasis
                        DataCell(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('Reg: ${item.registrationNumber}', style: const TextStyle(fontSize: 11)),
                            const SizedBox(height: 2),
                            Text('Chasis: ${item.chasisNumber}', style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: theme.colorScheme.onSurface.withOpacity(0.6))),
                          ],
                        )),
                        // Combined Type & Capacity
                        DataCell(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(typeString, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 2),
                            Text('Cap: ${item.maxLoadCapacity.toStringAsFixed(0)} $unitString', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                          ],
                        )),
                        // Combined Odometer & Cost
                        DataCell(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('${item.odometer.toStringAsFixed(0)} km', style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 2),
                            Text('Cost: ₹${_formatIndianCost(item.acquisitionCost)}', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                          ],
                        )),
                        DataCell(StatusBadge(
                          status: item.status.name == 'OnTrip' ? 'On Trip' : (item.status.name == 'InShop' ? 'In Shop' : item.status.name),
                          color: statusColor,
                        )),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              onPressed: () => _showEditVehicleDialog(context, index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              onPressed: () {
                                controller.vehiclesList.removeAt(index);
                                _showActionSnackbar('Vehicle removed successfully.');
                              },
                            ),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
        ));
  }

  void _showRegisterVehicleDialog(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController numberCtrl = TextEditingController();
    final TextEditingController regCtrl = TextEditingController();
    final TextEditingController chasisCtrl = TextEditingController();
    final TextEditingController capacityCtrl = TextEditingController();
    final TextEditingController odometerCtrl = TextEditingController();
    final TextEditingController costCtrl = TextEditingController();

    VehicleType selectedType = VehicleType.Van;
    CapacityUnit selectedUnit = CapacityUnit.Kg;
    VehicleStatus selectedStatus = VehicleStatus.Available;

    Get.dialog<dynamic>(
      AlertDialog(
        title: Row(
          children: <Widget>[
            Icon(Icons.local_shipping_outlined, color: theme.colorScheme.secondary),
            const SizedBox(width: 12),
            const Text('Register New Vehicle'),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Vehicle Name (e.g. Tata Ace)'),
                    validator: (String? v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: numberCtrl,
                    decoration: const InputDecoration(labelText: 'Vehicle Plate Number'),
                    validator: (String? v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: regCtrl,
                    decoration: const InputDecoration(labelText: 'Registration Number (Unique)'),
                    validator: (String? v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final bool isDuplicate = controller.vehiclesList.any((VehicleModel veh) =>
                          veh.registrationNumber.trim().toLowerCase() == v.trim().toLowerCase());
                      if (isDuplicate) return 'Registration number must be unique';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: chasisCtrl,
                    decoration: const InputDecoration(labelText: 'Chasis Number'),
                    validator: (String? v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Column(
                        children: <Widget>[
                          DropdownButtonFormField<VehicleType>(
                            value: selectedType,
                            decoration: const InputDecoration(labelText: 'Vehicle Type'),
                            items: VehicleType.values
                                .map((VehicleType t) => DropdownMenuItem<VehicleType>(
                                      value: t,
                                      child: Text(t == VehicleType.MiniTruck ? 'Mini Truck' : (t == VehicleType.MiniVan ? 'Mini Van' : t.name)),
                                    ))
                                .toList(),
                            onChanged: (VehicleType? v) {
                              if (v != null) setState(() => selectedType = v);
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: capacityCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Max Load Capacity'),
                                  validator: (String? v) {
                                    if (v == null || v.trim().isEmpty) return 'Required';
                                    if (double.tryParse(v) == null) return 'Must be a number';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<CapacityUnit>(
                                  value: selectedUnit,
                                  decoration: const InputDecoration(labelText: 'Unit'),
                                  items: CapacityUnit.values
                                      .map((CapacityUnit u) => DropdownMenuItem<CapacityUnit>(
                                            value: u,
                                            child: Text(u.name),
                                          ))
                                      .toList(),
                                  onChanged: (CapacityUnit? u) {
                                    if (u != null) setState(() => selectedUnit = u);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: odometerCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Odometer (Current km)',
                              helperText: 'Total cumulative mileage covered (in km)',
                            ),
                            validator: (String? v) {
                              if (v == null || v.trim().isEmpty) return 'Required';
                              if (double.tryParse(v) == null) return 'Must be a number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: costCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                              IndianCurrencyInputFormatter(),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Acquisition Cost',
                              prefixText: '₹ ',
                            ),
                            validator: (String? v) {
                              if (v == null || v.trim().isEmpty) return 'Required';
                              final String cleaned = v.replaceAll(',', '').trim();
                              if (double.tryParse(cleaned) == null) return 'Must be a number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<VehicleStatus>(
                            value: selectedStatus,
                            decoration: const InputDecoration(labelText: 'Status'),
                            items: VehicleStatus.values
                                .map((VehicleStatus s) => DropdownMenuItem<VehicleStatus>(
                                      value: s,
                                      child: Text(s == VehicleStatus.OnTrip ? 'On Trip' : (s == VehicleStatus.InShop ? 'In Shop' : s.name)),
                                    ))
                                .toList(),
                            onChanged: (VehicleStatus? s) {
                              if (s != null) setState(() => selectedStatus = s);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back<dynamic>(),
            child: const Text('Cancel'),
          ),
          AppButton(
            label: 'Register',
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final VehicleModel newVehicle = VehicleModel(
                  name: nameCtrl.text.trim(),
                  number: numberCtrl.text.trim(),
                  registrationNumber: regCtrl.text.trim(),
                  chasisNumber: chasisCtrl.text.trim(),
                  type: selectedType,
                  maxLoadCapacity: double.parse(capacityCtrl.text.trim()),
                  capacityUnit: selectedUnit,
                  odometer: double.parse(odometerCtrl.text.trim()),
                  acquisitionCost: double.parse(costCtrl.text.replaceAll(',', '').trim()),
                  status: selectedStatus,
                );
                controller.addVehicle(newVehicle);
                Get.back<dynamic>();
                _showActionSnackbar('Vehicle registered successfully!');
              }
            },
          ),
        ],
      ),
    );
  }

  void _showEditVehicleDialog(BuildContext context, int index) {
    final ThemeData theme = Theme.of(context);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final VehicleModel current = controller.vehiclesList[index];

    final TextEditingController nameCtrl = TextEditingController(text: current.name);
    final TextEditingController numberCtrl = TextEditingController(text: current.number);
    final TextEditingController regCtrl = TextEditingController(text: current.registrationNumber);
    final TextEditingController chasisCtrl = TextEditingController(text: current.chasisNumber);
    final TextEditingController capacityCtrl = TextEditingController(text: current.maxLoadCapacity.toStringAsFixed(0));
    final TextEditingController odometerCtrl = TextEditingController(text: current.odometer.toStringAsFixed(0));
    final TextEditingController costCtrl = TextEditingController(text: _formatIndianCost(current.acquisitionCost));

    VehicleType selectedType = current.type;
    CapacityUnit selectedUnit = current.capacityUnit;
    VehicleStatus selectedStatus = current.status;

    Get.dialog<dynamic>(
      AlertDialog(
        title: Row(
          children: <Widget>[
            Icon(Icons.edit, color: theme.colorScheme.secondary),
            const SizedBox(width: 12),
            const Text('Edit Vehicle'),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Vehicle Name'),
                    validator: (String? v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: numberCtrl,
                    decoration: const InputDecoration(labelText: 'Vehicle Plate Number'),
                    validator: (String? v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: regCtrl,
                    decoration: const InputDecoration(labelText: 'Registration Number (Unique)'),
                    validator: (String? v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final bool isDuplicate = controller.vehiclesList.asMap().entries.any((MapEntry<int, VehicleModel> entry) =>
                          entry.key != index && entry.value.registrationNumber.trim().toLowerCase() == v.trim().toLowerCase());
                      if (isDuplicate) return 'Registration number must be unique';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: chasisCtrl,
                    decoration: const InputDecoration(labelText: 'Chasis Number'),
                    validator: (String? v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Column(
                        children: <Widget>[
                          DropdownButtonFormField<VehicleType>(
                            value: selectedType,
                            decoration: const InputDecoration(labelText: 'Vehicle Type'),
                            items: VehicleType.values
                                .map((VehicleType t) => DropdownMenuItem<VehicleType>(
                                      value: t,
                                      child: Text(t == VehicleType.MiniTruck ? 'Mini Truck' : (t == VehicleType.MiniVan ? 'Mini Van' : t.name)),
                                    ))
                                .toList(),
                            onChanged: (VehicleType? v) {
                              if (v != null) setState(() => selectedType = v);
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: capacityCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Max Load Capacity'),
                                  validator: (String? v) {
                                    if (v == null || v.trim().isEmpty) return 'Required';
                                    if (double.tryParse(v) == null) return 'Must be a number';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<CapacityUnit>(
                                  value: selectedUnit,
                                  decoration: const InputDecoration(labelText: 'Unit'),
                                  items: CapacityUnit.values
                                      .map((CapacityUnit u) => DropdownMenuItem<CapacityUnit>(
                                            value: u,
                                            child: Text(u.name),
                                          ))
                                      .toList(),
                                  onChanged: (CapacityUnit? u) {
                                    if (u != null) setState(() => selectedUnit = u);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: odometerCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Odometer (Current km)',
                              helperText: 'Total cumulative mileage covered (in km)',
                            ),
                            validator: (String? v) {
                              if (v == null || v.trim().isEmpty) return 'Required';
                              if (double.tryParse(v) == null) return 'Must be a number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: costCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                              IndianCurrencyInputFormatter(),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Acquisition Cost',
                              prefixText: '₹ ',
                            ),
                            validator: (String? v) {
                              if (v == null || v.trim().isEmpty) return 'Required';
                              final String cleaned = v.replaceAll(',', '').trim();
                              if (double.tryParse(cleaned) == null) return 'Must be a number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<VehicleStatus>(
                            value: selectedStatus,
                            decoration: const InputDecoration(labelText: 'Status'),
                            items: VehicleStatus.values
                                .map((VehicleStatus s) => DropdownMenuItem<VehicleStatus>(
                                      value: s,
                                      child: Text(s == VehicleStatus.OnTrip ? 'On Trip' : (s == VehicleStatus.InShop ? 'In Shop' : s.name)),
                                    ))
                                .toList(),
                            onChanged: (VehicleStatus? s) {
                              if (s != null) setState(() => selectedStatus = s);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back<dynamic>(),
            child: const Text('Cancel'),
          ),
          AppButton(
            label: 'Save Changes',
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final VehicleModel updated = VehicleModel(
                  name: nameCtrl.text.trim(),
                  number: numberCtrl.text.trim(),
                  registrationNumber: regCtrl.text.trim(),
                  chasisNumber: chasisCtrl.text.trim(),
                  type: selectedType,
                  maxLoadCapacity: double.parse(capacityCtrl.text.trim()),
                  capacityUnit: selectedUnit,
                  odometer: double.parse(odometerCtrl.text.trim()),
                  acquisitionCost: double.parse(costCtrl.text.replaceAll(',', '').trim()),
                  status: selectedStatus,
                );
                controller.vehiclesList[index] = updated;
                Get.back<dynamic>();
                _showActionSnackbar('Vehicle modifications saved!');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTripsSection(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<Map<String, String>> tripsList = <Map<String, String>>[
      <String, String>{'sl': '1', 'id': 'TR-3092', 'vehicle': 'MH-12-PQ-8901', 'driver': 'John Driver', 'route': 'Pune Expressway', 'status': 'Dispatched'},
      <String, String>{'sl': '2', 'id': 'TR-3093', 'vehicle': 'DL-01-AB-1234', 'driver': 'Vikram Singh', 'route': 'Noida Sector 62', 'status': 'Completed'},
      <String, String>{'sl': '3', 'id': 'TR-3094', 'vehicle': 'TS-09-RT-4321', 'driver': 'Ramesh Kumar', 'route': 'Hyderabad Ring Road', 'status': 'Dispatched'},
    ];

    return DashboardCard(
      title: 'Current dispatch assignments',
      trailing: AccessControl(
        permission: 'trip:create',
        child: AppButton(
          label: 'Dispatch New Trip',
          icon: Icons.add_road,
          onPressed: () => _showActionSnackbar('Trip Dispatch Form Opened'),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const <DataColumn>[
            DataColumn(label: Text('S.L')),
            DataColumn(label: Text('Trip ID')),
            DataColumn(label: Text('Vehicle')),
            DataColumn(label: Text('Driver Name')),
            DataColumn(label: Text('Assigned Route')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Action')),
          ],
          rows: tripsList.map((Map<String, String> item) {
            final Color statusColor = item['status'] == 'Dispatched' ? Colors.blue : theme.colorScheme.secondary;
            return DataRow(cells: <DataCell>[
              DataCell(Text(item['sl']!)),
              DataCell(Text(item['id']!, style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(item['vehicle']!)),
              DataCell(Text(item['driver']!)),
              DataCell(Text(item['route']!)),
              DataCell(StatusBadge(status: item['status']!, color: statusColor)),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(icon: const Icon(Icons.visibility_outlined, size: 18), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.close, size: 18, color: Colors.red), onPressed: () {}),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMaintenanceSection(BuildContext context) {
    final List<Map<String, String>> maintenanceList = <Map<String, String>>[
      <String, String>{'sl': '1', 'vehicle': 'KA-03-XY-5678', 'type': 'Hydraulics Fluid Change', 'date': '2026-07-15', 'status': 'Scheduled'},
      <String, String>{'sl': '2', 'vehicle': 'MH-12-PQ-8901', 'type': 'Tire Rotation & Alignment', 'date': '2026-07-20', 'status': 'Pending'},
    ];

    return DashboardCard(
      title: 'Scheduled maintenance orders',
      trailing: AccessControl(
        permission: 'maintenance:create',
        child: AppButton(
          label: 'Schedule Service',
          icon: Icons.add,
          onPressed: () => _showActionSnackbar('Schedule Service Form Opened'),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const <DataColumn>[
            DataColumn(label: Text('S.L')),
            DataColumn(label: Text('Vehicle')),
            DataColumn(label: Text('Service Type')),
            DataColumn(label: Text('Scheduled Date')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Action')),
          ],
          rows: maintenanceList.map((Map<String, String> item) {
            return DataRow(cells: <DataCell>[
              DataCell(Text(item['sl']!)),
              DataCell(Text(item['vehicle']!, style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(item['type']!)),
              DataCell(Text(item['date']!)),
              DataCell(StatusBadge(status: item['status']!, color: Colors.orange)),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(icon: const Icon(Icons.check, size: 18, color: Colors.green), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.close, size: 18, color: Colors.red), onPressed: () {}),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildExpensesSection(BuildContext context) {
    final List<Map<String, String>> expensesList = <Map<String, String>>[
      <String, String>{'sl': '1', 'date': '2026-07-11', 'type': 'Fuel Log (Truck #45)', 'amount': '₹15,000', 'status': 'Approved'},
      <String, String>{'sl': '2', 'date': '2026-07-10', 'type': 'Brake Overhaul Parts', 'amount': '₹8,240', 'status': 'Approved'},
      <String, String>{'sl': '3', 'date': '2026-07-09', 'type': 'Highway toll recharge', 'amount': '₹5,000', 'status': 'Pending Approval'},
    ];

    return Column(
      children: <Widget>[
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: ResponsiveLayout.isMobile(context) ? 1 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 3.5,
          children: const <Widget>[
            StatisticTile(
              label: 'Total Expenses (This Month)',
              value: '₹28,240',
              icon: Icons.monetization_on_outlined,
              iconColor: Colors.green,
            ),
            StatisticTile(
              label: 'Fuel Cost Metric',
              value: '₹15,000',
              icon: Icons.local_gas_station_outlined,
              iconColor: Colors.amber,
            ),
          ],
        ),
        const SizedBox(height: 24),
        DashboardCard(
          title: 'Recent financial transactions',
          trailing: AccessControl(
            permission: 'fuel:create',
            child: AppButton(
              label: 'Log Fuel/Expense',
              icon: Icons.add,
              onPressed: () => _showActionSnackbar('Log Expense Form Opened'),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const <DataColumn>[
                DataColumn(label: Text('S.L')),
                DataColumn(label: Text('Transaction Date')),
                DataColumn(label: Text('Description')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Status')),
              ],
              rows: expensesList.map((Map<String, String> item) {
                final Color statusColor = item['status'] == 'Approved' ? Colors.green : Colors.orange;
                return DataRow(cells: <DataCell>[
                  DataCell(Text(item['sl']!)),
                  DataCell(Text(item['date']!)),
                  DataCell(Text(item['type']!)),
                  DataCell(Text(item['amount']!, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(StatusBadge(status: item['status']!, color: statusColor)),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementsSection(BuildContext context) {
    final List<Map<String, String>> announcements = <Map<String, String>>[
      <String, String>{
        'title': 'Monsoon safety guidelines on highways',
        'date': '2026-07-12',
        'desc': 'All drivers are requested to maintain speeds under 60km/h on regional highways during heavy downpours. Double distance parameters behind containers.'
      },
      <String, String>{
        'title': 'Depot 04 Toll updates',
        'date': '2026-07-10',
        'desc': 'Fastag configurations for MH registration trucks have been successfully updated in storage. Check your terminal wallet balance before leaving.'
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: announcements.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        announcements[index]['title']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Text(
                      announcements[index]['date']!,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  announcements[index]['desc']!,
                  style: TextStyle(height: 1.4, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeveloperSection(BuildContext context) {
    final Set<String> activePerms = AccessControlService.to.hasPermission('vehicle:create')
        ? <String>{
            'dashboard:view',
            'vehicle:read', 'vehicle:create', 'vehicle:update', 'vehicle:delete',
            'trip:read', 'trip:create', 'trip:dispatch', 'trip:complete', 'trip:cancel',
            'maintenance:read', 'maintenance:create', 'maintenance:update', 'maintenance:close',
            'fuel:create', 'expense:create', 'report:view', 'report:export',
          }
        : <String>{
            'dashboard:view',
            'trip:read', 'trip:complete',
            'fuel:create',
          };

    // Replicate permissions details map for explanation
    final Map<String, String> permDescriptions = <String, String>{
      'dashboard:view': 'Core dashboard visualization page access',
      'vehicle:read': 'Access registered vehicles listing and queries',
      'vehicle:create': 'Permit registration of new fleet inventory',
      'vehicle:update': 'Modify status profiles or routes of vehicles',
      'vehicle:delete': 'Permit removal of vehicle entries',
      'trip:read': 'Read active dispatch routes logs',
      'trip:create': 'Schedule dispatches for drivers and vehicles',
      'trip:dispatch': 'Approve and dispatch outbound shipments',
      'trip:complete': 'Log trip metrics upon final arrival',
      'trip:cancel': 'Cancel pending or interrupted dispatches',
      'maintenance:read': 'Query service schedules and workshop orders',
      'maintenance:create': 'Initiate breakdown or periodic orders',
      'maintenance:update': 'Log parts used or technicians details',
      'maintenance:close': 'Approve maintenance completion and return to active fleet',
      'fuel:create': 'Record gas mileage, fills, and receipts',
      'expense:create': 'Record general operating expenditures',
      'report:view': 'Compile analytical and performance reports',
      'report:export': 'Export database records to PDF/CSV spreadsheets',
    };

    int slCount = 1;

    return DashboardCard(
      title: 'Active Session Permissions (O(1) Memory Engine)',
      trailing: const Icon(Icons.shield_outlined),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const <DataColumn>[
            DataColumn(label: Text('S.L')),
            DataColumn(label: Text('Permission Name')),
            DataColumn(label: Text('Description')),
            DataColumn(label: Text('Resource')),
            DataColumn(label: Text('Action')),
            DataColumn(label: Text('Manage')),
          ],
          rows: activePerms.map((String perm) {
            final List<String> parts = perm.split(':');
            final String resource = parts.length > 0 ? parts[0] : 'general';
            final String action = parts.length > 1 ? parts[1] : 'access';
            final String desc = permDescriptions[perm] ?? 'Assigned access parameter';
            final int currentSl = slCount++;

            return DataRow(cells: <DataCell>[
              DataCell(Text('$currentSl')),
              DataCell(Text(perm, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold))),
              DataCell(Text(desc)),
              DataCell(Text(resource)),
              DataCell(Text(action)),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: () {}),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  String _formatIndianCost(double cost) {
    String cleaned = cost.toStringAsFixed(0);
    if (cleaned.length <= 3) return cleaned;
    String lastThree = cleaned.substring(cleaned.length - 3);
    String rest = cleaned.substring(0, cleaned.length - 3);
    List<String> groups = [];
    int i = rest.length;
    while (i > 0) {
      int start = i - 2;
      if (start < 0) start = 0;
      groups.insert(0, rest.substring(start, i));
      i -= 2;
    }
    return '${groups.join(',')},$lastThree';
  }

  void _showActionSnackbar(String message) {
    Get.snackbar(
      'Operational Event',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0F172A),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }
}

class IndianCurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    // Clean all non-digits
    String cleaned = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
    
    String formatted = _format(cleaned);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
  
  String _format(String cleaned) {
    if (cleaned.length <= 3) return cleaned;
    String lastThree = cleaned.substring(cleaned.length - 3);
    String rest = cleaned.substring(0, cleaned.length - 3);
    
    List<String> groups = [];
    int i = rest.length;
    while (i > 0) {
      int start = i - 2;
      if (start < 0) start = 0;
      groups.insert(0, rest.substring(start, i));
      i -= 2;
    }
    return '${groups.join(',')},$lastThree';
  }
}
