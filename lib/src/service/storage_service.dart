import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final storage = const FlutterSecureStorage();

  Future<String?> get token async {
    final jwt = await getValueFromStorage("access_token");
    return jwt;
  }

  Future<String?> get connectToken async {
    final jwt = await getValueFromStorage("connect_token");
    return jwt;
  }

  Future<String?> get businessName async {
    final string = await getValueFromStorage("businessName");
    return string;
  }

  Future<String> get businessId async {
    final string = await getValueFromStorage("businessId");
    return string;
  }

  getValueFromStorage(key) async {
    String? value = await storage.read(key: key);
    return value;
  }

  getAllValuesFromStorage() async {
    Map<String, String> allValues = await storage.readAll();
    return allValues;
  }

  deleteValueFromStorage(key) async {
    await storage.delete(key: key);
  }

  deleteStorageLogout() async {
    deleteAllValuesFromStorage();
    await createAndUpdateKeyValuePairInStorage('isFirstLogin', 'true');
  }

  deleteAllValuesFromStorage() async {
    await storage.deleteAll();
  }

  createAndUpdateKeyValuePairInStorage(key, value) async {
    await storage.write(key: key, value: value);
  }
}
