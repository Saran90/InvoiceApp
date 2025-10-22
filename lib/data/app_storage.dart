import 'dart:ui';

import 'package:get_storage/get_storage.dart';

import 'app_storage_keys.dart';

final box = GetStorage();

class AppStorage {

  String? getAccessToken() {
    String? accessToken = box.read(accessTokenKey);
    return accessToken;
  }

  bool? isLoggedIn() {
    bool? flag = box.read(isLoggedInKey);
    return flag;
  }

  String? getS3Folder() {
    String? folder = box.read(s3FolderNameKey);
    return folder;
  }

  Future<void> setAccessToken({required String token}) async {
    await box.write(accessTokenKey, token);
  }

  int? getUserId() {
    int? userId = box.read(userIdKey);
    return userId;
  }

  Future<void> setBaseUrl({required String url}) async {
    await box.write(baseUrlKey, url);
  }

  String? getBaseUrl() {
    String? url = box.read(baseUrlKey);
    return url;
  }

  Future<void> setUserId({required int userId}) async {
    await box.write(userIdKey, userId);
  }

  Future<void> setLoggedIn({required bool flag}) async {
    await box.write(isLoggedInKey, flag);
  }

  Future<void> setS3Folder({required String folder}) async {
    await box.write(s3FolderNameKey, folder);
  }

  Future<void> setLoginStatus({required bool status}) async {
    await box.write(isLoggedInKey, status);
  }

  Future<void> clear() async {
    await box.erase();
    await setLoginStatus(status: false);
  }
}
