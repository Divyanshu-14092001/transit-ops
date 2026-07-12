import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
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
  final Rxn<VehicleStatus> selectedVehicleStatusFilter = Rxn<VehicleStatus>();

  // Reactive Drivers List
  final RxList<DriverModel> driversList = <DriverModel>[].obs;
  final RxString driverSearchQuery = ''.obs;
  final Rxn<DriverStatus> selectedDriverStatusFilter = Rxn<DriverStatus>();

  // Reactive Trips List
  final RxList<TripModel> tripsList = <TripModel>[].obs;

  // Track expanded trip ID
  final RxnString expandedTripId = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
    
    // Auto-fetch drivers when query or status filter changes
    debounce<String>(driverSearchQuery, (_) => fetchDrivers(), time: const Duration(milliseconds: 300));
    ever<DriverStatus?>(selectedDriverStatusFilter, (_) => fetchDrivers());
    ever<VehicleStatus?>(selectedVehicleStatusFilter, (_) => fetchVehicles());
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

    // Fetch vehicles from backend, or fall back to mock profiles
    await fetchVehicles();
    if (vehiclesList.isEmpty) {
      vehiclesList.assignAll(<VehicleModel>[
        VehicleModel(
          name: 'Ashok Leyland Cargo 101',
          number: 'MH-12-PQ-8901',
          registrationNumber: 'REG-8901',
          chasisNumber: 'CHS-091A82',
          type: VehicleType.TRUCK,
          maxLoadCapacity: 12000.0,
          capacityUnit: CapacityUnit.KILOGRAM,
          odometer: 45230.0,
          acquisitionCost: 2800000.0,
          status: VehicleStatus.AVAILABLE,
        ),
        VehicleModel(
          name: 'Tata Ace Gold',
          number: 'DL-01-AB-1234',
          registrationNumber: 'REG-1234',
          chasisNumber: 'CHS-129B78',
          type: VehicleType.MINI_TRUCK,
          maxLoadCapacity: 1500.0,
          capacityUnit: CapacityUnit.KILOGRAM,
          odometer: 12800.0,
          acquisitionCost: 650000.0,
          status: VehicleStatus.ON_TRIP,
        ),
        VehicleModel(
          name: 'Mahindra Supro',
          number: 'KA-03-XY-5678',
          registrationNumber: 'REG-5678',
          chasisNumber: 'CHS-812C43',
          type: VehicleType.VAN,
          maxLoadCapacity: 800.0,
          capacityUnit: CapacityUnit.KILOGRAM,
          odometer: 34100.0,
          acquisitionCost: 750000.0,
          status: VehicleStatus.IN_SHOP,
        ),
        VehicleModel(
          name: 'Maruti Suzuki Eeco Cargo',
          number: 'TS-09-RT-4321',
          registrationNumber: 'REG-4321',
          chasisNumber: 'CHS-431D91',
          type: VehicleType.VAN,
          maxLoadCapacity: 600.0,
          capacityUnit: CapacityUnit.KILOGRAM,
          odometer: 62400.0,
          acquisitionCost: 520000.0,
          status: VehicleStatus.RETIRED,
        ),
      ]);
    }

    // Fetch drivers from backend, or fall back to mock profiles
    await fetchDrivers();
    if (driversList.isEmpty) {
      driversList.assignAll(<DriverModel>[
        DriverModel(
          fullName: 'Vikram Malhotra',
          email: 'vikram@transitops.com',
          contactNumber: '9876543210',
          employeeCode: 'DRV001',
          licenseNumber: 'DL-991823A',
          licenseCategory: LicenseCategory.HMV,
          licenseIssuedAt: DateTime.now().subtract(const Duration(days: 365 * 3)),
          licenseExpiryDate: DateTime(2030, 5, 12),
          safetyScore: 95.0,
          status: DriverStatus.AVAILABLE,
        ),
        DriverModel(
          fullName: 'John Doe',
          email: 'john.doe@transitops.com',
          contactNumber: '9812345670',
          employeeCode: 'DRV002',
          licenseNumber: 'DL-182309B',
          licenseCategory: LicenseCategory.LMV,
          licenseIssuedAt: DateTime.now().subtract(const Duration(days: 365 * 3)),
          licenseExpiryDate: DateTime(2028, 11, 22),
          safetyScore: 88.0,
          status: DriverStatus.ON_TRIP,
        ),
        DriverModel(
          fullName: 'Rajesh Kumar',
          email: 'rajesh@transitops.com',
          contactNumber: '9718293810',
          employeeCode: 'DRV003',
          licenseNumber: 'DL-481923C',
          licenseCategory: LicenseCategory.HMV,
          licenseIssuedAt: DateTime.now().subtract(const Duration(days: 365 * 3)),
          licenseExpiryDate: DateTime(2027, 2, 15),
          safetyScore: 91.0,
          status: DriverStatus.AVAILABLE,
        ),
        DriverModel(
          fullName: 'Sunita Sharma',
          email: 'sunita@transitops.com',
          contactNumber: '9923849102',
          employeeCode: 'DRV004',
          licenseNumber: 'DL-382910D',
          licenseCategory: LicenseCategory.LMV,
          licenseIssuedAt: DateTime.now().subtract(const Duration(days: 365 * 3)),
          licenseExpiryDate: DateTime(2025, 9, 8),
          safetyScore: 78.5,
          status: DriverStatus.SUSPENDED,
        ),
      ]);
    }

    // Prepopulate trips list with safe bounds-checking lookups
    final DriverModel fallbackDriver = driversList.isNotEmpty
        ? driversList[0]
        : DriverModel(
            fullName: 'Vikram Malhotra',
            email: 'vikram@transitops.com',
            contactNumber: '9876543210',
            employeeCode: 'DRV001',
            licenseNumber: 'DL-991823A',
            licenseCategory: LicenseCategory.HMV,
            licenseIssuedAt: DateTime.now().subtract(const Duration(days: 365)),
            licenseExpiryDate: DateTime(2030, 5, 12),
            safetyScore: 95.0,
            status: DriverStatus.AVAILABLE,
          );

    final VehicleModel fallbackVehicle = vehiclesList.isNotEmpty
        ? vehiclesList[0]
        : VehicleModel(
            name: 'Ashok Leyland Cargo 101',
            number: 'MH-12-PQ-8901',
            registrationNumber: 'REG-8901',
            chasisNumber: 'CHS-091A82',
            type: VehicleType.TRUCK,
            maxLoadCapacity: 12000.0,
            capacityUnit: CapacityUnit.KILOGRAM,
            odometer: 45230.0,
            acquisitionCost: 2800000.0,
            status: VehicleStatus.AVAILABLE,
          );

    tripsList.assignAll(<TripModel>[
      TripModel(
        id: 'TR-3092',
        source: 'Pune',
        destination: 'Mumbai',
        vehicle: vehiclesList.isNotEmpty ? vehiclesList[0] : fallbackVehicle,
        driver: driversList.isNotEmpty ? driversList[0] : fallbackDriver,
        cargoWeight: 8500.0,
        plannedDistance: 150.0,
        initialStatus: TripStatus.ASSIGNED,
        historyList: <TripStatusHistory>[
          TripStatusHistory(status: TripStatus.DRAFT, timestamp: DateTime.now().subtract(const Duration(hours: 4)), changedBy: 'Fleet Manager'),
          TripStatusHistory(status: TripStatus.ASSIGNED, timestamp: DateTime.now().subtract(const Duration(hours: 2)), changedBy: 'Fleet Manager'),
        ],
      ),
      TripModel(
        id: 'TR-3093',
        source: 'Delhi',
        destination: 'Noida',
        vehicle: vehiclesList.length > 1 ? vehiclesList[1] : fallbackVehicle,
        driver: driversList.length > 1 ? driversList[1] : fallbackDriver,
        cargoWeight: 1200.0,
        plannedDistance: 45.0,
        initialStatus: TripStatus.COMPLETED,
        historyList: <TripStatusHistory>[
          TripStatusHistory(status: TripStatus.DRAFT, timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5)), changedBy: 'Fleet Manager'),
          TripStatusHistory(status: TripStatus.ASSIGNED, timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)), changedBy: 'Fleet Manager'),
          TripStatusHistory(status: TripStatus.COMPLETED, timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 1)), changedBy: 'Fleet Manager'),
        ],
      ),
      TripModel(
        id: 'TR-3094',
        source: 'Hyderabad',
        destination: 'Secunderabad',
        vehicle: vehiclesList.length > 2 ? vehiclesList[2] : fallbackVehicle,
        driver: driversList.length > 2 ? driversList[2] : fallbackDriver,
        cargoWeight: 400.0,
        plannedDistance: 25.0,
        initialStatus: TripStatus.CANCELLED,
        historyList: <TripStatusHistory>[
          TripStatusHistory(status: TripStatus.DRAFT, timestamp: DateTime.now().subtract(const Duration(hours: 6)), changedBy: 'Fleet Manager'),
          TripStatusHistory(status: TripStatus.ASSIGNED, timestamp: DateTime.now().subtract(const Duration(hours: 5)), changedBy: 'Fleet Manager'),
          TripStatusHistory(status: TripStatus.CANCELLED, timestamp: DateTime.now().subtract(const Duration(hours: 4)), changedBy: 'Fleet Manager'),
        ],
      ),
    ]);

    isLoading.value = false;
  }

  Future<void> fetchVehicles() async {
    try {
      final Map<String, dynamic> queryParameters = <String, dynamic>{};
      if (selectedVehicleStatusFilter.value != null) {
        queryParameters['status'] = selectedVehicleStatusFilter.value!.name;
      }

      final dio.Response<dynamic> response = await AuthService.to.dio.get<dynamic>(
        '/vehicles',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 && response.data != null) {
        final dynamic data = response.data['data'];
        if (data != null) {
          List<dynamic> items = <dynamic>[];
          if (data is List) {
            items = data;
          } else if (data is Map && data['items'] != null) {
            items = data['items'] as List<dynamic>;
          }
          final List<VehicleModel> loadedVehicles = items
              .map((dynamic item) => VehicleModel.fromJson(item as Map<String, dynamic>))
              .toList();
          vehiclesList.assignAll(loadedVehicles);
        }
      }
    } catch (e) {
      // Keep existing list on failure
    }
  }

  Future<VehicleModel?> checkVehicleRegistration(String registrationNumber) async {
    try {
      final dio.Response<dynamic> response = await AuthService.to.dio.get<dynamic>(
        '/vehicles',
        queryParameters: <String, String>{'registrationNumber': registrationNumber.trim()},
      );
      if (response.statusCode == 200 && response.data != null) {
        final dynamic data = response.data['data'];
        if (data != null) {
          if (data is Map<String, dynamic>) {
            return VehicleModel.fromJson(data);
          } else if (data is List && data.isNotEmpty) {
            return VehicleModel.fromJson(data.first as Map<String, dynamic>);
          }
        }
      }
    } catch (e) {
      // Return null on failure
    }
    return null;
  }

  Future<bool> addVehicle(VehicleModel vehicle) async {
    try {
      isLoading.value = true;
      final dio.Response<dynamic> response = await AuthService.to.dio.post<dynamic>(
        '/vehicles',
        data: vehicle.toJson(),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchVehicles();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addDriver(DriverModel driver) async {
    try {
      isLoading.value = true;
      final dio.Response<dynamic> response = await AuthService.to.dio.post<dynamic>(
        '/drivers',
        data: driver.toJson(),
      );
      if (response.statusCode == 200) {
        await fetchDrivers();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDrivers() async {
    try {
      final Map<String, dynamic> queryParameters = <String, dynamic>{};
      if (driverSearchQuery.value.isNotEmpty) {
        queryParameters['search'] = driverSearchQuery.value;
      }
      if (selectedDriverStatusFilter.value != null) {
        queryParameters['status'] = selectedDriverStatusFilter.value!.name;
      }

      final dio.Response<dynamic> response = await AuthService.to.dio.get<dynamic>(
        '/drivers',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 && response.data != null) {
        final dynamic data = response.data['data'];
        if (data != null && data['items'] != null) {
          final List<dynamic> items = data['items'] as List<dynamic>;
          final List<DriverModel> loadedDrivers = items
              .map((dynamic item) => DriverModel.fromJson(item as Map<String, dynamic>))
              .toList();
          driversList.assignAll(loadedDrivers);
        }
      }
    } catch (e) {
      // Keep existing local list if API fails (e.g. offline fallback)
    }
  }

  Future<DriverModel?> checkLicense(String licenseNumber) async {
    try {
      final dio.Response<dynamic> response = await AuthService.to.dio.get<dynamic>(
        '/drivers',
        queryParameters: <String, String>{'licenseNumber': licenseNumber.trim()},
      );
      if (response.statusCode == 200 && response.data != null) {
        final dynamic data = response.data['data'];
        if (data != null && data['items'] != null) {
          final List<dynamic> items = data['items'] as List<dynamic>;
          if (items.isNotEmpty) {
            return DriverModel.fromJson(items.first as Map<String, dynamic>);
          }
        }
      }
    } on dio.DioException catch (e) {
      final dynamic responseData = e.response?.data;
      if (responseData != null && responseData['message'] != null) {
        throw Exception(responseData['message'].toString());
      }
      rethrow;
    } catch (e) {
      // Error checking license
    }
    return null;
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

  Future<void> logout() async {
    await AuthService.to.logout();
    AppNavigator.replaceAllNamed<dynamic>(AppRoutes.login);
  }
}

// Vehicle Enums and Models
enum VehicleType { VAN, TRUCK, MINI_TRUCK, TANKER, OTHER }
enum CapacityUnit { KILOGRAM, LITRE }
enum VehicleStatus { AVAILABLE, ON_TRIP, IN_SHOP, RETIRED }

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

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      name: json['vehicleNumber'] as String? ?? '',
      number: json['vehicleNumber'] as String? ?? '',
      registrationNumber: json['registrationNumber'] as String? ?? '',
      chasisNumber: json['chassisNumber'] as String? ?? '',
      type: VehicleType.values.firstWhere(
        (e) => e.name == json['vehicleType'],
        orElse: () => VehicleType.TRUCK,
      ),
      maxLoadCapacity: double.tryParse(json['maximumCapacity']?.toString() ?? '') ?? 0.0,
      capacityUnit: CapacityUnit.values.firstWhere(
        (e) => e.name == json['capacityUnit'],
        orElse: () => CapacityUnit.KILOGRAM,
      ),
      odometer: double.tryParse(json['odometerReading']?.toString() ?? '') ?? 0.0,
      acquisitionCost: double.tryParse(json['acquisitionCost']?.toString() ?? '') ?? 0.0,
      status: VehicleStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => VehicleStatus.AVAILABLE,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'vehicleNumber': number,
      'registrationNumber': registrationNumber,
      'chassisNumber': chasisNumber,
      'vehicleType': type.name,
      'acquisitionCost': acquisitionCost,
      'acquisitionDate': DateTime.now().toIso8601String().substring(0, 10),
      'manufacturingYear': DateTime.now().year,
      'capacityType': 'WEIGHT',
      'maximumCapacity': maxLoadCapacity,
      'capacityUnit': capacityUnit.name,
      'odometerReading': odometer,
      'status': status.name,
    };
  }
}

// Driver Enums and Models
enum DriverStatus { AVAILABLE, ON_TRIP, OFF_DUTY, SUSPENDED }
enum LicenseCategory { LMV, HMV, TRANSPORT, COMMERCIAL, OTHER }

class DriverModel {
  final String fullName;
  final String email;
  final String contactNumber;
  final String employeeCode;
  final String licenseNumber;
  final LicenseCategory licenseCategory;
  final DateTime licenseIssuedAt;
  final DateTime licenseExpiryDate;
  final double safetyScore;
  final DriverStatus status;

  DriverModel({
    required this.fullName,
    required this.email,
    required this.contactNumber,
    required this.employeeCode,
    required this.licenseNumber,
    required this.licenseCategory,
    required this.licenseIssuedAt,
    required this.licenseExpiryDate,
    required this.safetyScore,
    required this.status,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> user = json['user'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return DriverModel(
      fullName: user['fullName'] as String? ?? json['fullName'] as String? ?? '',
      email: user['email'] as String? ?? json['email'] as String? ?? '',
      contactNumber: user['contactNumber'] as String? ?? json['contactNumber'] as String? ?? '',
      employeeCode: json['employeeCode'] as String? ?? '',
      licenseNumber: json['licenseNumber'] as String? ?? '',
      licenseCategory: LicenseCategory.values.firstWhere(
        (LicenseCategory e) => e.name == (json['licenseCategory'] as String? ?? 'LMV').toUpperCase(),
        orElse: () => LicenseCategory.LMV,
      ),
      licenseIssuedAt: DateTime.tryParse(json['licenseIssuedAt'] as String? ?? '') ?? DateTime.now(),
      licenseExpiryDate: DateTime.tryParse(json['licenseExpiryDate'] as String? ?? '') ?? DateTime.now(),
      safetyScore: double.tryParse(json['safetyScore']?.toString() ?? '') ?? 100.0,
      status: DriverStatus.values.firstWhere(
        (DriverStatus e) => e.name == (json['status'] as String? ?? 'AVAILABLE').toUpperCase(),
        orElse: () => DriverStatus.AVAILABLE,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fullName': fullName,
      'email': email,
      'contactNumber': contactNumber,
      'employeeCode': employeeCode,
      'licenseNumber': licenseNumber,
      'licenseCategory': licenseCategory.name,
      'licenseIssuedAt': licenseIssuedAt.toIso8601String(),
      'licenseExpiryDate': licenseExpiryDate.toIso8601String(),
      'safetyScore': safetyScore,
      'status': status.name,
    };
  }
}

// Trip Enums and Models
enum TripStatus { DRAFT, PLANNED, ASSIGNED, READY, IN_PROGRESS, COMPLETED, CANCELLED, DELAYED, FAILED }

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
