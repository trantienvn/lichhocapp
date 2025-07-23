import 'dart:convert';
import 'dart:html' as html;

class CacheService {
  static Future<void> saveJson(String username, String jsonData) async {
    final old = html.window.localStorage[username];
    html.window.localStorage["$username.old"] = old ?? '';
    final cache = {
      'timestamp': DateTime.now().toIso8601String(),
      'data': jsonData,
    };
    html.window.localStorage[username] = jsonEncode(cache);
  }

  static Future<String?> readJson(String username) async {
    final raw = html.window.localStorage[username];
    if (raw == null) return null;

    try {
      final parsed = jsonDecode(raw);
      final timestamp = DateTime.tryParse(parsed['timestamp']);
      if (timestamp == null) return null;

      final now = DateTime.now();
      final diff = now.difference(timestamp);
      if (diff.inHours < 24) {
        return parsed['data'];
      } else {
        html.window.localStorage.remove(username); // Xóa nếu hết hạn
      }
    } catch (e) {
      return null; // Lỗi định dạng hoặc JSON sai
    }

    return null;
  }
  static Future<void> clearCache(String username) async {
    html.window.localStorage.remove(username);
    html.window.localStorage.remove("$username.old");
  }
  static Future<String?> readOldJson(String username) async {
    return html.window.localStorage["$username.old"];
  }
}
