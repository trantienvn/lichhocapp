import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/buoi_hoc.dart';
import 'cache_service.dart';

class ApiService {
  static Future<List<BuoiHoc>> fetchLichHoc(String msv, String pwd, bool? reload) async {
    final url = Uri.parse('https://trantienvn.onrender.com/lichhoc?msv=$msv&pwd=$pwd');
    final cachedJson = await CacheService.readJson(msv);
    if (cachedJson != null && !reload!) {
      return _parseJson(cachedJson);
    }
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

    throw Exception('Không thể tải dữ liệu lịch học từ server hoặc cache');
  }

  static List<BuoiHoc> _parseJson(String jsonStr) {
    
    final data = json.decode(jsonStr);
    if (data['error']==true) {
      throw Exception('${data['message']}');
    }
    final list = data['lichhocdata'] as List;
    // print(list);
    return list.map((e) => BuoiHoc.fromJson(e)).toList();
  }
}
