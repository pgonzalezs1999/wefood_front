import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSecureStorage {
  // Create storage
  final storage = const FlutterSecureStorage();

  // Read value
  Future<String?> read({required String key}) async {
    return await storage.read(key: key);
  }

  // Write value
  Future<void> write({required String key, required String value}) async {
    await storage.write(key: key, value: value);
  }

  Future<void> delete({required String key}) async {
    await storage.delete(key: key);
  }

  Future<DateTime?> readDateTime({required String key}) async {
    final dateString = await storage.read(key: key);
    if(dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  Future<void> writeDateTime({required String key, required DateTime value}) async {
    await storage.write(key: key, value: value.toIso8601String());
  }
}