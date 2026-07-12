import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/access_control.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../controllers/dashboard_controller.dart';
import 'dashboard_helpers.dart';

class ExpensesView extends GetView<DashboardController> {
  const ExpensesView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> expensesList = <Map<String, String>>[
      <String, String>{'sl': '1', 'date': '2026-07-11', 'type': 'Fuel Log (Truck #45)', 'amount': '₹15,000', 'status': 'Approved'},
      <String, String>{'sl': '2', 'date': '2026-07-10', 'type': 'Brake Overhaul Parts', 'amount': '₹8,240', 'status': 'Approved'},
      <String, String>{'sl': '3', 'date': '2026-07-09', 'type': 'Highway toll recharge', 'amount': '₹5,000', 'status': 'Pending Approval'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: ResponsiveLayout.isMobile(context) ? 1 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3.5,
            children: const <Widget>[
              StatisticTile(label: 'Total Expenses (This Month)', value: '₹28,240', icon: Icons.monetization_on_outlined, iconColor: Colors.green),
              StatisticTile(label: 'Fuel Cost Metric', value: '₹15,000', icon: Icons.local_gas_station_outlined, iconColor: Colors.amber),
            ],
          ),
          const SizedBox(height: 24),
          DashboardCard(
            title: 'Recent financial transactions',
            trailing: AccessControl(
              permission: 'fuel:create',
              child: AppButton(label: 'Log Fuel/Expense', icon: Icons.add, onPressed: () => showActionSnackbar('Log Expense Form Opened')),
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
      ),
    );
  }
}
