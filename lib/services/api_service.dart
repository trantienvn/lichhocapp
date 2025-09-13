import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/buoi_hoc.dart';
import '../models/mon_thi.dart';
import 'cache_service.dart';
class TranTienException implements Exception {
  final String message;
  
  TranTienException(this.message);

  @override
  String toString() => message;
}
class ApiService {
  
  static Future<List<BuoiHoc>> fetchLichHoc(
    String msv,
    String pwd,
    bool? reload,
  ) async {
    final url = Uri.parse(await getUrl(msv, pwd));
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        await CacheService.saveJson(msv, res.body);
        return _parseJson(res.body);
      }
    } catch (_) {
      final cached = await CacheService.readOldJson(msv);
      if (cached != null) {
        return _parseJson(cached);
      }
    }

    throw TranTienException('Không thể tải dữ liệu lịch học từ server hoặc cache');
  }

  static Future<List<MonThi>> fetchLichThi(String msv, String pwd) async {
    final url = Uri.parse("${await getUrl(msv, pwd)}&lichthi=1");
    try {
      final response = await http.get(url);
      final data = json.decode(response.body);
      if (data['HoTen'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', data['HoTen']);
      }
      if (data['error'] == true) {
        throw TranTienException('${data['message']}');
      }
      final list = data['lichthidata'] as List;
      return list.map((e) => MonThi.fromMap(e)).toList();
    } catch (e) {
      throw TranTienException('$e');
    }
  }

  static Future<List<BuoiHoc>> getLichHocFromCache(
    String msv,
    String pwd,
  ) async {
    final cachedJson = await CacheService.readJson(msv);
    if (cachedJson != null) {
      return _parseJson(cachedJson);
    }
    return fetchLichHoc(msv, pwd, false);
  }

  static Map<String, List<BuoiHoc>> conv(List<BuoiHoc> list) {
    final grouped = <String, List<BuoiHoc>>{};
    for (var item in list) {
      if (item.mocTG == null) continue; // Bỏ qua nếu không có tên học phần
      if (grouped[item.mocTG] == null) {
        grouped[item.mocTG ?? ''] = [];
      }
      grouped[item.mocTG]!.add(item);
    }
    return grouped;
  }

  static Future<String> getUrl(String msv, String pwd) async {
    final pref = await SharedPreferences.getInstance();
    final university = pref.getString('university') ?? 'DTC';
    switch (university) {
      case 'DTC':
        return 'https://trantien.id.vn/lichhoc/api/v2/?username=$msv&password=$pwd';
      case 'DTZ':
        return 'https://trantien.id.vn/lichhoc/api/tnus/?username=$msv&password=$pwd';
      default:
        return 'https://trantien.id.vn/lichhoc/api/v2/?username=$msv&password=$pwd';
    }
  }

  static List<BuoiHoc> _parseJson(String jsonStr) {
    final data = json.decode(jsonStr);
    if (data['error'] == true) {
      throw Exception('${data['message']}');
    }
    final list = data['lichhocdata'] as List;
    // print(list);
    return list.map((e) => BuoiHoc.fromJson(e)).toList();
  }
}
