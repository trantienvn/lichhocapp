import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CacheService {
  static Future<String> _getFilePath(String username) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$username.json';
  }

  static Future<void> saveJson(String username, String jsonData) async {
    final path = await _getFilePath(username);
    final file = File(path);
    final pathOld = await _getFilePath('$username.old');
    final fileOld = File(pathOld);
    if (await fileOld.exists()) {
      await fileOld.delete(); // Xóa file cũ nếu tồn tại
    }
    if (await file.exists()) {
      final oldContent = await file.readAsString();
      await fileOld.writeAsString(oldContent); // Lưu nội dung cũ
    }

    final wrapped = jsonEncode({
      'timestamp': DateTime.now().toIso8601String(),
      'data': jsonData,
    });

    await file.writeAsString(wrapped);
  }

  static Future<String?> readJson(String username) async {
    final path = await _getFilePath(username);
    final file = File(path);
    if (!await file.exists()) return null;

    try {
      final content = await file.readAsString();
      final jsonMap = jsonDecode(content);

      final timestamp = DateTime.tryParse(jsonMap['timestamp']);
      if (timestamp == null) return null;

      final now = DateTime.now();
      if (now.difference(timestamp).inHours < 24) {
        return jsonMap['data'];
      } else {
        await file.delete(); // Xóa nếu hết hạn
      }
    } catch (_) {
      return null;
    }

    return null;
  }
  static Future<void> clearCache(String username) async {
    final path = await _getFilePath(username);
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
  static Future<String?> readOldJson(String username) async {
    final path = await _getFilePath(username);
    final file = File(path);
    if (await file.exists()) {
      return await file.readAsString();
    }
    return null;
  }
}
