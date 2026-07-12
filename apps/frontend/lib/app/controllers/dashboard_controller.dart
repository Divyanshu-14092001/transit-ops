import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../../core/services/auth_service.dart';

class DashboardController extends GetxController {
  final RxBool isLoading = false.obs;

  // Mocked stats
  final RxInt activeVehicles = 0.obs;
  final RxInt downVehicles = 0.obs;
  final RxInt pendingTrips = 0.obs;
  final RxDouble operatingCost = 0.0.obs;
  final RxList<String> recentActivities = <String>[].obs;

  final RxString selectedModule = 'Dashboard'.obs;

  // Additional KPIs
  final RxInt availableVehicles = 0.obs;
  final RxInt activeTrips = 0.obs;
  final RxInt driversOnDuty = 0.obs;
  final RxDouble fleetUtilization = 0.0.obs;

  // Filter Selections
  final RxString selectedVehicleType = 'All'.obs;
  final RxString selectedStatus = 'All'.obs;
  final RxString selectedRegion = 'All'.obs;

  // Reactive Vehicles List
  final RxList<VehicleModel> vehiclesList = <VehicleModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  void selectModule(String module) {
    selectedModule.value = module;
  }

  void updateFilters({String? type, String? status, String? region}) {
    if (type != null) selectedVehicleType.value = type;
    if (status != null) selectedStatus.value = status;
    if (region != null) selectedRegion.value = region;

    // Simulate stats updating dynamically when filters change
    int multiplier = 1;
    if (selectedVehicleType.value == 'Cargo Trucks') multiplier = 2;
    if (selectedVehicleType.value == 'Delivery Vans') multiplier = 3;
    if (selectedVehicleType.value == 'Tippers') multiplier = 4;

    activeVehicles.value = (35 + multiplier * 2) % 60;
    availableVehicles.value = (10 + multiplier * 3) % 25;
    downVehicles.value = (2 + multiplier) % 8;
    activeTrips.value = (20 + multiplier * 2) % 45;
    pendingTrips.value = (8 + multiplier) % 20;
    driversOnDuty.value = (30 + multiplier * 3) % 50;
    fleetUtilization.value = 75.0 + (multiplier * 2.5);
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    
    // Simulate API fetch delay
    await Future<void>.delayed(const Duration(milliseconds: 600));

    activeVehicles.value = 42;
    availableVehicles.value = 15;
    downVehicles.value = 4;
    activeTrips.value = 28;
    pendingTrips.value = 12;
    driversOnDuty.value = 35;
    fleetUtilization.value = 82.5;
    operatingCost.value = 14250.75;
    
    recentActivities.assignAll(<String>[
      'Trip #3092 dispatched successfully to Driver John.',
      'Vehicle #104 brake inspection logged by safety team.',
      'Fuel transaction ₹15,000 logged for Truck #45.',
      'Maintenance order #819 closed for Vehicle #12.',
    ]);

    // Prepopulate vehicles list
    vehiclesList.assignAll(<VehicleModel>[
      VehicleModel(
        name: 'Ashok Leyland Cargo 101',
        number: 'MH-12-PQ-8901',
        registrationNumber: 'REG-8901',
        chasisNumber: 'CHS-091A82',
        type: VehicleType.Truck,
        maxLoadCapacity: 12000.0,
        capacityUnit: CapacityUnit.Kg,
        odometer: 45230.0,
        acquisitionCost: 2800000.0,
        status: VehicleStatus.Available,
      ),
      VehicleModel(
        name: 'Tata Ace Gold',
        number: 'DL-01-AB-1234',
        registrationNumber: 'REG-1234',
        chasisNumber: 'CHS-129B78',
        type: VehicleType.MiniTruck,
        maxLoadCapacity: 1500.0,
        capacityUnit: CapacityUnit.Kg,
        odometer: 12800.0,
        acquisitionCost: 650000.0,
        status: VehicleStatus.OnTrip,
      ),
      VehicleModel(
        name: 'Mahindra Supro',
        number: 'KA-03-XY-5678',
        registrationNumber: 'REG-5678',
        chasisNumber: 'CHS-812C43',
        type: VehicleType.Van,
        maxLoadCapacity: 800.0,
        capacityUnit: CapacityUnit.Kg,
        odometer: 34100.0,
        acquisitionCost: 750000.0,
        status: VehicleStatus.InShop,
      ),
      VehicleModel(
        name: 'Maruti Suzuki Eeco Cargo',
        number: 'TS-09-RT-4321',
        registrationNumber: 'REG-4321',
        chasisNumber: 'CHS-431D91',
        type: VehicleType.MiniVan,
        maxLoadCapacity: 600.0,
        capacityUnit: CapacityUnit.Kg,
        odometer: 62400.0,
        acquisitionCost: 520000.0,
        status: VehicleStatus.Retired,
      ),
    ]);

    isLoading.value = false;
  }

  bool addVehicle(VehicleModel vehicle) {
    if (vehiclesList.any((VehicleModel v) =>
        v.registrationNumber.trim().toLowerCase() == vehicle.registrationNumber.trim().toLowerCase())) {
      return false;
    }
    vehiclesList.add(vehicle);
    return true;
  }

  void logout() {
    AuthService.to.logout();
    Get.offAllNamed<dynamic>(AppRoutes.login);
  }
}

// Vehicle Enums and Models
enum VehicleType { Van, MiniTruck, Truck, MiniVan }
enum CapacityUnit { Kg, Litres }
enum VehicleStatus { Available, OnTrip, InShop, Retired }

class VehicleModel {
  final String name;
  final String number;
  final String registrationNumber;
  final String chasisNumber;
  final VehicleType type;
  final double maxLoadCapacity;
  final CapacityUnit capacityUnit;
  final double odometer;
  final double acquisitionCost;
  final VehicleStatus status;

  VehicleModel({
    required this.name,
    required this.number,
    required this.registrationNumber,
    required this.chasisNumber,
    required this.type,
    required this.maxLoadCapacity,
    required this.capacityUnit,
    required this.odometer,
    required this.acquisitionCost,
    required this.status,
  });
}
