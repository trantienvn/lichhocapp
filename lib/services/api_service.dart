import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/buoi_hoc.dart';
import 'cache_service.dart';

class ApiService {
  static Future<List<BuoiHoc>> fetchLichHoc(String msv, String pwd, bool? reload) async {
    final url = Uri.parse('https://trantien.id.vn/lichhoc/api/v2/?username=$msv&password=$pwd');
    // final cachedJson = await CacheService.readJson(msv);
    // if (cachedJson != null && !reload!) {
    //   return _parseJson(cachedJson);
    // }
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
  static Future<List<BuoiHoc>> getLichHocFromCache(String msv, String pwd) async {
    final cachedJson = await CacheService.readJson(msv);
    if (cachedJson != null) {
      return _parseJson(cachedJson);
    }
    return fetchLichHoc(msv, pwd, false);
  }
  static Map<String, List<BuoiHoc>> conv(List<BuoiHoc> list) {
    final grouped = <String, List<BuoiHoc>>{};
    for (var item in list) {
      if(item.mocTG == null) continue; // Bỏ qua nếu không có tên học phần
      if (grouped[item.mocTG] == null) {
        grouped[item.mocTG??''] = [];
      }
      grouped[item.mocTG]!.add(item);
    }
    return grouped;
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
