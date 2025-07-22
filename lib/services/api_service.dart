import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/buoi_hoc.dart';
import 'cache_service.dart';

class ApiService {
  static Future<List<BuoiHoc>> fetchLichHoc(String msv, String pwd) async {
    final url = Uri.parse('https://trantienvn.onrender.com/lichhoc?msv=$msv&pwd=$pwd');

    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        await CacheService.saveJson(msv, res.body);
        return _parseJson(res.body);
      }
    } catch (_) {
      final cached = await CacheService.readJson(msv);
      if (cached != null) {
        return _parseJson(cached);
      }
    }

    throw Exception('Không thể tải dữ liệu lịch học từ server hoặc cache');
  }

  static List<BuoiHoc> _parseJson(String jsonStr) {
    
    final data = json.decode(jsonStr);
    final list = data['lichhocdata'] as List;
    // print(list);
    return list.map((e) => BuoiHoc.fromJson(e)).toList();
  }
}
