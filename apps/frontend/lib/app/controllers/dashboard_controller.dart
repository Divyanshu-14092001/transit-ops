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

  // Reactive Locations List
  final RxList<LocationModel> locationsList = <LocationModel>[].obs;

  // Track expanded trip ID
  final RxnString expandedTripId = RxnString();

  // Reactive Maintenance List
  final RxList<MaintenanceModel> maintenanceList = <MaintenanceModel>[].obs;

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
    await fetchMaintenance();
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

    // Fetch locations from backend
    await fetchLocations();

    // Fetch trips from backend
    await fetchTrips();

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

  Future<bool> createTrip(Map<String, dynamic> tripData) async {
    try {
      isLoading.value = true;
      final dio.Response<dynamic> response = await AuthService.to.dio.post<dynamic>(
        '/trips',
        data: tripData,
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchTrips();
        await fetchVehicles();
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

  Future<bool> updateTripStatus(String tripId, TripStatus newStatus) async {
    try {
      isLoading.value = true;
      final dio.Response<dynamic> response = await AuthService.to.dio.patch<dynamic>(
        '/trips/$tripId/status',
        data: <String, String>{
          'status': newStatus.name,
          'reason': 'Status updated from app',
        },
      );
      if (response.statusCode == 200) {
        await fetchTrips();
        await fetchVehicles();
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

  Future<void> fetchTrips() async {
    try {
      final dio.Response<dynamic> response = await AuthService.to.dio.get<dynamic>('/trips');
      if (response.statusCode == 200 && response.data != null) {
        final dynamic data = response.data['data'];
        if (data != null && data['trips'] != null) {
          final List<dynamic> items = data['trips'] as List<dynamic>;
          final List<TripModel> loadedTrips = items
              .map((dynamic item) => TripModel.fromJson(item as Map<String, dynamic>))
              .toList();
          tripsList.assignAll(loadedTrips);
        }
      }
    } catch (e) {
      // Keep existing list on failure
    }
  }

  Future<void> fetchLocations() async {
    try {
      final dio.Response<dynamic> response = await AuthService.to.dio.get<dynamic>('/locations');
      if (response.statusCode == 200 && response.data != null) {
        final dynamic data = response.data['data'];
        if (data is List) {
          final List<LocationModel> loadedLocations = data
              .map((dynamic item) => LocationModel.fromJson(item as Map<String, dynamic>))
              .toList();
          locationsList.assignAll(loadedLocations);
        }
      }
    } catch (e) {
      // Keep existing list on failure
    }
  }

  Future<void> fetchMaintenance() async {
    try {
      final dio.Response<dynamic> response = await AuthService.to.dio.get<dynamic>(
        '/maintenance',
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
          final List<MaintenanceModel> loaded = items
              .map((dynamic item) => MaintenanceModel.fromJson(item as Map<String, dynamic>))
              .toList();
          maintenanceList.assignAll(loaded);
        }
      }
    } catch (e) {
      // Keep existing list on failure
    }
  }

  Future<bool> addMaintenance(MaintenanceModel record) async {
    try {
      isLoading.value = true;
      final dio.Response<dynamic> response = await AuthService.to.dio.post<dynamic>(
        '/maintenance',
        data: record.toJson(),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchMaintenance();
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

  Future<bool> updateMaintenance(String id, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final dio.Response<dynamic> response = await AuthService.to.dio.put<dynamic>(
        '/maintenance/$id',
        data: data,
      );
      if (response.statusCode == 200) {
        await fetchMaintenance();
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
  final String id;
  final String? fleetId;
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
    this.id = '',
    this.fleetId,
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
      id: json['id'] as String? ?? '',
      fleetId: json['fleetId'] as String?,
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
      'id': id,
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
  final String id;
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
    this.id = '',
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
      id: json['id'] as String? ?? '',
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
      'id': id,
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

// Location Model
class LocationModel {
  final String id;
  final String name;
  final String code;
  final String type;

  LocationModel({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );
  }
}

// Trip Enums and Models
enum TripStatus { DRAFT, DISPATCHED, COMPLETED, CANCELLED }

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

  factory TripModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> vehicleJson = json['vehicle'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic> driverJson = json['driver'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic> sourceLocation = json['sourceLocation'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic> destinationLocation = json['destinationLocation'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final List<dynamic> logs = json['statusLogs'] as List<dynamic>? ?? <dynamic>[];

    final List<TripStatusHistory> historyList = logs.map((dynamic l) {
      final Map<String, dynamic> logMap = l as Map<String, dynamic>;
      final Map<String, dynamic> updatedBy = logMap['updatedBy'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return TripStatusHistory(
        status: TripStatus.values.firstWhere(
          (e) => e.name == logMap['statusTo'],
          orElse: () => TripStatus.DRAFT,
        ),
        timestamp: DateTime.tryParse(logMap['createdAt'] as String? ?? '') ?? DateTime.now(),
        changedBy: updatedBy['fullName'] as String? ?? 'System',
      );
    }).toList();

    return TripModel(
      id: json['id'] as String? ?? '',
      source: sourceLocation['name'] as String? ?? '',
      destination: destinationLocation['name'] as String? ?? '',
      vehicle: VehicleModel.fromJson(vehicleJson),
      driver: DriverModel.fromJson(driverJson),
      cargoWeight: double.tryParse(json['cargoWeight']?.toString() ?? '') ?? 0.0,
      plannedDistance: double.tryParse(json['distance']?.toString() ?? '') ?? 0.0,
      historyList: historyList,
      initialStatus: TripStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TripStatus.DRAFT,
      ),
    );
  }
}

// Maintenance Enums and Models
enum MaintenanceType {
  ROUTINE_SERVICE,
  PREVENTIVE,
  CORRECTIVE,
  BREAKDOWN,
  INSPECTION,
  TYRE_REPLACEMENT,
  ENGINE_REPAIR,
  BODY_REPAIR,
  OTHER
}

enum MaintenanceStatus {
  SCHEDULED,
  IN_PROGRESS,
  COMPLETED,
  CANCELLED,
  ON_HOLD
}

class MaintenanceModel {
  final String id;
  final String? fleetId;
  final String vehicleId;
  final String vehicleNumber;
  final MaintenanceType maintenanceType;
  final String? description;
  final MaintenanceStatus status;
  final DateTime startedAt;
  final DateTime? expectedCompletionAt;
  final DateTime? completedAt;
  final double? odometerReading;
  final double? estimatedCost;
  final double? actualCost;
  final String? serviceProvider;
  final String? invoiceNumber;
  final String? notes;
  final String? createdBy;
  final String? updatedBy;

  MaintenanceModel({
    required this.id,
    this.fleetId,
    required this.vehicleId,
    required this.vehicleNumber,
    required this.maintenanceType,
    this.description,
    required this.status,
    required this.startedAt,
    this.expectedCompletionAt,
    this.completedAt,
    this.odometerReading,
    this.estimatedCost,
    this.actualCost,
    this.serviceProvider,
    this.invoiceNumber,
    this.notes,
    this.createdBy,
    this.updatedBy,
  });

  factory MaintenanceModel.fromJson(Map<String, dynamic> json) {
    final vehicle = json['vehicle'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final createdByUser = json['createdBy'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final updatedByUser = json['updatedBy'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return MaintenanceModel(
      id: json['id'] as String? ?? '',
      fleetId: json['fleetId'] as String?,
      vehicleId: json['vehicleId'] as String? ?? '',
      vehicleNumber: vehicle['vehicleNumber'] as String? ?? json['vehicleNumber'] as String? ?? '',
      maintenanceType: MaintenanceType.values.firstWhere(
        (e) => e.name == json['maintenanceType'],
        orElse: () => MaintenanceType.ROUTINE_SERVICE,
      ),
      description: json['description'] as String?,
      status: MaintenanceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MaintenanceStatus.SCHEDULED,
      ),
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ?? DateTime.now(),
      expectedCompletionAt: DateTime.tryParse(json['expectedCompletionAt'] as String? ?? ''),
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? ''),
      odometerReading: double.tryParse(json['odometerReading']?.toString() ?? ''),
      estimatedCost: double.tryParse(json['estimatedCost']?.toString() ?? ''),
      actualCost: double.tryParse(json['actualCost']?.toString() ?? ''),
      serviceProvider: json['serviceProvider'] as String?,
      invoiceNumber: json['invoiceNumber'] as String?,
      notes: json['notes'] as String?,
      createdBy: createdByUser['fullName'] as String? ?? json['createdBy'] as String?,
      updatedBy: updatedByUser['fullName'] as String? ?? json['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'vehicleId': vehicleId,
      if (fleetId != null) 'fleetId': fleetId,
      'maintenanceType': maintenanceType.name,
      'description': description ?? '',
      'status': status.name,
      'startedAt': startedAt.toIso8601String(),
      if (expectedCompletionAt != null) 'expectedCompletionAt': expectedCompletionAt!.toIso8601String(),
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      if (odometerReading != null) 'odometerReading': odometerReading,
      if (estimatedCost != null) 'estimatedCost': estimatedCost,
      if (actualCost != null) 'actualCost': actualCost,
      if (serviceProvider != null) 'serviceProvider': serviceProvider,
      if (invoiceNumber != null) 'invoiceNumber': invoiceNumber,
      if (notes != null) 'notes': notes,
    };
  }
}
