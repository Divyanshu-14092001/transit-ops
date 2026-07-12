import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/widgets/access_control.dart';
import '../../../core/services/access_control_service.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../controllers/dashboard_controller.dart';
import 'dashboard_helpers.dart';

class VehiclesView extends GetView<DashboardController> {
  const VehiclesView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Obx(() => DashboardCard(
            title: 'Registered Vehicle Inventory',
            trailing: AccessControl(
              permission: BackendPermissions.fleetCreate,
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

                        String typeString = item.type == VehicleType.MiniTruck
                            ? 'Mini Truck'
                            : (item.type == VehicleType.MiniVan ? 'Mini Van' : item.type.name);
                        String unitString = item.capacityUnit == CapacityUnit.Kg ? 'Kg' : 'Litres';

                        return DataRow(cells: <DataCell>[
                          DataCell(Text('${index + 1}')),
                          DataCell(Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(item.number, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                            ],
                          )),
                          DataCell(Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('Reg: ${item.registrationNumber}', style: const TextStyle(fontSize: 11)),
                              const SizedBox(height: 2),
                              Text('Chasis: ${item.chasisNumber}', style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: theme.colorScheme.onSurface.withOpacity(0.6))),
                            ],
                          )),
                          DataCell(Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(typeString, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 2),
                              Text('Cap: ${item.maxLoadCapacity.toStringAsFixed(0)} $unitString', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                            ],
                          )),
                          DataCell(Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('${item.odometer.toStringAsFixed(0)} km', style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 2),
                              Text('Cost: ₹${formatIndianCost(item.acquisitionCost)}', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6))),
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
                                  showActionSnackbar('Vehicle removed successfully.');
                                },
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
          )),
    );
  }

  void _showRegisterVehicleDialog(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final GlobalKey<FormState> checkFormKey = GlobalKey<FormState>();
    final GlobalKey<FormState> regFormKey = GlobalKey<FormState>();

    final TextEditingController regCheckCtrl = TextEditingController();
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController numberCtrl = TextEditingController();
    final TextEditingController chasisCtrl = TextEditingController();
    final TextEditingController capacityCtrl = TextEditingController();
    final TextEditingController odometerCtrl = TextEditingController();
    final TextEditingController costCtrl = TextEditingController();

    final RxBool isChecking = false.obs;
    final RxBool hasChecked = false.obs;
    final RxBool isExisting = false.obs;

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
            child: Obx(() {
              if (isChecking.value) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text('Checking database...', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                    ],
                  ),
                );
              }

              if (!hasChecked.value) {
                return Form(
                  key: checkFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('Step 1: Check Vehicle Registration', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Enter the vehicle\'s registration number to verify if it exists in our database.', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: regCheckCtrl,
                        decoration: const InputDecoration(labelText: 'Vehicle Registration Number', hintText: 'e.g. REG-8901'),
                        validator: (String? v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ],
                  ),
                );
              }

              return Form(
                key: regFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    isExisting.value
                        ? Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.withOpacity(0.3))),
                            child: Row(children: <Widget>[const Icon(Icons.check_circle_outline, color: Colors.blue), const SizedBox(width: 12), Expanded(child: Text('Registration "${regCheckCtrl.text.trim()}" found in database. Auto-filling existing vehicle details.', style: const TextStyle(fontSize: 11, height: 1.3)))]),
                          )
                        : Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: <Widget>[
                                const Icon(Icons.info_outline, color: Colors.amber),
                                const SizedBox(width: 12),
                                Expanded(child: Text('Registration "${regCheckCtrl.text.trim()}" not found in database. Proceeding with new vehicle registration.', style: const TextStyle(fontSize: 11, height: 1.3))),
                              ],
                            ),
                          ),
                    const SizedBox(height: 20),
                    TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Vehicle Name (e.g. Tata Ace)'), validator: (String? v) => v == null || v.trim().isEmpty ? 'Required' : null),
                    const SizedBox(height: 12),
                    TextFormField(controller: numberCtrl, decoration: const InputDecoration(labelText: 'Vehicle Plate Number'), validator: (String? v) => v == null || v.trim().isEmpty ? 'Required' : null),
                    const SizedBox(height: 12),
                    TextFormField(initialValue: regCheckCtrl.text.trim(), enabled: false, decoration: const InputDecoration(labelText: 'Verified Registration Number')),
                    const SizedBox(height: 12),
                    TextFormField(controller: chasisCtrl, decoration: const InputDecoration(labelText: 'Chasis Number'), validator: (String? v) => v == null || v.trim().isEmpty ? 'Required' : null),
                    const SizedBox(height: 12),
                    StatefulBuilder(
                      builder: (BuildContext ctx, StateSetter setState) {
                        return Column(
                          children: <Widget>[
                            DropdownButtonFormField<VehicleType>(
                              value: selectedType,
                              decoration: const InputDecoration(labelText: 'Vehicle Type'),
                              items: VehicleType.values.map((VehicleType t) => DropdownMenuItem<VehicleType>(value: t, child: Text(t == VehicleType.MiniTruck ? 'Mini Truck' : (t == VehicleType.MiniVan ? 'Mini Van' : t.name)))).toList(),
                              onChanged: (VehicleType? v) { if (v != null) setState(() => selectedType = v); },
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: <Widget>[
                                Expanded(flex: 2, child: TextFormField(controller: capacityCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Max Load Capacity'), validator: (String? v) { if (v == null || v.trim().isEmpty) return 'Required'; if (double.tryParse(v) == null) return 'Must be a number'; return null; })),
                                const SizedBox(width: 12),
                                Expanded(child: DropdownButtonFormField<CapacityUnit>(value: selectedUnit, decoration: const InputDecoration(labelText: 'Unit'), items: CapacityUnit.values.map((CapacityUnit u) => DropdownMenuItem<CapacityUnit>(value: u, child: Text(u.name))).toList(), onChanged: (CapacityUnit? u) { if (u != null) setState(() => selectedUnit = u); })),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(controller: odometerCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Odometer (Current km)', helperText: 'Total cumulative mileage covered (in km)'), validator: (String? v) { if (v == null || v.trim().isEmpty) return 'Required'; if (double.tryParse(v) == null) return 'Must be a number'; return null; }),
                            const SizedBox(height: 12),
                            TextFormField(controller: costCtrl, keyboardType: TextInputType.number, inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, IndianCurrencyInputFormatter()], decoration: const InputDecoration(labelText: 'Acquisition Cost', prefixText: '₹ '), validator: (String? v) { if (v == null || v.trim().isEmpty) return 'Required'; if (double.tryParse(v.replaceAll(',', '').trim()) == null) return 'Must be a number'; return null; }),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<VehicleStatus>(value: selectedStatus, decoration: const InputDecoration(labelText: 'Status'), items: VehicleStatus.values.map((VehicleStatus s) => DropdownMenuItem<VehicleStatus>(value: s, child: Text(s == VehicleStatus.OnTrip ? 'On Trip' : (s == VehicleStatus.InShop ? 'In Shop' : s.name)))).toList(), onChanged: (VehicleStatus? s) { if (s != null) setState(() => selectedStatus = s); }),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        actions: <Widget>[
          Obx(() {
            if (isChecking.value) return const SizedBox.shrink();
            return TextButton(onPressed: () => Get.back<dynamic>(), child: const Text('Cancel'));
          }),
          Obx(() {
            if (isChecking.value) return const SizedBox.shrink();
            if (!hasChecked.value) {
              return AppButton(
                label: 'Check Registration',
                onPressed: () async {
                  if (checkFormKey.currentState?.validate() ?? false) {
                    isChecking.value = true;
                    await Future<void>.delayed(const Duration(milliseconds: 1200));
                    isChecking.value = false;

                    final String cleanReg = regCheckCtrl.text.trim().toLowerCase();
                    final VehicleModel? found = controller.vehiclesList.firstWhereOrNull((VehicleModel v) => v.registrationNumber.trim().toLowerCase() == cleanReg);
                    if (found != null) {
                      nameCtrl.text = found.name;
                      numberCtrl.text = found.number;
                      chasisCtrl.text = found.chasisNumber;
                      selectedType = found.type;
                      capacityCtrl.text = found.maxLoadCapacity.toStringAsFixed(0);
                      selectedUnit = found.capacityUnit;
                      odometerCtrl.text = found.odometer.toStringAsFixed(0);
                      costCtrl.text = formatIndianCost(found.acquisitionCost);
                      selectedStatus = found.status;
                      isExisting.value = true;
                    } else {
                      nameCtrl.clear();
                      numberCtrl.clear();
                      chasisCtrl.clear();
                      capacityCtrl.clear();
                      odometerCtrl.clear();
                      costCtrl.clear();
                      selectedType = VehicleType.Van;
                      selectedUnit = CapacityUnit.Kg;
                      selectedStatus = VehicleStatus.Available;
                      isExisting.value = false;
                    }
                    hasChecked.value = true;
                  }
                },
              );
            }
            return AppButton(
              label: isExisting.value ? 'Save Vehicle' : 'Register',
              onPressed: () {
                if (regFormKey.currentState?.validate() ?? false) {
                  final VehicleModel vehicleData = VehicleModel(
                    name: nameCtrl.text.trim(),
                    number: numberCtrl.text.trim(),
                    registrationNumber: regCheckCtrl.text.trim(),
                    chasisNumber: chasisCtrl.text.trim(),
                    type: selectedType,
                    maxLoadCapacity: double.parse(capacityCtrl.text.trim()),
                    capacityUnit: selectedUnit,
                    odometer: double.parse(odometerCtrl.text.trim()),
                    acquisitionCost: double.parse(costCtrl.text.replaceAll(',', '').trim()),
                    status: selectedStatus,
                  );
                  if (isExisting.value) {
                    final int idx = controller.vehiclesList.indexWhere((VehicleModel v) => v.registrationNumber.trim().toLowerCase() == regCheckCtrl.text.trim().toLowerCase());
                    if (idx != -1) {
                      controller.vehiclesList[idx] = vehicleData;
                    }
                    showActionSnackbar('Vehicle details updated successfully!');
                  } else {
                    controller.addVehicle(vehicleData);
                    showActionSnackbar('Vehicle registered successfully!');
                  }
                  Get.back<dynamic>();
                }
              },
            );
          }),
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
    final TextEditingController costCtrl = TextEditingController(text: formatIndianCost(current.acquisitionCost));

    VehicleType selectedType = current.type;
    CapacityUnit selectedUnit = current.capacityUnit;
    VehicleStatus selectedStatus = current.status;

    Get.dialog<dynamic>(
      AlertDialog(
        title: Row(children: <Widget>[Icon(Icons.edit, color: theme.colorScheme.secondary), const SizedBox(width: 12), const Text('Edit Vehicle')]),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Vehicle Name'), validator: (String? v) => v == null || v.trim().isEmpty ? 'Required' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: numberCtrl, decoration: const InputDecoration(labelText: 'Vehicle Plate Number'), validator: (String? v) => v == null || v.trim().isEmpty ? 'Required' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: regCtrl, decoration: const InputDecoration(labelText: 'Registration Number (Unique)'), validator: (String? v) { if (v == null || v.trim().isEmpty) return 'Required'; final bool isDuplicate = controller.vehiclesList.asMap().entries.any((MapEntry<int, VehicleModel> e) => e.key != index && e.value.registrationNumber.trim().toLowerCase() == v.trim().toLowerCase()); if (isDuplicate) return 'Registration number must be unique'; return null; }),
                  const SizedBox(height: 12),
                  TextFormField(controller: chasisCtrl, decoration: const InputDecoration(labelText: 'Chasis Number'), validator: (String? v) => v == null || v.trim().isEmpty ? 'Required' : null),
                  const SizedBox(height: 12),
                  StatefulBuilder(
                    builder: (BuildContext ctx, StateSetter setState) {
                      return Column(
                        children: <Widget>[
                          DropdownButtonFormField<VehicleType>(value: selectedType, decoration: const InputDecoration(labelText: 'Vehicle Type'), items: VehicleType.values.map((VehicleType t) => DropdownMenuItem<VehicleType>(value: t, child: Text(t == VehicleType.MiniTruck ? 'Mini Truck' : (t == VehicleType.MiniVan ? 'Mini Van' : t.name)))).toList(), onChanged: (VehicleType? v) { if (v != null) setState(() => selectedType = v); }),
                          const SizedBox(height: 12),
                          Row(children: <Widget>[
                            Expanded(flex: 2, child: TextFormField(controller: capacityCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Max Load Capacity'), validator: (String? v) { if (v == null || v.trim().isEmpty) return 'Required'; if (double.tryParse(v) == null) return 'Must be a number'; return null; })),
                            const SizedBox(width: 12),
                            Expanded(child: DropdownButtonFormField<CapacityUnit>(value: selectedUnit, decoration: const InputDecoration(labelText: 'Unit'), items: CapacityUnit.values.map((CapacityUnit u) => DropdownMenuItem<CapacityUnit>(value: u, child: Text(u.name))).toList(), onChanged: (CapacityUnit? u) { if (u != null) setState(() => selectedUnit = u); })),
                          ]),
                          const SizedBox(height: 12),
                          TextFormField(controller: odometerCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Odometer (Current km)', helperText: 'Total cumulative mileage covered (in km)'), validator: (String? v) { if (v == null || v.trim().isEmpty) return 'Required'; if (double.tryParse(v) == null) return 'Must be a number'; return null; }),
                          const SizedBox(height: 12),
                          TextFormField(controller: costCtrl, keyboardType: TextInputType.number, inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, IndianCurrencyInputFormatter()], decoration: const InputDecoration(labelText: 'Acquisition Cost', prefixText: '₹ '), validator: (String? v) { if (v == null || v.trim().isEmpty) return 'Required'; if (double.tryParse(v.replaceAll(',', '').trim()) == null) return 'Must be a number'; return null; }),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<VehicleStatus>(value: selectedStatus, decoration: const InputDecoration(labelText: 'Status'), items: VehicleStatus.values.map((VehicleStatus s) => DropdownMenuItem<VehicleStatus>(value: s, child: Text(s == VehicleStatus.OnTrip ? 'On Trip' : (s == VehicleStatus.InShop ? 'In Shop' : s.name)))).toList(), onChanged: (VehicleStatus? s) { if (s != null) setState(() => selectedStatus = s); }),
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
          TextButton(onPressed: () => Get.back<dynamic>(), child: const Text('Cancel')),
          AppButton(
            label: 'Save Changes',
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                controller.vehiclesList[index] = VehicleModel(
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
                Get.back<dynamic>();
                showActionSnackbar('Vehicle modifications saved!');
              }
            },
          ),
        ],
      ),
    );
  }
}
