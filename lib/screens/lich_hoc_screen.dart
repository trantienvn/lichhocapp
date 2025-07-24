import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lichhocapp/services/cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/buoi_hoc.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import '../lunar_converter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart'; // Đảm bảo rằng GestureRecognizer đã được import

// Hàm mở URL khi nhấn vào tên học phần hoặc meet
void _launchUrl(String url) async {
  Uri uri = Uri.parse(url);
  if (!await launchUrl(uri)) {
    throw 'Could not launch $url';
  }
}

class LichHocScreen extends StatefulWidget {
  const LichHocScreen({super.key});

  @override
  State<LichHocScreen> createState() => _LichHocScreenState();
}

class _LichHocScreenState extends State<LichHocScreen> {
  List<BuoiHoc> _lich = [];
  bool _loading = true;
  final _today = DateTime.now();
  final _daysOfWeek = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final msv = prefs.getString('msv') ?? '';
    final pwd = prefs.getString('pwd') ?? '';

    try {
      final result = await ApiService.fetchLichHoc(msv, pwd, true);
      setState(() {
        _lich = result;
        _loading = false;
      });
    } catch (e) {
      print('Lỗi: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không tải được dữ liệu')));
    }
  }

  void _logout() async {
    setState(() {
      _loading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    await CacheService.clearCache(prefs.getString('msv') ?? ''); // Xóa cache

    await prefs.remove('msv');
    await prefs.remove('pwd');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  Text _AmLich(DateTime date) {
    final lunar = convertSolar2Lunar(date.day, date.month, date.year, 7);
    // return "ÂL${lunar[0]}/${lunar[1]} ${lunar[3] == 1 ? 'N' : ''}";
    return Text(
      "ÂL${lunar[0]}/${lunar[1]} ${lunar[3] == 1 ? 'N' : ''}",
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    );
  }

  Color _isToDay(DateTime date) {
    if (DateFormat('dd/MM/yyyy').format(date) ==
        DateFormat('dd/MM/yyyy').format(_today)) {
      return const Color.fromARGB(255, 253, 146, 192);
    } else if (_today.add(const Duration(days: 1)) == date) {
      return const Color.fromARGB(255, 200, 126, 253);
    }
    return const Color.fromARGB(255, 246, 185, 255);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: _appBarTitle(),
        body: Center(
          child: SpinKitPouringHourGlassRefined(
            color: Color.fromARGB(255, 154, 0, 159),
          ),
        ),
      );
    }

    bool started = false;
    bool haveLesson = false;
    List<Widget> content = [];
    if (DateFormat('dd/MM/yyyy').parse(_lich[0].tu).isAfter(_today)) {
      int numberOfDays = DateFormat(
        'dd/MM/yyyy',
      ).parse(_lich[0].tu).difference(_today).inDays;
      content.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _daysOfWeek[_today.weekday - 1],
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                  ),
                  Text(
                      DateFormat('dd/MM').format(_today),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  _AmLich(_today),
                ],
              ),
              Expanded(
                child: Card(
                  color: Color.fromARGB(255, 200, 126, 253),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // padding: const EdgeInsets.all(8.0),
                      children: [
                        SpinKitPouringHourGlassRefined(
                          color: Color.fromARGB(255, 22, 22, 22),
                        ),
                        Text(
                          "Lịch học sẽ bắt đầu sau $numberOfDays ngày",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    for (var item in _lich) {
      if (item.tuan != null) {
        // print(item.tuan); // Debugging output
        DateTime start = DateFormat('dd/MM/yyyy').parse(item.tu);
        DateTime end = DateFormat('dd/MM/yyyy').parse(item.den);

        if (end.isBefore(_today)) continue;
        if (start.isBefore(_today)) start = _today;
        if (!started) started = true;
        content.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "${item.tuan}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        );

        DateTime curr = start;
        while (!curr.isAfter(end)) {
          final formatted = DateFormat('dd/MM/yyyy').format(curr);
          final dayIndex = curr.weekday;
          List lessons = [];
          for (var lesson in _lich) {
            if (lesson.mocTG == formatted) {
              // print(lesson.mocTG); // Debugging output
              // print(formatted); // Debugging output
              // isPrinted = true;
              lessons.add(lesson);
            }
          }
          // print(isToday); // Debugging output
          bool found = lessons.isNotEmpty;
          haveLesson = true;

          content.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _daysOfWeek[dayIndex - 1],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        DateFormat('dd/MM').format(curr),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      _AmLich(curr),
                    ],
                  ),
                  Expanded(
                    child: found
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: lessons.map((lesson) {
                              return Card(
                                color: _isToDay(curr),
                                child: ListTile(
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lesson.thoiGian ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      // Tên học phần
                                      Text(
                                        "${lesson.tenHP}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text("Giảng viên: ${lesson.giangVien}"),
                                      // Sử dụng RichText để tạo link cho meet
                                      if (lesson.meet.length > 8)
                                        Text.rich(
                                          TextSpan(
                                            text: "Meet: ${lesson.meet}",
                                            style: const TextStyle(),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                // Giả sử URL của meet là link Google Meet/Zoom
                                                _launchUrl(
                                                  lesson.meet,
                                                ); // Mở link meet khi nhấn
                                              },
                                          ),
                                        ),
                                      Text("Tiết: ${lesson.tietHoc}"),
                                      Text("Phòng: ${lesson.diaDiem}"),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        : Card(
                            color: _isToDay(curr),
                            child: const ListTile(
                              title: Text("Bạn không có lịch học..."),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );

          curr = curr.add(const Duration(days: 1));
        }
      }
    }

    if (!started || !haveLesson) {
      return Scaffold(
        appBar: _appBarTitle(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/oops.png", height: 120),
              const SizedBox(height: 20),
              const Text(
                "Aww. Hiện tại bạn không có lịch học!",
                style: TextStyle(fontSize: 18, color: Colors.green),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _appBarTitle(),
      backgroundColor: const Color.fromARGB(255, 253, 228, 255),
      body: RefreshIndicator(
        onRefresh: _fetch,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(children: content),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _fetch),
        IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
      ],
    );
  }

  AppBar _appBarTitle() {
    return AppBar(
      title: const Text("Lịch học"),
      backgroundColor: Color(0xFFF0AAFB),
      actions: [_buildActions()],
    );
  }
}
