import 'package:get/get.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/access_control_service.dart';
import '../../core/services/auth_service.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<StorageService>(StorageService(), permanent: true);
    Get.put<AccessControlService>(AccessControlService(), permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);
  }
}
