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

  // Reactive Drivers List
  final RxList<DriverModel> driversList = <DriverModel>[].obs;

  // Reactive Trips List
  final RxList<TripModel> tripsList = <TripModel>[].obs;

  // Track expanded trip ID
  final RxnString expandedTripId = RxnString();

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

    // Prepopulate drivers list
    driversList.assignAll(<DriverModel>[
      DriverModel(
        fullName: 'Vikram Malhotra',
        email: 'vikram@transitops.com',
        contactNumber: '9876543210',
        licenseNumber: 'DL-991823A',
        licenseCategory: LicenseCategory.HMV,
        licenseExpiryDate: DateTime(2030, 5, 12),
        safetyScore: 95.0,
        status: DriverStatus.Available,
      ),
      DriverModel(
        fullName: 'John Doe',
        email: 'john.doe@transitops.com',
        contactNumber: '9812345670',
        licenseNumber: 'DL-182309B',
        licenseCategory: LicenseCategory.LMV,
        licenseExpiryDate: DateTime(2028, 11, 22),
        safetyScore: 88.0,
        status: DriverStatus.OnTrip,
      ),
      DriverModel(
        fullName: 'Rajesh Kumar',
        email: 'rajesh@transitops.com',
        contactNumber: '9718293810',
        licenseNumber: 'DL-481923C',
        licenseCategory: LicenseCategory.HMV,
        licenseExpiryDate: DateTime(2027, 2, 15),
        safetyScore: 91.0,
        status: DriverStatus.OffDuty,
      ),
      DriverModel(
        fullName: 'Sunita Sharma',
        email: 'sunita@transitops.com',
        contactNumber: '9923849102',
        licenseNumber: 'DL-382910D',
        licenseCategory: LicenseCategory.LMV,
        licenseExpiryDate: DateTime(2025, 9, 8),
        safetyScore: 78.5,
        status: DriverStatus.Suspended,
      ),
    ]);

    // Prepopulate trips list
    tripsList.assignAll(<TripModel>[
      TripModel(
        id: 'TR-3092',
        source: 'Pune',
        destination: 'Mumbai',
        vehicle: vehiclesList[0],
        driver: driversList[0],
        cargoWeight: 8500.0,
        plannedDistance: 150.0,
        initialStatus: TripStatus.Dispatched,
        historyList: <TripStatusHistory>[
          TripStatusHistory(status: TripStatus.Draft, timestamp: DateTime.now().subtract(const Duration(hours: 4)), changedBy: 'Fleet Manager'),
          TripStatusHistory(status: TripStatus.Dispatched, timestamp: DateTime.now().subtract(const Duration(hours: 2)), changedBy: 'Fleet Manager'),
        ],
      ),
      TripModel(
        id: 'TR-3093',
        source: 'Delhi',
        destination: 'Noida',
        vehicle: vehiclesList[1],
        driver: driversList[1],
        cargoWeight: 1200.0,
        plannedDistance: 45.0,
        initialStatus: TripStatus.Completed,
        historyList: <TripStatusHistory>[
          TripStatusHistory(status: TripStatus.Draft, timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5)), changedBy: 'Fleet Manager'),
          TripStatusHistory(status: TripStatus.Dispatched, timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)), changedBy: 'Fleet Manager'),
          TripStatusHistory(status: TripStatus.Completed, timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 1)), changedBy: 'Fleet Manager'),
        ],
      ),
      TripModel(
        id: 'TR-3094',
        source: 'Hyderabad',
        destination: 'Secunderabad',
        vehicle: vehiclesList[2],
        driver: driversList[2],
        cargoWeight: 400.0,
        plannedDistance: 25.0,
        initialStatus: TripStatus.Cancelled,
        historyList: <TripStatusHistory>[
          TripStatusHistory(status: TripStatus.Draft, timestamp: DateTime.now().subtract(const Duration(hours: 6)), changedBy: 'Fleet Manager'),
          TripStatusHistory(status: TripStatus.Dispatched, timestamp: DateTime.now().subtract(const Duration(hours: 5)), changedBy: 'Fleet Manager'),
          TripStatusHistory(status: TripStatus.Cancelled, timestamp: DateTime.now().subtract(const Duration(hours: 4)), changedBy: 'Fleet Manager'),
        ],
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

  bool addDriver(DriverModel driver) {
    if (driversList.any((DriverModel d) =>
        d.licenseNumber.trim().toLowerCase() == driver.licenseNumber.trim().toLowerCase())) {
      return false;
    }
    driversList.add(driver);
    return true;
  }

  bool addTrip(TripModel trip) {
    if (tripsList.any((TripModel t) => t.id.toLowerCase() == trip.id.toLowerCase())) {
      return false;
    }
    tripsList.add(trip);
    return true;
  }

  void updateTripStatus(int index, TripStatus newStatus) {
    if (index >= 0 && index < tripsList.length) {
      final TripModel trip = tripsList[index];
      trip.status.value = newStatus;
      trip.history.add(TripStatusHistory(
        status: newStatus,
        timestamp: DateTime.now(),
        changedBy: 'Fleet Manager',
      ));
      tripsList[index] = trip;
    }
  }

  void logout() {
    AuthService.to.logout();
    AppNavigator.replaceAllNamed<dynamic>(AppRoutes.login);
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

// Driver Enums and Models
enum DriverStatus { Available, OnTrip, OffDuty, Suspended }
enum LicenseCategory { LMV, HMV }

class DriverModel {
  final String fullName;
  final String email;
  final String contactNumber;
  final String licenseNumber;
  final LicenseCategory licenseCategory;
  final DateTime licenseExpiryDate;
  final double safetyScore;
  final DriverStatus status;

  DriverModel({
    required this.fullName,
    required this.email,
    required this.contactNumber,
    required this.licenseNumber,
    required this.licenseCategory,
    required this.licenseExpiryDate,
    required this.safetyScore,
    required this.status,
  });
}

// Trip Enums and Models
enum TripStatus { Draft, Dispatched, Completed, Cancelled }

class TripStatusHistory {
  final TripStatus status;
  final DateTime timestamp;
  final String changedBy;

  TripStatusHistory({
    required this.status,
    required this.timestamp,
    required this.changedBy,
  });
}

class TripModel {
  final String id;
  final String source;
  final String destination;
  final VehicleModel vehicle;
  final DriverModel driver;
  final double cargoWeight;
  final double plannedDistance;
  final RxList<TripStatusHistory> history;
  final Rx<TripStatus> status;

  TripModel({
    required this.id,
    required this.source,
    required this.destination,
    required this.vehicle,
    required this.driver,
    required this.cargoWeight,
    required this.plannedDistance,
    required List<TripStatusHistory> historyList,
    required TripStatus initialStatus,
  })  : history = historyList.obs,
        status = initialStatus.obs;
}
