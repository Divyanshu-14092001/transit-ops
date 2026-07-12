import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/widgets/access_control.dart';
import '../../../core/services/access_control_service.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../controllers/dashboard_controller.dart';
import 'dashboard_helpers.dart';

class ExpensesView extends GetView<DashboardController> {
  const ExpensesView({super.key});

  String _formatExpenseType(ExpenseType type) {
    return type.name.split('_').map((String word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }

  String _formatExpenseStatus(ExpenseStatus status) {
    return status.name.split('_').map((String word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }

  Color _getStatusColor(ExpenseStatus status) {
    switch (status) {
      case ExpenseStatus.APPROVED:
      case ExpenseStatus.PAID:
        return Colors.green;
      case ExpenseStatus.DRAFT:
      case ExpenseStatus.SUBMITTED:
        return Colors.orange;
      case ExpenseStatus.REJECTED:
      case ExpenseStatus.CANCELLED:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Obx(() {
      final List<ExpenseModel> expenses = controller.expensesList;

      // 1. Calculate stats dynamically
      double totalExpenses = 0.0;
      double totalFuelCost = 0.0;

      for (final ExpenseModel exp in expenses) {
        if (exp.status == ExpenseStatus.APPROVED || exp.status == ExpenseStatus.PAID) {
          totalExpenses += exp.amount;
          if (exp.expenseType == ExpenseType.FUEL) {
            totalFuelCost += exp.amount;
          }
        }
      }

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
              children: <Widget>[
                StatisticTile(
                  label: 'Total Approved Expenses (Month)',
                  value: '₹${formatIndianCost(totalExpenses)}',
                  icon: Icons.monetization_on_outlined,
                  iconColor: Colors.green,
                ),
                StatisticTile(
                  label: 'Total Approved Fuel Cost',
                  value: '₹${formatIndianCost(totalFuelCost)}',
                  icon: Icons.local_gas_station_outlined,
                  iconColor: Colors.amber,
                ),
              ],
            ),
            const SizedBox(height: 24),
            DashboardCard(
              title: 'Recent financial transactions',
              trailing: AccessControl(
                permission: BackendPermissions.expenseCreate,
                child: AppButton(
                  label: 'Log Fuel/Expense',
                  icon: Icons.add,
                  onPressed: () => _showLogDialog(context),
                ),
              ),
              child: expenses.isEmpty
                  ? const EmptyState(
                      title: 'No transactions found',
                      description:
                          'Log your operations fuel refuels or other expenses to track metrics.',
                      icon: Icons.account_balance_wallet_outlined,
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const <DataColumn>[
                          DataColumn(label: Text('S.L')),
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Vehicle / Trip')),
                          DataColumn(label: Text('Expense Type')),
                          DataColumn(label: Text('Description')),
                          DataColumn(label: Text('Amount')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Logged By')),
                          DataColumn(label: Text('Action')),
                        ],
                        rows: List<DataRow>.generate(expenses.length, (int index) {
                          final ExpenseModel item = expenses[index];
                          final Color statusColor = _getStatusColor(item.status);

                          final String vehicleTripStr = <String>[
                            if (item.vehicleNumber != null &&
                                item.vehicleNumber!.isNotEmpty)
                              'Veh: ${item.vehicleNumber}',
                            if (item.tripNumber != null && item.tripNumber!.isNotEmpty)
                              'Trip: ${item.tripNumber}',
                          ].join(' / ');

                          return DataRow(cells: <DataCell>[
                            DataCell(Text('${index + 1}')),
                            DataCell(Text(
                              item.expenseDate.toLocal().toString().substring(0, 10),
                            )),
                            DataCell(Text(
                              vehicleTripStr.isNotEmpty ? vehicleTripStr : '-',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            )),
                            DataCell(Text(_formatExpenseType(item.expenseType))),
                            DataCell(Text(item.description ?? '-')),
                            DataCell(Text(
                              '₹${formatIndianCost(item.amount)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            )),
                            DataCell(StatusBadge(
                              status: _formatExpenseStatus(item.status),
                              color: statusColor,
                            )),
                            DataCell(Text(item.createdBy ?? '-')),
                            DataCell(
                              AccessControl(
                                permission: BackendPermissions.expenseApprove,
                                child: item.status == ExpenseStatus.DRAFT ||
                                        item.status == ExpenseStatus.SUBMITTED
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          IconButton(
                                            icon: const Icon(Icons.check_circle_outline,
                                                color: Colors.green, size: 18),
                                            tooltip: 'Approve',
                                            onPressed: () async {
                                              final bool success = await controller
                                                  .approveExpense(item.id, 'APPROVED');
                                              if (success) {
                                                showActionSnackbar(
                                                    'Transaction approved.');
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.highlight_off,
                                                color: Colors.red, size: 18),
                                            tooltip: 'Reject',
                                            onPressed: () async {
                                              final bool success = await controller
                                                  .approveExpense(item.id, 'REJECTED');
                                              if (success) {
                                                showActionSnackbar(
                                                    'Transaction rejected.');
                                              }
                                            },
                                          ),
                                        ],
                                      )
                                    : const Text('-', style: TextStyle(color: Colors.grey)),
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }

  void _showLogDialog(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    Get.dialog<dynamic>(
      DefaultTabController(
        length: 2,
        child: AlertDialog(
          title: Row(
            children: <Widget>[
              Icon(Icons.monetization_on_outlined,
                  color: theme.colorScheme.secondary),
              const SizedBox(width: 12),
              const Text('Log Financial Transaction'),
            ],
          ),
          content: SizedBox(
            width: 550,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TabBar(
                  labelColor: theme.colorScheme.secondary,
                  unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
                  indicatorColor: theme.colorScheme.secondary,
                  tabs: const <Tab>[
                    Tab(icon: Icon(Icons.receipt_long), text: 'General Expense'),
                    Tab(icon: Icon(Icons.local_gas_station), text: 'Fuel Transaction'),
                  ],
                ),
                const SizedBox(height: 16),
                const Flexible(
                  child: TabBarView(
                    children: <Widget>[
                      _GeneralExpenseForm(),
                      _FuelTransactionForm(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GeneralExpenseForm extends StatefulWidget {
  const _GeneralExpenseForm();

  @override
  State<_GeneralExpenseForm> createState() => _GeneralExpenseFormState();
}

class _GeneralExpenseFormState extends State<_GeneralExpenseForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DashboardController controller = Get.find<DashboardController>();

  VehicleModel? _selectedVehicle;
  TripModel? _selectedTrip;
  ExpenseType _selectedType = ExpenseType.TOLL;

  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _refCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final List<ExpenseType> expenseTypes = ExpenseType.values
        .where((ExpenseType t) => t != ExpenseType.FUEL)
        .toList();

    return Form(
      key: _formKey,
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          DropdownButtonFormField<VehicleModel>(
            value: _selectedVehicle,
            decoration: const InputDecoration(labelText: 'Select Vehicle'),
            items: controller.vehiclesList.map((VehicleModel v) {
              return DropdownMenuItem<VehicleModel>(
                value: v,
                child: Text('${v.name} (${v.number})'),
              );
            }).toList(),
            onChanged: (VehicleModel? val) => setState(() => _selectedVehicle = val),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<TripModel>(
            value: _selectedTrip,
            decoration: const InputDecoration(labelText: 'Link Active Trip'),
            items: controller.tripsList.map((TripModel t) {
              return DropdownMenuItem<TripModel>(
                value: t,
                child: Text('Trip #${t.id} (${t.source} → ${t.destination})'),
              );
            }).toList(),
            onChanged: (TripModel? val) => setState(() => _selectedTrip = val),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: DropdownButtonFormField<ExpenseType>(
                  value: _selectedType,
                  decoration: const InputDecoration(labelText: 'Expense Type *'),
                  items: expenseTypes.map((ExpenseType t) {
                    final String label = t.name.split('_').map((String word) {
                      if (word.isEmpty) return '';
                      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
                    }).join(' ');
                    return DropdownMenuItem<ExpenseType>(
                      value: t,
                      child: Text(label),
                    );
                  }).toList(),
                  onChanged: (ExpenseType? val) {
                    if (val != null) {
                      setState(() => _selectedType = val);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _amountCtrl,
                  decoration: const InputDecoration(labelText: 'Amount (₹) *'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    IndianCurrencyInputFormatter()
                  ],
                  validator: (String? v) =>
                      v == null || v.trim().isEmpty ? 'Amount is required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: _refCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Reference #', hintText: 'e.g. TOLL-89021'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(_selectedDate.toString().substring(0, 10)),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descCtrl,
            decoration: const InputDecoration(
                labelText: 'Description / Purpose',
                hintText: 'Describe details of financial transaction...'),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                onPressed: () => Get.back<dynamic>(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              AppButton(
                label: 'Log Expense',
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final double amountVal =
                        double.parse(_amountCtrl.text.replaceAll(',', ''));

                    final ExpenseModel record = ExpenseModel(
                      id: '',
                      amount: amountVal,
                      currency: 'INR',
                      expenseType: _selectedType,
                      expenseDate: _selectedDate,
                      referenceNumber: _refCtrl.text.trim().isNotEmpty
                          ? _refCtrl.text.trim()
                          : null,
                      description: _descCtrl.text.trim().isNotEmpty
                          ? _descCtrl.text.trim()
                          : null,
                      status: ExpenseStatus.APPROVED, // Automatically approve operational logs
                      vehicleId: _selectedVehicle?.id,
                      tripId: _selectedTrip?.id,
                    );

                    final bool success = await controller.addExpense(record);
                    if (success) {
                      Get.back<dynamic>();
                      showActionSnackbar('Expense transaction logged successfully.');
                    } else {
                      showActionSnackbar('Failed to log expense.');
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FuelTransactionForm extends StatefulWidget {
  const _FuelTransactionForm();

  @override
  State<_FuelTransactionForm> createState() => _FuelTransactionFormState();
}

class _FuelTransactionFormState extends State<_FuelTransactionForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DashboardController controller = Get.find<DashboardController>();

  VehicleModel? _selectedVehicle;
  TripModel? _selectedTrip;
  FuelType _selectedFuelType = FuelType.DIESEL;
  FuelQuantityUnit _selectedUnit = FuelQuantityUnit.LITRE;

  final TextEditingController _qtyCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _totalCtrl = TextEditingController();
  final TextEditingController _odometerCtrl = TextEditingController();
  final TextEditingController _stationCtrl = TextEditingController();
  final TextEditingController _receiptCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  void _calculateTotal() {
    final double qty = double.tryParse(_qtyCtrl.text.replaceAll(',', '')) ?? 0.0;
    final double price = double.tryParse(_priceCtrl.text.replaceAll(',', '')) ?? 0.0;
    if (qty > 0 && price > 0) {
      _totalCtrl.text = (qty * price).toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          DropdownButtonFormField<VehicleModel>(
            value: _selectedVehicle,
            decoration: const InputDecoration(labelText: 'Select Vehicle *'),
            items: controller.vehiclesList.map((VehicleModel v) {
              return DropdownMenuItem<VehicleModel>(
                value: v,
                child: Text('${v.name} (${v.number})'),
              );
            }).toList(),
            onChanged: (VehicleModel? val) {
              if (val != null) {
                setState(() {
                  _selectedVehicle = val;
                  _odometerCtrl.text = val.odometer.toStringAsFixed(0);
                });
              }
            },
            validator: (VehicleModel? val) =>
                val == null ? 'Vehicle is required' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<TripModel>(
            value: _selectedTrip,
            decoration: const InputDecoration(labelText: 'Link Active Trip'),
            items: controller.tripsList.map((TripModel t) {
              return DropdownMenuItem<TripModel>(
                value: t,
                child: Text('Trip #${t.id} (${t.source} → ${t.destination})'),
              );
            }).toList(),
            onChanged: (TripModel? val) => setState(() => _selectedTrip = val),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: DropdownButtonFormField<FuelType>(
                  value: _selectedFuelType,
                  decoration: const InputDecoration(labelText: 'Fuel Type *'),
                  items: FuelType.values.map((FuelType t) {
                    return DropdownMenuItem<FuelType>(
                      value: t,
                      child: Text(
                          '${t.name[0]}${t.name.substring(1).toLowerCase()}'),
                    );
                  }).toList(),
                  onChanged: (FuelType? val) {
                    if (val != null) {
                      setState(() => _selectedFuelType = val);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<FuelQuantityUnit>(
                  value: _selectedUnit,
                  decoration: const InputDecoration(labelText: 'Unit *'),
                  items: FuelQuantityUnit.values.map((FuelQuantityUnit u) {
                    final String label = u == FuelQuantityUnit.LITRE
                        ? 'Litres'
                        : (u == FuelQuantityUnit.KILOGRAM ? 'Kg' : 'kWh');
                    return DropdownMenuItem<FuelQuantityUnit>(
                      value: u,
                      child: Text(label),
                    );
                  }).toList(),
                  onChanged: (FuelQuantityUnit? val) {
                    if (val != null) {
                      setState(() => _selectedUnit = val);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: _qtyCtrl,
                  decoration: const InputDecoration(labelText: 'Quantity *'),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(_calculateTotal),
                  validator: (String? v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _priceCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Price / Unit (₹) *'),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(_calculateTotal),
                  validator: (String? v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: _totalCtrl,
                  decoration: const InputDecoration(labelText: 'Total Cost (₹) *'),
                  keyboardType: TextInputType.number,
                  validator: (String? v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _odometerCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Odometer Reading *'),
                  keyboardType: TextInputType.number,
                  validator: (String? v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: _stationCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Station Name',
                      hintText: 'e.g. Indian Oil, Pune'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _receiptCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Receipt No.', hintText: 'e.g. RC-9021'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text('Fuelled Date *',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(_selectedDate.toString().substring(0, 10)),
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesCtrl,
            decoration: const InputDecoration(
                labelText: 'Notes', hintText: 'Additional comments...'),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                onPressed: () => Get.back<dynamic>(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              AppButton(
                label: 'Log Fuel',
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final double qty =
                        double.parse(_qtyCtrl.text.replaceAll(',', ''));
                    final double price =
                        double.parse(_priceCtrl.text.replaceAll(',', ''));
                    final double total =
                        double.parse(_totalCtrl.text.replaceAll(',', ''));
                    final double odometer =
                        double.parse(_odometerCtrl.text.replaceAll(',', ''));

                    final FuelLogModel record = FuelLogModel(
                      id: '',
                      vehicleId: _selectedVehicle!.id,
                      vehicleNumber: _selectedVehicle!.number,
                      tripId: _selectedTrip?.id,
                      fuelType: _selectedFuelType,
                      quantity: qty,
                      quantityUnit: _selectedUnit,
                      pricePerUnit: price,
                      totalCost: total,
                      fuelledAt: _selectedDate,
                      odometerReading: odometer,
                      fuelStationName: _stationCtrl.text.trim().isNotEmpty
                          ? _stationCtrl.text.trim()
                          : null,
                      receiptNumber: _receiptCtrl.text.trim().isNotEmpty
                          ? _receiptCtrl.text.trim()
                          : null,
                      notes: _notesCtrl.text.trim().isNotEmpty
                          ? _notesCtrl.text.trim()
                          : null,
                    );

                    final bool success = await controller.addFuelLog(record);
                    if (success) {
                      Get.back<dynamic>();
                      showActionSnackbar('Fuel transaction logged successfully.');
                    } else {
                      showActionSnackbar('Failed to log fuel transaction.');
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
