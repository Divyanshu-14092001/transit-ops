import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/widgets/access_control.dart';
import '../../../core/services/access_control_service.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../controllers/dashboard_controller.dart';
import 'dashboard_helpers.dart';

class MaintenanceView extends GetView<DashboardController> {
  const MaintenanceView({super.key});

  String _formatMaintenanceType(MaintenanceType type) {
    return type.name.split('_').map((String word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }

  String _formatMaintenanceStatus(MaintenanceStatus status) {
    return status.name.split('_').map((String word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }

  Color _getStatusColor(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.SCHEDULED:
        return Colors.orange;
      case MaintenanceStatus.IN_PROGRESS:
        return Colors.blue;
      case MaintenanceStatus.COMPLETED:
        return Colors.green;
      case MaintenanceStatus.CANCELLED:
        return Colors.red;
      case MaintenanceStatus.ON_HOLD:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Obx(() {
      final List<MaintenanceModel> maintenanceList = controller.maintenanceList;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: DashboardCard(
          title: 'Scheduled maintenance orders',
          trailing: AccessControl(
            permission: BackendPermissions.maintenanceCreate,
            child: AppButton(
              label: 'Schedule Service',
              icon: Icons.add,
              onPressed: () => _showScheduleServiceDialog(context),
            ),
          ),
          child: maintenanceList.isEmpty
              ? EmptyState(
                  title: 'No maintenance records found',
                  description:
                      'Schedule a maintenance service for your vehicles to keep them operational.',
                  icon: Icons.build_outlined,
                  actionLabel: 'Schedule Service',
                  onActionPressed: () => _showScheduleServiceDialog(context),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const <DataColumn>[
                      DataColumn(label: Text('S.L')),
                      DataColumn(label: Text('Vehicle')),
                      DataColumn(label: Text('Service Type')),
                      DataColumn(label: Text('Scheduled Date')),
                      DataColumn(label: Text('Est / Actual Cost')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Updated By')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: List<DataRow>.generate(maintenanceList.length, (int index) {
                      final MaintenanceModel item = maintenanceList[index];
                      final Color statusColor = _getStatusColor(item.status);

                      final String estCostStr = item.estimatedCost != null
                          ? '₹${formatIndianCost(item.estimatedCost!)}'
                          : '-';
                      final String actCostStr = item.actualCost != null
                          ? '₹${formatIndianCost(item.actualCost!)}'
                          : '-';

                      return DataRow(cells: <DataCell>[
                        DataCell(Text('${index + 1}')),
                        DataCell(Text(
                          item.vehicleNumber,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )),
                        DataCell(Text(_formatMaintenanceType(item.maintenanceType))),
                        DataCell(Text(
                          item.startedAt.toLocal().toString().substring(0, 10),
                        )),
                        DataCell(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('Est: $estCostStr', style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 2),
                            Text('Act: $actCostStr',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurface.withOpacity(0.6))),
                          ],
                        )),
                        DataCell(StatusBadge(
                          status: _formatMaintenanceStatus(item.status),
                          color: statusColor,
                        )),
                        DataCell(Text(item.updatedBy ?? item.createdBy ?? '-')),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            if (item.status == MaintenanceStatus.SCHEDULED) ...<Widget>[
                              IconButton(
                                icon: const Icon(Icons.play_arrow,
                                    size: 18, color: Colors.blue),
                                tooltip: 'Start Service',
                                onPressed: () async {
                                  final bool success = await controller.updateMaintenance(
                                    item.id,
                                    <String, dynamic>{'status': 'IN_PROGRESS'},
                                  );
                                  if (success) {
                                    showActionSnackbar('Maintenance service has started.');
                                  } else {
                                    showActionSnackbar('Failed to start maintenance.');
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel_outlined,
                                    size: 18, color: Colors.red),
                                tooltip: 'Cancel Service',
                                onPressed: () async {
                                  final bool success = await controller.updateMaintenance(
                                    item.id,
                                    <String, dynamic>{'status': 'CANCELLED'},
                                  );
                                  if (success) {
                                    showActionSnackbar('Maintenance service cancelled.');
                                  }
                                },
                              ),
                            ] else if (item.status == MaintenanceStatus.IN_PROGRESS) ...<Widget>[
                              IconButton(
                                icon: const Icon(Icons.check_circle_outline,
                                    size: 18, color: Colors.green),
                                tooltip: 'Complete Service',
                                onPressed: () =>
                                    _showCompleteServiceDialog(context, item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel_outlined,
                                    size: 18, color: Colors.red),
                                tooltip: 'Cancel Service',
                                onPressed: () async {
                                  final bool success = await controller.updateMaintenance(
                                    item.id,
                                    <String, dynamic>{'status': 'CANCELLED'},
                                  );
                                  if (success) {
                                    showActionSnackbar('Maintenance service cancelled.');
                                  }
                                },
                              ),
                            ] else ...<Widget>[
                              const Text('-', style: TextStyle(color: Colors.grey)),
                            ],
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
        ),
      );
    });
  }

  void _showScheduleServiceDialog(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    VehicleModel? selectedVehicle;
    MaintenanceType selectedType = MaintenanceType.ROUTINE_SERVICE;

    final TextEditingController descCtrl = TextEditingController();
    final TextEditingController odometerCtrl = TextEditingController();
    final TextEditingController costCtrl = TextEditingController();
    final TextEditingController providerCtrl = TextEditingController();
    final TextEditingController invoiceCtrl = TextEditingController();
    final TextEditingController notesCtrl = TextEditingController();

    DateTime selectedStartDate = DateTime.now();
    DateTime? selectedExpectedEndDate;

    final RxString startDateText =
        selectedStartDate.toString().substring(0, 10).obs;
    final RxString expectedEndDateText = 'Select Date'.obs;

    // Filter available vehicles or show all vehicles
    final List<VehicleModel> vehicles = controller.vehiclesList;

    Get.dialog<dynamic>(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Row(
              children: <Widget>[
                Icon(Icons.build_outlined, color: theme.colorScheme.secondary),
                const SizedBox(width: 12),
                const Text('Schedule Maintenance Service'),
              ],
            ),
            content: SizedBox(
              width: 550,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      DropdownButtonFormField<VehicleModel>(
                        value: selectedVehicle,
                        decoration:
                            const InputDecoration(labelText: 'Select Vehicle *'),
                        items: vehicles.map((VehicleModel v) {
                          return DropdownMenuItem<VehicleModel>(
                            value: v,
                            child: Text('${v.name} (${v.number})'),
                          );
                        }).toList(),
                        onChanged: (VehicleModel? val) {
                          if (val != null) {
                            setState(() {
                              selectedVehicle = val;
                              odometerCtrl.text = val.odometer.toStringAsFixed(0);
                            });
                          }
                        },
                        validator: (VehicleModel? val) =>
                            val == null ? 'Vehicle is required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<MaintenanceType>(
                        value: selectedType,
                        decoration:
                            const InputDecoration(labelText: 'Maintenance Type *'),
                        items: MaintenanceType.values.map((MaintenanceType t) {
                          return DropdownMenuItem<MaintenanceType>(
                            value: t,
                            child: Text(_formatMaintenanceType(t)),
                          );
                        }).toList(),
                        onChanged: (MaintenanceType? val) {
                          if (val != null) {
                            setState(() {
                              selectedType = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'Describe the maintenance issues...'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: odometerCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Odometer Reading (km)'),
                              keyboardType: TextInputType.number,
                              validator: (String? v) {
                                if (v != null && v.isNotEmpty) {
                                  if (double.tryParse(v) == null) {
                                    return 'Invalid number';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: costCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Estimated Cost (₹)',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                IndianCurrencyInputFormatter()
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: providerCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Service Provider',
                                  hintText: 'e.g. Bosch Service Center'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: invoiceCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Invoice Number',
                                  hintText: 'e.g. INV-1002'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text('Start Date *',
                                    style: TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.calendar_today, size: 16),
                                  label: Obx(() => Text(startDateText.value)),
                                  onPressed: () async {
                                    final DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: selectedStartDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2101),
                                    );
                                    if (picked != null) {
                                      selectedStartDate = picked;
                                      startDateText.value = picked
                                          .toString()
                                          .substring(0, 10);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text('Expected End Date',
                                    style: TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.calendar_today, size: 16),
                                  label: Obx(() => Text(expectedEndDateText.value)),
                                  onPressed: () async {
                                    final DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: selectedExpectedEndDate ??
                                          DateTime.now().add(const Duration(days: 1)),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2101),
                                    );
                                    if (picked != null) {
                                      selectedExpectedEndDate = picked;
                                      expectedEndDateText.value = picked
                                          .toString()
                                          .substring(0, 10);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: notesCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Notes', hintText: 'Additional comments...'),
                        maxLines: 2,
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
                label: 'Schedule',
                onPressed: () async {
                  if (formKey.currentState?.validate() ?? false) {
                    final double? odometerVal =
                        double.tryParse(odometerCtrl.text.replaceAll(',', ''));
                    final double? costVal =
                        double.tryParse(costCtrl.text.replaceAll(',', ''));

                    final MaintenanceModel newRecord = MaintenanceModel(
                      id: '',
                      fleetId: selectedVehicle!.fleetId,
                      vehicleId: selectedVehicle!.id,
                      vehicleNumber: selectedVehicle!.number,
                      maintenanceType: selectedType,
                      description: descCtrl.text.trim().isNotEmpty
                          ? descCtrl.text.trim()
                          : null,
                      status: MaintenanceStatus.SCHEDULED,
                      startedAt: selectedStartDate,
                      expectedCompletionAt: selectedExpectedEndDate,
                      odometerReading: odometerVal,
                      estimatedCost: costVal,
                      serviceProvider: providerCtrl.text.trim().isNotEmpty
                          ? providerCtrl.text.trim()
                          : null,
                      invoiceNumber: invoiceCtrl.text.trim().isNotEmpty
                          ? invoiceCtrl.text.trim()
                          : null,
                      notes: notesCtrl.text.trim().isNotEmpty
                          ? notesCtrl.text.trim()
                          : null,
                    );

                    final bool success = await controller.addMaintenance(newRecord);
                    if (success) {
                      Get.back<dynamic>();
                      showActionSnackbar('Maintenance service scheduled successfully.');
                    } else {
                      showActionSnackbar(
                          'Failed to schedule maintenance. Please try again.');
                    }
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCompleteServiceDialog(BuildContext context, MaintenanceModel item) {
    final ThemeData theme = Theme.of(context);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final TextEditingController actualCostCtrl = TextEditingController();
    final TextEditingController notesCtrl = TextEditingController();

    Get.dialog<dynamic>(
      AlertDialog(
        title: Row(
          children: <Widget>[
            Icon(Icons.check_circle_outline, color: theme.colorScheme.secondary),
            const SizedBox(width: 12),
            const Text('Complete Maintenance Service'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Confirm completion of maintenance service for vehicle ${item.vehicleNumber}.',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: actualCostCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Actual Cost (₹) *',
                    hintText: 'Enter total actual service cost',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    IndianCurrencyInputFormatter()
                  ],
                  validator: (String? v) => v == null || v.trim().isEmpty
                      ? 'Actual cost is required'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Completion Notes',
                    hintText: 'e.g. Repaired engine component successfully.',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back<dynamic>(),
            child: const Text('Cancel'),
          ),
          AppButton(
            label: 'Complete Service',
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final double? actualCostVal =
                    double.tryParse(actualCostCtrl.text.replaceAll(',', ''));

                final Map<String, dynamic> updateData = <String, dynamic>{
                  'status': 'COMPLETED',
                  'actualCost': actualCostVal,
                  'completedAt': DateTime.now().toIso8601String(),
                  if (notesCtrl.text.trim().isNotEmpty) 'notes': notesCtrl.text.trim(),
                };

                final bool success =
                    await controller.updateMaintenance(item.id, updateData);
                if (success) {
                  Get.back<dynamic>();
                  showActionSnackbar('Maintenance service has been completed.');
                } else {
                  showActionSnackbar('Failed to complete maintenance service.');
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
