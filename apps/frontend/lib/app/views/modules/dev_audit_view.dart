import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/access_control_service.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../controllers/dashboard_controller.dart';

class DevAuditView extends GetView<DashboardController> {
  const DevAuditView({super.key});

  @override
  Widget build(BuildContext context) {
    final Set<String> activePerms = AccessControlService.to.hasPermission('vehicle:create')
        ? <String>{
            'dashboard:view',
            'vehicle:read', 'vehicle:create', 'vehicle:update', 'vehicle:delete',
            'driver:read', 'driver:create', 'driver:update', 'driver:delete',
            'trip:read', 'trip:create', 'trip:dispatch', 'trip:complete', 'trip:cancel',
            'maintenance:read', 'maintenance:create', 'maintenance:update', 'maintenance:close',
            'fuel:create', 'expense:create', 'report:view', 'report:export',
          }
        : <String>{'dashboard:view', 'trip:read', 'trip:complete', 'fuel:create'};

    final Map<String, String> permDescriptions = <String, String>{
      'dashboard:view': 'Core dashboard visualization page access',
      'vehicle:read': 'Access registered vehicles listing and queries',
      'vehicle:create': 'Permit registration of new fleet inventory',
      'vehicle:update': 'Modify status profiles or routes of vehicles',
      'vehicle:delete': 'Permit removal of vehicle entries',
      'driver:read': 'Access registered drivers directory and details',
      'driver:create': 'Permit registration of new driver profiles',
      'driver:update': 'Modify status profiles or license data of drivers',
      'driver:delete': 'Permit removal of driver entries',
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
      ),
    );
  }
}
