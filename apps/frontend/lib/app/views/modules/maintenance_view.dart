import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/access_control.dart';
import '../../../core/services/access_control_service.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../controllers/dashboard_controller.dart';
import 'dashboard_helpers.dart';

class MaintenanceView extends GetView<DashboardController> {
  const MaintenanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> maintenanceList = <Map<String, String>>[
      <String, String>{'sl': '1', 'vehicle': 'KA-03-XY-5678', 'type': 'Hydraulics Fluid Change', 'date': '2026-07-15', 'status': 'Scheduled'},
      <String, String>{'sl': '2', 'vehicle': 'MH-12-PQ-8901', 'type': 'Tire Rotation & Alignment', 'date': '2026-07-20', 'status': 'Pending'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: DashboardCard(
        title: 'Scheduled maintenance orders',
        trailing: AccessControl(
          permission: BackendPermissions.maintenanceCreate,
          child: AppButton(
            label: 'Schedule Service',
            icon: Icons.add,
            onPressed: () => showActionSnackbar('Schedule Service Form Opened'),
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
      ),
    );
  }
}
