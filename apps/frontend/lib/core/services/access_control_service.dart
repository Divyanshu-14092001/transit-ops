import 'package:get/get.dart';

class AccessControlService extends GetxService {
  static AccessControlService get to => Get.find();

  final RxSet<String> _permissions = <String>{}.obs;

  void loadPermissions(List<String> newPermissions) {
    _permissions.assignAll(newPermissions);
  }

  bool hasPermission(String permission) {
    return _permissions.contains(permission);
  }

  void clearPermissions() {
    _permissions.clear();
  }
}
