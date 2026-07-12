import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'storage_service.dart';
import 'access_control_service.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final RxBool isLoggedIn = false.obs;
  final RxnString token = RxnString();
  final RxnString username = RxnString();

  late final Dio _dio;
  
  // Base configuration: Can be configured via environment variables
  static const String baseUrl = 'http://localhost:3000/api';

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    ));

    // Restore session on boot
    final String? cachedToken = StorageService.to.read('auth_token') as String?;
    final String? cachedUser = StorageService.to.read('auth_user') as String?;
    final List<dynamic>? cachedPerms = StorageService.to.read('auth_permissions') as List<dynamic>?;

    if (cachedToken != null && cachedUser != null && cachedPerms != null) {
      token.value = cachedToken;
      username.value = cachedUser;
      isLoggedIn.value = true;
      AccessControlService.to.loadPermissions(cachedPerms.cast<String>());
      _setupDioAuthorization(cachedToken);
    }
  }

  void _setupDioAuthorization(String userToken) {
    _dio.options.headers['Authorization'] = 'Bearer $userToken';
  }

  void _clearDioAuthorization() {
    _dio.options.headers.remove('Authorization');
  }

  Future<bool> login(String email, String password) async {
    // Delay slightly to simulate a responsive loading state
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (email.trim() == 'driver@transitops.com') {
      return _handleMockLogin(
        'mock-jwt-driver-token',
        'John Driver',
        const <String>[
          'dashboard:view',
          'trip:read', 'trip:complete',
          'fuel:create',
        ],
      );
    } else {
      final String displayName = email.isNotEmpty && email.contains('@')
          ? email.split('@')[0]
          : 'Fleet Manager';
      return _handleMockLogin(
        'mock-jwt-admin-token',
        displayName.substring(0, 1).toUpperCase() + displayName.substring(1),
        const <String>[
          'dashboard:view',
          'vehicle:read', 'vehicle:create', 'vehicle:update', 'vehicle:delete',
          'driver:read', 'driver:create', 'driver:update', 'driver:delete',
          'trip:read', 'trip:create', 'trip:dispatch', 'trip:complete', 'trip:cancel',
          'maintenance:read', 'maintenance:create', 'maintenance:update', 'maintenance:close',
          'fuel:create', 'expense:create', 'report:view', 'report:export',
        ],
      );
    }
  }

  bool _handleMockLogin(String authToken, String name, List<String> perms) {
    token.value = authToken;
    username.value = name;
    isLoggedIn.value = true;

    StorageService.to.write('auth_token', authToken);
    StorageService.to.write('auth_user', name);
    StorageService.to.write('auth_permissions', perms);

    AccessControlService.to.loadPermissions(perms);
    _setupDioAuthorization(authToken);
    return true;
  }

  void logout() {
    token.value = null;
    username.value = null;
    isLoggedIn.value = false;

    StorageService.to.remove('auth_token');
    StorageService.to.remove('auth_user');
    StorageService.to.remove('auth_permissions');

    AccessControlService.to.clearPermissions();
    _clearDioAuthorization();
  }
}
