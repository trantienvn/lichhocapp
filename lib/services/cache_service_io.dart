// import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CacheService {
  static Future<String> _getFilePath(String username) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$username.json';
  }

  static Future<void> saveJson(String username, String json) async {
    final path = await _getFilePath(username);
    final file = File(path);
    await file.writeAsString(json);
  }

  static Future<String?> readJson(String username) async {
    final path = await _getFilePath(username);
    final file = File(path);
    if (await file.exists()) {
      return await file.readAsString();
    }
    return null;
  }
}
