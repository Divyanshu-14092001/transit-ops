import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/access_control.dart';
import '../../../core/services/access_control_service.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../controllers/dashboard_controller.dart';
import 'dashboard_helpers.dart';

class DriversView extends GetView<DashboardController> {
  const DriversView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Obx(() => DashboardCard(
            title: 'Registered Driver Directory',
            trailing: AccessControl(
              permission: BackendPermissions.driverAssign,
              child: AppButton(
                label: 'Register Driver',
                icon: Icons.add,
                onPressed: () => _showRegisterDriverDialog(context),
              ),
            ),
            child: controller.driversList.isEmpty
                ? const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('No drivers registered yet.')))
                : SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      dataRowMinHeight: 52,
                      dataRowMaxHeight: 64,
                      columns: const <DataColumn>[
                        DataColumn(label: Text('S.L')),
                        DataColumn(label: Text('Driver Details')),
                        DataColumn(label: Text('License Details')),
                        DataColumn(label: Text('Score & Status')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: List<DataRow>.generate(controller.driversList.length, (int index) {
                        final DriverModel item = controller.driversList[index];
                        Color statusColor;
                        switch (item.status) {
                          case DriverStatus.Available:
                            statusColor = Colors.green;
                            break;
                          case DriverStatus.OnTrip:
                            statusColor = Colors.blue;
                            break;
                          case DriverStatus.OffDuty:
                            statusColor = Colors.orange;
                            break;
                          case DriverStatus.Suspended:
                            statusColor = Colors.red;
                            break;
                        }

                        return DataRow(cells: <DataCell>[
                          DataCell(Text('${index + 1}')),
                          DataCell(Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(item.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text('${item.email} • ${item.contactNumber}', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                            ],
                          )),
                          DataCell(Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('No: ${item.licenseNumber}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 2),
                              Text('Cat: ${item.licenseCategory.name} • Exp: ${item.licenseExpiryDate.year}-${item.licenseExpiryDate.month.toString().padLeft(2, '0')}-${item.licenseExpiryDate.day.toString().padLeft(2, '0')}', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                            ],
                          )),
                          DataCell(Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('Safety Score: ${item.safetyScore.toStringAsFixed(1)}', style: const TextStyle(fontSize: 11)),
                              const SizedBox(height: 2),
                              StatusBadge(
                                status: item.status == DriverStatus.OnTrip ? 'On Trip' : (item.status == DriverStatus.OffDuty ? 'Off Duty' : item.status.name),
                                color: statusColor,
                              ),
                            ],
                          )),
                          DataCell(Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _showEditDriverDialog(context, index)),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                onPressed: () {
                                  controller.driversList.removeAt(index);
                                  showActionSnackbar('Driver profile deleted.');
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

  void _showRegisterDriverDialog(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final GlobalKey<FormState> checkFormKey = GlobalKey<FormState>();
    final GlobalKey<FormState> regFormKey = GlobalKey<FormState>();

    final TextEditingController licenseCheckCtrl = TextEditingController();
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController emailCtrl = TextEditingController();
    final TextEditingController contactCtrl = TextEditingController();
    final TextEditingController expiryCtrl = TextEditingController();
    final TextEditingController scoreCtrl = TextEditingController(text: '90.0');

    final RxBool isChecking = false.obs;
    final RxBool hasChecked = false.obs;
    final RxBool isExisting = false.obs;

    LicenseCategory selectedCategory = LicenseCategory.LMV;
    DriverStatus selectedStatus = DriverStatus.Available;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 365));

    Get.dialog<dynamic>(
      AlertDialog(
        title: Row(children: <Widget>[Icon(Icons.person_add_alt_1_outlined, color: theme.colorScheme.secondary), const SizedBox(width: 12), const Text('Register Driver Profile')]),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Obx(() {
              if (isChecking.value) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text('Checking license database...', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                  ]),
                );
              }

              if (!hasChecked.value) {
                return Form(
                  key: checkFormKey,
                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                    const Text('Step 1: Check License Registration', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Enter the driver\'s license number to verify if their profile exists in our database.', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                    const SizedBox(height: 16),
                    TextFormField(controller: licenseCheckCtrl, decoration: const InputDecoration(labelText: 'Driver License Number', hintText: 'e.g. DL-1420230012345'), validator: (String? v) => v == null || v.trim().isEmpty ? 'Required' : null),
                  ]),
                );
              }

              return Form(
                key: regFormKey,
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  isExisting.value
                      ? Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.withOpacity(0.3))),
                          child: Row(children: <Widget>[const Icon(Icons.check_circle_outline, color: Colors.blue), const SizedBox(width: 12), Expanded(child: Text('License "${licenseCheckCtrl.text.trim()}" found in database. Auto-filling existing driver profile.', style: const TextStyle(fontSize: 11, height: 1.3)))]),
                        )
                      : Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.withOpacity(0.3))),
                          child: Row(children: <Widget>[const Icon(Icons.info_outline, color: Colors.amber), const SizedBox(width: 12), Expanded(child: Text('License "${licenseCheckCtrl.text.trim()}" not found in database. Proceeding with new user registration.', style: const TextStyle(fontSize: 11, height: 1.3)))]),
                        ),
                  const SizedBox(height: 20),
                  Row(children: <Widget>[Icon(Icons.account_box_outlined, size: 18, color: theme.colorScheme.secondary), const SizedBox(width: 8), const Text('1. User Account Registration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]),
                  const Divider(height: 16),
                  TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name'), validator: (String? v) => v == null || v.trim().isEmpty ? 'Required' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address'), validator: (String? v) { if (v == null || v.trim().isEmpty) return 'Required'; if (!GetUtils.isEmail(v.trim())) return 'Invalid email format'; return null; }),
                  const SizedBox(height: 12),
                  TextFormField(controller: contactCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Contact Number'), validator: (String? v) => v == null || v.trim().isEmpty ? 'Required' : null),
                  const SizedBox(height: 24),
                  Row(children: <Widget>[Icon(Icons.badge_outlined, size: 18, color: theme.colorScheme.secondary), const SizedBox(width: 8), const Text('2. Driver Profile Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]),
                  const Divider(height: 16),
                  TextFormField(initialValue: licenseCheckCtrl.text.trim(), enabled: false, decoration: const InputDecoration(labelText: 'Verified License Number')),
                  const SizedBox(height: 12),
                  StatefulBuilder(
                    builder: (BuildContext ctx, StateSetter setState) {
                      return Column(children: <Widget>[
                        DropdownButtonFormField<LicenseCategory>(value: selectedCategory, decoration: const InputDecoration(labelText: 'License Category'), items: LicenseCategory.values.map((LicenseCategory c) => DropdownMenuItem<LicenseCategory>(value: c, child: Text(c.name))).toList(), onChanged: (LicenseCategory? c) { if (c != null) setState(() => selectedCategory = c); }),
                        const SizedBox(height: 12),
                        TextFormField(controller: expiryCtrl, readOnly: true, decoration: const InputDecoration(labelText: 'License Expiry Date', suffixIcon: Icon(Icons.calendar_today)), onTap: () async {
                          final DateTime? date = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 7300)));
                          if (date != null) setState(() { selectedDate = date; expiryCtrl.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'; });
                        }, validator: (String? v) => v == null || v.trim().isEmpty ? 'Required' : null),
                      ]);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(controller: scoreCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Initial Safety Score (0-100)'), validator: (String? v) { if (v == null || v.trim().isEmpty) return 'Required'; final double? s = double.tryParse(v); if (s == null || s < 0 || s > 100) return 'Must be between 0 and 100'; return null; }),
                  const SizedBox(height: 12),
                  StatefulBuilder(builder: (BuildContext ctx, StateSetter setState) => DropdownButtonFormField<DriverStatus>(value: selectedStatus, decoration: const InputDecoration(labelText: 'Initial Availability Status'), items: DriverStatus.values.map((DriverStatus s) => DropdownMenuItem<DriverStatus>(value: s, child: Text(s == DriverStatus.OnTrip ? 'On Trip' : (s == DriverStatus.OffDuty ? 'Off Duty' : s.name)))).toList(), onChanged: (DriverStatus? s) { if (s != null) setState(() => selectedStatus = s); })),
                ]),
              );
            }),
          ),
        ),
        actions: <Widget>[
          Obx(() { if (isChecking.value) return const SizedBox.shrink(); return TextButton(onPressed: () => Get.back<dynamic>(), child: const Text('Cancel')); }),
          Obx(() {
            if (isChecking.value) return const SizedBox.shrink();
            if (!hasChecked.value) {
              return AppButton(label: 'Check License', onPressed: () async {
                if (checkFormKey.currentState?.validate() ?? false) {
                  isChecking.value = true;
                  await Future<void>.delayed(const Duration(milliseconds: 1200));
                  isChecking.value = false;

                  final String cleanLicense = licenseCheckCtrl.text.trim().toLowerCase();
                  final DriverModel? found = controller.driversList.firstWhereOrNull((DriverModel d) => d.licenseNumber.trim().toLowerCase() == cleanLicense);
                  if (found != null) {
                    nameCtrl.text = found.fullName;
                    emailCtrl.text = found.email;
                    contactCtrl.text = found.contactNumber;
                    selectedCategory = found.licenseCategory;
                    selectedDate = found.licenseExpiryDate;
                    expiryCtrl.text = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
                    scoreCtrl.text = found.safetyScore.toStringAsFixed(1);
                    selectedStatus = found.status;
                    isExisting.value = true;
                  } else {
                    nameCtrl.clear();
                    emailCtrl.clear();
                    contactCtrl.clear();
                    expiryCtrl.clear();
                    scoreCtrl.text = '90.0';
                    selectedCategory = LicenseCategory.LMV;
                    selectedStatus = DriverStatus.Available;
                    selectedDate = DateTime.now().add(const Duration(days: 365));
                    isExisting.value = false;
                  }
                  hasChecked.value = true;
                }
              });
            }
            return AppButton(
              label: isExisting.value ? 'Save Driver' : 'Register Driver',
              onPressed: () {
                if (regFormKey.currentState?.validate() ?? false) {
                  final DriverModel driverData = DriverModel(
                    fullName: nameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    contactNumber: contactCtrl.text.trim(),
                    licenseNumber: licenseCheckCtrl.text.trim(),
                    licenseCategory: selectedCategory,
                    licenseExpiryDate: selectedDate,
                    safetyScore: double.parse(scoreCtrl.text.trim()),
                    status: selectedStatus,
                  );
                  if (isExisting.value) {
                    final int idx = controller.driversList.indexWhere((DriverModel d) => d.licenseNumber.trim().toLowerCase() == licenseCheckCtrl.text.trim().toLowerCase());
                    if (idx != -1) {
                      controller.driversList[idx] = driverData;
                    }
                    showActionSnackbar('Driver "${driverData.fullName}" profile updated!');
                  } else {
                    controller.addDriver(driverData);
                    showActionSnackbar('Driver "${driverData.fullName}" registered successfully! Password set to license.');
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

  void _showEditDriverDialog(BuildContext context, int index) {
    final ThemeData theme = Theme.of(context);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final DriverModel current = controller.driversList[index];

    final TextEditingController nameCtrl = TextEditingController(text: current.fullName);
    final TextEditingController emailCtrl = TextEditingController(text: current.email);
    final TextEditingController contactCtrl = TextEditingController(text: current.contactNumber);
    final TextEditingController expiryCtrl = TextEditingController(text: '${current.licenseExpiryDate.year}-${current.licenseExpiryDate.month.toString().padLeft(2, '0')}-${current.licenseExpiryDate.day.toString().padLeft(2, '0')}');
    final TextEditingController scoreCtrl = TextEditingController(text: current.safetyScore.toStringAsFixed(1));

    LicenseCategory selectedCategory = current.licenseCategory;
    DriverStatus selectedStatus = current.status;
    DateTime selectedDate = current.licenseExpiryDate;

    Get.dialog<dynamic>(
      AlertDialog(
        title: Row(children: <Widget>[Icon(Icons.edit_outlined, color: theme.colorScheme.secondary), const SizedBox(width: 12), const Text('Edit Driver Profile')]),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name'), validator: (String? v) => v == null || v.trim().isEmpty ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address'), validator: (String? v) { if (v == null || v.trim().isEmpty) return 'Required'; if (!GetUtils.isEmail(v.trim())) return 'Invalid email format'; return null; }),
                const SizedBox(height: 12),
                TextFormField(controller: contactCtrl, decoration: const InputDecoration(labelText: 'Contact Number'), validator: (String? v) => v == null || v.trim().isEmpty ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(initialValue: current.licenseNumber, enabled: false, decoration: const InputDecoration(labelText: 'License Number (Read-only)')),
                const SizedBox(height: 12),
                StatefulBuilder(
                  builder: (BuildContext ctx, StateSetter setState) {
                    return Column(children: <Widget>[
                      DropdownButtonFormField<LicenseCategory>(value: selectedCategory, decoration: const InputDecoration(labelText: 'License Category'), items: LicenseCategory.values.map((LicenseCategory c) => DropdownMenuItem<LicenseCategory>(value: c, child: Text(c.name))).toList(), onChanged: (LicenseCategory? c) { if (c != null) setState(() => selectedCategory = c); }),
                      const SizedBox(height: 12),
                      TextFormField(controller: expiryCtrl, readOnly: true, decoration: const InputDecoration(labelText: 'License Expiry Date', suffixIcon: Icon(Icons.calendar_today)), onTap: () async {
                        final DateTime? date = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 7300)));
                        if (date != null) setState(() { selectedDate = date; expiryCtrl.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'; });
                      }, validator: (String? v) => v == null || v.trim().isEmpty ? 'Required' : null),
                    ]);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(controller: scoreCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Safety Score (0-100)'), validator: (String? v) { if (v == null || v.trim().isEmpty) return 'Required'; final double? s = double.tryParse(v); if (s == null || s < 0 || s > 100) return 'Must be between 0 and 100'; return null; }),
                const SizedBox(height: 12),
                StatefulBuilder(builder: (BuildContext ctx, StateSetter setState) => DropdownButtonFormField<DriverStatus>(value: selectedStatus, decoration: const InputDecoration(labelText: 'Status'), items: DriverStatus.values.map((DriverStatus s) => DropdownMenuItem<DriverStatus>(value: s, child: Text(s == DriverStatus.OnTrip ? 'On Trip' : (s == DriverStatus.OffDuty ? 'Off Duty' : s.name)))).toList(), onChanged: (DriverStatus? s) { if (s != null) setState(() => selectedStatus = s); })),
              ]),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Get.back<dynamic>(), child: const Text('Cancel')),
          AppButton(label: 'Save Changes', onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              controller.driversList[index] = DriverModel(fullName: nameCtrl.text.trim(), email: emailCtrl.text.trim(), contactNumber: contactCtrl.text.trim(), licenseNumber: current.licenseNumber, licenseCategory: selectedCategory, licenseExpiryDate: selectedDate, safetyScore: double.parse(scoreCtrl.text.trim()), status: selectedStatus);
              Get.back<dynamic>();
              showActionSnackbar('Driver modifications saved successfully!');
            }
          }),
        ],
      ),
    );
  }
}
