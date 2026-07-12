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

    isLoading.value = false;
  }

  void logout() {
    AuthService.to.logout();
    Get.offAllNamed<dynamic>(AppRoutes.login);
  }
}
