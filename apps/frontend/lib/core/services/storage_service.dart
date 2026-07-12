import 'package:get/get.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find();
  
  final Map<String, dynamic> _cache = <String, dynamic>{};

  Future<StorageService> init() async {
    return this;
  }

  void write(String key, dynamic value) {
    _cache[key] = value;
  }

  dynamic read(String key) {
    return _cache[key];
  }

  void remove(String key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }
}
