import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/access_control.dart';
import '../../../core/services/access_control_service.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../controllers/dashboard_controller.dart';
import 'dashboard_helpers.dart';

class TripsView extends GetView<DashboardController> {
  const TripsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Obx(() => DashboardCard(
            title: 'Current Dispatch Assignments',
            trailing: AccessControl(
              permission: BackendPermissions.tripCreate,
              child: AppButton(
                label: 'Dispatch New Trip',
                icon: Icons.add_road,
                onPressed: () => _showDispatchTripDialog(context),
              ),
            ),
            child: controller.tripsList.isEmpty
                ? const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('No trips registered yet.')))
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.tripsList.length,
                    separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
                    itemBuilder: (BuildContext context, int index) {
                      final TripModel item = controller.tripsList[index];
                      return Obx(() {
                        final bool isExpanded = controller.expandedTripId.value == item.id;
                        final ThemeData theme = Theme.of(context);
                        Color statusColor;
                        switch (item.status.value) {
                          case TripStatus.DRAFT:
                            statusColor = Colors.grey;
                            break;
                          case TripStatus.DISPATCHED:
                            statusColor = Colors.blue;
                            break;
                          case TripStatus.COMPLETED:
                            statusColor = Colors.green;
                            break;
                          case TripStatus.CANCELLED:
                            statusColor = Colors.red;
                            break;
                        }

                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
                          ),
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                onTap: () {
                                  controller.expandedTripId.value = isExpanded ? null : item.id;
                                },
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
                                  child: Icon(Icons.local_shipping_outlined, color: statusColor),
                                ),
                                title: Row(children: <Widget>[
                                  Text(item.id, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 12),
                                  StatusBadge(
                                    status: item.status.value == TripStatus.DISPATCHED ? 'Dispatched' : (item.status.value == TripStatus.COMPLETED ? 'Completed' : (item.status.value == TripStatus.CANCELLED ? 'Cancelled' : 'Draft')),
                                    color: statusColor,
                                  ),
                                ]),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    'Route: ${item.source} → ${item.destination}  •  Vehicle: ${item.vehicle.name}  •  Driver: ${item.driver.fullName}',
                                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                                  onPressed: () => controller.expandedTripId.value = isExpanded ? null : item.id,
                                ),
                              ),
                              if (isExpanded) ...<Widget>[
                                const Divider(height: 1),
                                _buildTripLifecycleTimeline(item, context),
                              ],
                            ],
                          ),
                        );
                      });
                    },
                  ),
          )),
    );
  }

  Widget _buildTripLifecycleTimeline(TripModel trip, BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final TripStatusHistory? draftHist = trip.history.firstWhereOrNull((TripStatusHistory h) => h.status == TripStatus.DRAFT);
    final TripStatusHistory? dispHist = trip.history.firstWhereOrNull((TripStatusHistory h) => h.status == TripStatus.DISPATCHED);
    final TripStatusHistory? compHist = trip.history.firstWhereOrNull((TripStatusHistory h) => h.status == TripStatus.COMPLETED);
    final TripStatusHistory? cancHist = trip.history.firstWhereOrNull((TripStatusHistory h) => h.status == TripStatus.CANCELLED);

    final bool isCompleted = trip.status.value == TripStatus.COMPLETED;
    final bool isCancelled = trip.status.value == TripStatus.CANCELLED;

    final List<TimelineNode> nodes = <TimelineNode>[
      TimelineNode(title: isCancelled ? 'Cancelled' : 'Completed', isActive: isCompleted || isCancelled, history: isCancelled ? cancHist : compHist, color: isCancelled ? Colors.red : Colors.green),
      TimelineNode(title: 'Dispatched', isActive: dispHist != null, color: Colors.blue, history: dispHist),
      TimelineNode(title: 'Draft', isActive: draftHist != null, color: Colors.grey, history: draftHist),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: theme.colorScheme.onSurface.withOpacity(0.02), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: <Widget>[
              const Text('Lifecycle Tracking (Bottom to Top Timeline)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  if (trip.status.value == TripStatus.DRAFT)
                    AppButton(
                      label: 'Dispatch Trip',
                      icon: Icons.local_shipping_outlined,
                      onPressed: () {
                        controller.updateTripStatus(trip.id, TripStatus.DISPATCHED);
                        showActionSnackbar('Trip ${trip.id} dispatched!');
                      },
                    ),
                  if (trip.status.value == TripStatus.DISPATCHED) ...<Widget>[
                    AppButton(
                      label: 'Complete Trip',
                      icon: Icons.check,
                      onPressed: () {
                        controller.updateTripStatus(trip.id, TripStatus.COMPLETED);
                        showActionSnackbar('Trip ${trip.id} marked as completed!');
                      },
                    ),
                    TextButton.icon(
                      onPressed: () {
                        controller.updateTripStatus(trip.id, TripStatus.CANCELLED);
                        showActionSnackbar('Trip ${trip.id} cancelled.');
                      },
                      icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
                      label: const Text('Cancel', style: TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: List<Widget>.generate(nodes.length, (int index) {
              final TimelineNode node = nodes[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(children: <Widget>[
                    Container(width: 14, height: 14, decoration: BoxDecoration(shape: BoxShape.circle, color: node.isActive ? node.color : theme.colorScheme.outline.withOpacity(0.3), border: Border.all(color: Colors.white, width: 2))),
                    if (index < nodes.length - 1)
                      Container(width: 2, height: 40, color: nodes[index + 1].isActive ? nodes[index].color : theme.colorScheme.outline.withOpacity(0.2)),
                  ]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      Text(node.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: node.isActive ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.4))),
                      const SizedBox(height: 2),
                      if (node.isActive && node.history != null)
                        Text('Updated by: ${node.history!.changedBy}  •  ${node.history!.timestamp.year}-${node.history!.timestamp.month.toString().padLeft(2, '0')}-${node.history!.timestamp.day.toString().padLeft(2, '0')} ${node.history!.timestamp.hour.toString().padLeft(2, '0')}:${node.history!.timestamp.minute.toString().padLeft(2, '0')}', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.6)))
                      else
                        Text('Pending stage', style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: theme.colorScheme.onSurface.withOpacity(0.4))),
                      const SizedBox(height: 12),
                    ]),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showDispatchTripDialog(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final List<LocationModel> locations = controller.locationsList;
    LocationModel? selectedSourceLoc = locations.isNotEmpty ? locations[0] : null;
    LocationModel? selectedDestinationLoc = locations.length > 1 ? locations[1] : (locations.isNotEmpty ? locations[0] : null);

    final List<VehicleModel> availableVehicles = controller.vehiclesList.where((VehicleModel v) => v.status == VehicleStatus.AVAILABLE).toList();
    final List<DriverModel> availableDrivers = controller.driversList.where((DriverModel d) => d.status == DriverStatus.AVAILABLE && d.licenseExpiryDate.isAfter(DateTime.now())).toList();

    VehicleModel? selectedVehicle = availableVehicles.isNotEmpty ? availableVehicles[0] : null;
    DriverModel? selectedDriver = availableDrivers.isNotEmpty ? availableDrivers[0] : null;

    final TextEditingController weightCtrl = TextEditingController();
    final TextEditingController distanceCtrl = TextEditingController();

    Get.dialog<dynamic>(
      AlertDialog(
        title: Row(children: <Widget>[Icon(Icons.add_road, color: theme.colorScheme.secondary), const SizedBox(width: 12), const Text('Dispatch New Trip')]),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  StatefulBuilder(
                    builder: (BuildContext ctx, StateSetter setState) {
                      return Column(children: <Widget>[
                        DropdownButtonFormField<LocationModel>(
                          value: selectedSourceLoc,
                          decoration: const InputDecoration(labelText: 'Source Location'),
                          items: locations.map((LocationModel l) => DropdownMenuItem<LocationModel>(value: l, child: Text(l.name))).toList(),
                          onChanged: (LocationModel? val) {
                            if (val != null) setState(() => selectedSourceLoc = val);
                          },
                          validator: (LocationModel? val) => val == null ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<LocationModel>(
                          value: selectedDestinationLoc,
                          decoration: const InputDecoration(labelText: 'Destination Location'),
                          items: locations.map((LocationModel l) => DropdownMenuItem<LocationModel>(value: l, child: Text(l.name))).toList(),
                          onChanged: (LocationModel? val) {
                            if (val != null) setState(() => selectedDestinationLoc = val);
                          },
                          validator: (LocationModel? val) => val == null ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<VehicleModel>(
                          value: selectedVehicle,
                          decoration: const InputDecoration(labelText: 'Select Available Vehicle'),
                          items: availableVehicles.map((VehicleModel v) => DropdownMenuItem<VehicleModel>(value: v, child: Text('${v.name} (${v.number})'))).toList(),
                          onChanged: (VehicleModel? val) {
                            if (val != null) setState(() => selectedVehicle = val);
                          },
                          validator: (VehicleModel? val) => val == null ? 'No vehicles available' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<DriverModel>(
                          value: selectedDriver,
                          decoration: const InputDecoration(labelText: 'Select Available Driver'),
                          items: availableDrivers.map((DriverModel d) => DropdownMenuItem<DriverModel>(value: d, child: Text(d.fullName))).toList(),
                          onChanged: (DriverModel? val) {
                            if (val != null) setState(() => selectedDriver = val);
                          },
                          validator: (DriverModel? val) => val == null ? 'No drivers available' : null,
                        ),
                      ]);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: weightCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Cargo Weight (Kg)'),
                    validator: (String? v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final double? w = double.tryParse(v);
                      if (w == null) return 'Must be a number';
                      if (selectedVehicle != null && w > selectedVehicle!.maxLoadCapacity) {
                        return 'Cargo weight exceeds vehicle capacity (${selectedVehicle!.maxLoadCapacity.toInt()} kg)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: distanceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Planned Distance (km)'),
                    validator: (String? v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Must be a number';
                      return null;
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
            label: 'Create Trip',
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                if (selectedVehicle == null || selectedDriver == null || selectedSourceLoc == null || selectedDestinationLoc == null) {
                  showActionSnackbar('Please select available locations, vehicle and driver.');
                  return;
                }
                
                final String generatedTripNum = 'TRIP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                final Map<String, dynamic> tripData = <String, dynamic>{
                  'tripNumber': generatedTripNum,
                  'sourceLocationId': selectedSourceLoc!.id,
                  'destinationLocationId': selectedDestinationLoc!.id,
                  'vehicleId': selectedVehicle!.id,
                  'driverId': selectedDriver!.id,
                  'scheduledStartAt': DateTime.now().toUtc().toIso8601String(),
                  'scheduledEndAt': DateTime.now().add(const Duration(hours: 4)).toUtc().toIso8601String(),
                  'distance': double.parse(distanceCtrl.text.trim()),
                  'distanceUnit': 'KM',
                  'cargoWeight': double.parse(weightCtrl.text.trim()),
                  'notes': 'Created via TransitOps frontend dashboard dialog',
                };

                final bool success = await controller.createTrip(tripData);
                Get.back<dynamic>();
                if (success) {
                  showActionSnackbar('Trip $generatedTripNum created in Draft state!');
                } else {
                  showActionSnackbar('Failed to create trip. Please try again.');
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
