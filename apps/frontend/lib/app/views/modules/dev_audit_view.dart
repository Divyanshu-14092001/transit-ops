import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/access_control_service.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../controllers/dashboard_controller.dart';

class DevAuditView extends GetView<DashboardController> {
  const DevAuditView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> activePerms = AccessControlService.to.permissions.toList()
      ..sort();

    final Map<String, String> permDescriptions = <String, String>{
      BackendPermissions.authRead: 'Read auth configuration',
      BackendPermissions.authManage: 'Manage authentication',
      BackendPermissions.organizationCreate: 'Create organizations',
      BackendPermissions.organizationRead: 'Read organizations',
      BackendPermissions.organizationUpdate: 'Update organizations',
      BackendPermissions.fleetCreate: 'Create fleets',
      BackendPermissions.fleetRead: 'Read fleets',
      BackendPermissions.fleetUpdate: 'Update fleets',
      BackendPermissions.fleetDelete: 'Delete fleets',
      BackendPermissions.driverAssign: 'Assign drivers',
      BackendPermissions.tripCreate: 'Create trips',
      BackendPermissions.tripAssign: 'Assign trips',
      BackendPermissions.tripUpdate: 'Update trips',
      BackendPermissions.maintenanceCreate: 'Create maintenance records',
      BackendPermissions.fuelCreate: 'Log fuel records',
      BackendPermissions.expenseCreate: 'Log expenses',
      BackendPermissions.expenseApprove: 'Approve expenses',
      BackendPermissions.reportRead: 'Read reports',
      BackendPermissions.reportExport: 'Export reports',
    };

    int slCount = 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: DashboardCard(
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
              final String resource = parts.isNotEmpty ? parts[0] : 'general';
              final String action = parts.length > 1 ? parts[1] : 'access';
              final String desc = permDescriptions[perm] ?? 'Assigned access parameter';
              final int currentSl = slCount++;

              return DataRow(cells: <DataCell>[
                DataCell(Text('$currentSl')),
                DataCell(Text(perm, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold))),
                DataCell(Text(desc)),
                DataCell(Text(resource)),
                DataCell(Text(action)),
                const DataCell(Icon(Icons.verified_outlined, size: 18)),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
