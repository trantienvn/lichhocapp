import 'dart:html' as html;

class CacheService {
  static Future<void> saveJson(String username, String json) async {
    html.window.localStorage[username] = json;
  }

  static Future<String?> readJson(String username) async {
    return html.window.localStorage[username];
  }
}
