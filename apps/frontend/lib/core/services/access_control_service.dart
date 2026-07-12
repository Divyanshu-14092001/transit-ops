import 'package:get/get.dart';

/// Permission codes seeded by the backend. Keep these values aligned with
/// `apps/backend/prisma/seed.ts`; the frontend must not invent permission names.
abstract final class BackendPermissions {
  static const String authRead = 'auth_management:read';
  static const String authManage = 'auth_management:manage';
  static const String organizationCreate = 'organization_management:create';
  static const String organizationRead = 'organization_management:read';
  static const String organizationUpdate = 'organization_management:update';
  static const String fleetCreate = 'fleet_management:create';
  static const String fleetRead = 'fleet_management:read';
  static const String fleetUpdate = 'fleet_management:update';
  static const String fleetDelete = 'fleet_management:delete';
  static const String driverAssign = 'driver_management:assign';
  static const String tripCreate = 'trip_management:create';
  static const String tripAssign = 'trip_management:assign';
  static const String tripUpdate = 'trip_management:update';
  static const String maintenanceCreate = 'maintenance_management:create';
  static const String fuelCreate = 'fuel_management:create';
  static const String expenseCreate = 'expense_management:create';
  static const String expenseApprove = 'expense_management:approve';
  static const String reportRead = 'report_management:read';
  static const String reportExport = 'report_management:export';
}

class AccessControlService extends GetxService {
  static AccessControlService get to => Get.find();

  final RxSet<String> _permissions = <String>{}.obs;

  void loadPermissions(List<String> newPermissions) {
    _permissions.assignAll(newPermissions);
  }

  bool hasPermission(String permission) {
    return _permissions.contains(permission);
  }

  bool hasAnyPermission(Iterable<String> permissions) {
    return permissions.any(_permissions.contains);
  }

  Set<String> get permissions => Set<String>.unmodifiable(_permissions);

  void clearPermissions() {
    _permissions.clear();
  }
}
