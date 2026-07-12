import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:transitops_frontend/config/api_config.dart';

import 'access_control_service.dart';
import 'auth_models.dart';
import 'storage_service.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final RxBool isLoggedIn = false.obs;
  final RxnString token = RxnString();
  final Rxn<AuthUser> user = Rxn<AuthUser>();
  final RxnString lastError = RxnString();

  late final Dio _dio;
  Dio get dio => _dio;

  static final String baseUrl =
      '${ApiConfig.baseUrl}/api';

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      headers: <String, String>{'Content-Type': 'application/json'},
    ));
  }

  Future<bool> restoreSession() async {
    final String? cachedToken = await StorageService.to.readAccessToken();
    final Map<String, dynamic>? cachedProfile = await StorageService.to.readProfile();

    if (cachedToken == null || cachedProfile == null) {
      await _clearSession();
      return false;
    }

    _setupDioAuthorization(cachedToken);

    try {
      final Response<dynamic> response =
          await _dio.get<dynamic>('/auth/verify-access-token');
      final Map<String, dynamic> body = _responseBody(response.data);
      final Map<String, dynamic> data = _jsonMap(body['data']);
      final AuthUser verifiedUser = AuthUser.fromJson(_jsonMap(data['user']));
      await _applySession(cachedToken, verifiedUser, persist: true);
      return true;
    } on DioException catch (error) {
      lastError.value = _errorMessage(error);
      await _clearSession();
      return false;
    } on FormatException catch (error) {
      lastError.value = error.message;
      await _clearSession();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    lastError.value = null;

    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        '/auth/login',
        data: <String, String>{
          'email': email.trim(),
          'password': password,
        },
      );
      final Map<String, dynamic> body = _responseBody(response.data);
      final Map<String, dynamic> data = _jsonMap(body['data']);
      final String accessToken = data['accessToken'] as String;
      final AuthUser loggedInUser = AuthUser.fromJson(_jsonMap(data['user']));

      await _applySession(accessToken, loggedInUser, persist: true);
      return true;
    } on DioException catch (error) {
      lastError.value = _errorMessage(error);
      return false;
    } on FormatException catch (error) {
      lastError.value = error.message;
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post<dynamic>('/auth/logout');
    } on DioException {
      // Logout is best-effort on the stateless backend. Local credentials must
      // always be removed even if the request cannot reach the server.
    } finally {
      await _clearSession();
    }
  }

  Future<void> _applySession(
    String accessToken,
    AuthUser authenticatedUser, {
    required bool persist,
  }) async {
    token.value = accessToken;
    user.value = authenticatedUser;
    isLoggedIn.value = true;
    AccessControlService.to.loadPermissions(authenticatedUser.permissions);
    _setupDioAuthorization(accessToken);

    if (persist) {
      await StorageService.to.writeAccessToken(accessToken);
      await StorageService.to.writeProfile(authenticatedUser.toJson());
    }
  }

  Future<void> _clearSession() async {
    token.value = null;
    user.value = null;
    isLoggedIn.value = false;
    AccessControlService.to.clearPermissions();
    _clearDioAuthorization();
    await StorageService.to.removeAccessToken();
    await StorageService.to.removeProfile();
  }

  void _setupDioAuthorization(String userToken) {
    _dio.options.headers['Authorization'] = 'Bearer $userToken';
  }

  void _clearDioAuthorization() {
    _dio.options.headers.remove('Authorization');
  }

  Map<String, dynamic> _responseBody(dynamic value) => _jsonMap(value);

  Map<String, dynamic> _jsonMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map<dynamic, dynamic>) {
      return value.cast<String, dynamic>();
    }
    throw const FormatException('The server returned an invalid response.');
  }

  String _errorMessage(DioException error) {
    final dynamic responseData = error.response?.data;
    if (responseData is Map) {
      final dynamic message = responseData['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.connectionError) {
      return 'Unable to reach the server. Please check your connection.';
    }
    return 'Unable to complete the request. Please try again.';
  }
}
