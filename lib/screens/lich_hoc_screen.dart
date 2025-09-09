import 'dart:ui';
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
import 'dart:html' as html;
import 'package:flutter/gestures.dart';
import 'package:table_calendar/table_calendar.dart';

class LichHocScreen extends StatefulWidget {
  const LichHocScreen({super.key});

  @override
  State<LichHocScreen> createState() => _LichHocScreenState();
}

class _LichHocScreenState extends State<LichHocScreen> {
  List<BuoiHoc> _lich = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, List<BuoiHoc>> _lessons = {};
  bool _danhsach = true;
  bool _loading = true;
  bool _hasAnError = false;
  String loaitruong = '';
  String nhan = '';

  final _today = DateTime.now();
  final _daysOfWeek = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    html.document.title = "Lịch Học";
    _loadFirst();
  }

  Future<void> _loadFirst() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    _danhsach = prefs.getBool('lich_danhsach') ?? true;
    loaitruong = prefs.getString('university') ?? 'DTC';
    final msv = prefs.getString('msv') ?? '';
    final pwd = prefs.getString('pwd') ?? '';
    try {
      final result = await ApiService.getLichHocFromCache(msv, pwd);
      setState(() {
        _lessons = ApiService.conv(result);
        _lich = result;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _hasAnError = true;
      });
    }
  }

  void _launchUrl(String url) async {
    switch (loaitruong) {
      case "DTC":
        break;
      case "DTZ":
        url = "tel:$url";
        break;
      default:
    }
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    loaitruong = prefs.getString('university') ?? 'DTC';
    final msv = prefs.getString('msv') ?? '';
    final pwd = prefs.getString('pwd') ?? '';
    try {
      final result = await ApiService.fetchLichHoc(msv, pwd, true);
      setState(() {
        _lich = result;
        _loading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không tải được dữ liệu')));
    }
  }

  void _logout() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    await CacheService.clearCache(prefs.getString('msv') ?? '');
    await prefs.remove('msv');
    await prefs.remove('pwd');
    await prefs.remove('isFirstTime');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Text _amLich(DateTime date) {
    final lunar = convertSolar2Lunar(date.day, date.month, date.year, 7);
    return Text(
      "ÂL${lunar[0]}/${lunar[1]} ${lunar[3] == 1 ? 'N' : ''}",
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.white70,
      ),
    );
  }

  Color _isToDay(DateTime date) {
    if (DateFormat('dd/MM/yyyy').format(date) ==
        DateFormat('dd/MM/yyyy').format(_today)) {
      return Colors.blueAccent.withOpacity(0.4);
    } else if (_today.add(const Duration(days: 1)) == date) {
      return Colors.indigo.withOpacity(0.4);
    }
    return Colors.cyan.withOpacity(0.3);
  }

  @override
  Widget build(BuildContext context) {
    switch (loaitruong) {
      case "DTC":
        nhan = "Meet";
        break;
      case "DTZ":
        nhan = "SĐT";
        break;
      default:
        nhan = "Meet";
    }
    if (_loading) {
      return Scaffold(
        appBar: _appBarTitle(),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Hình nền
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/lqglss.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Lớp blur (liquid glass)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: Colors.black.withOpacity(0.2), // thêm overlay nhẹ
              ),
            ),

            // Nội dung chính (loading spinner)
            const Center(
              child: SpinKitPouringHourGlassRefined(
                color: Color.fromARGB(255, 255, 255, 255),
                size: 80,
              ),
            ),
          ],
        ),
      );
    }

    if (_hasAnError) {
      return Scaffold(
        appBar: _appBarTitle(),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Hình nền
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/lqglss.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Lớp blur (liquid glass)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: Colors.black.withOpacity(0.2), // thêm overlay nhẹ
              ),
            ),

            // Nội dung chính (loading spinner)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/oops.png", height: 120),
                  const SizedBox(height: 20),
                  const Text(
                    "Aww. Có lỗi xảy ra khi tải lịch học!",
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: _logout,
                    child: const Text("Đăng Nhập Lại"),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    if (!_danhsach) {
      return renderLichThang();
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), // s
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
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      DateFormat('dd/MM').format(_today),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    _amLich(_today),
                  ],
                ),
                Expanded(
                  child: glassCard(
                    color: _isToDay(_today),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                      children: [
                        SpinKitPouringHourGlassRefined(color: Colors.white),
                        Text(
                          "Lịch học sẽ bắt đầu sau ${numberOfDays + 1} ngày",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    for (var item in _lich) {
      if (item.tuan != null) {
        DateTime start = DateFormat('dd/MM/yyyy').parse(item.tu);
        DateTime end = DateFormat('dd/MM/yyyy').parse(item.den);
        if ((end.add(new Duration(days: 1))).isBefore(_today)) continue;
        if (start.isBefore(_today)) start = _today;
        if (!started) started = true;
        content.add(
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600), // set max width
              child: glassCard(
                child: Center(
                  child: Text(
                    "${item.tuan} (${item.tu} đến ${item.den})",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        DateTime curr = start;
        while (isSameOrBefore(curr, end)) {
          final formatted = DateFormat('dd/MM/yyyy').format(curr);
          final dayIndex = curr.weekday;

          List lessons = _lich.where((l) => l.mocTG == formatted).toList();

          bool found = lessons.isNotEmpty;
          haveLesson = true;
          content.add(
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                ), // set max width
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8, top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _daysOfWeek[dayIndex - 1],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM').format(curr),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          _amLich(curr),
                        ],
                      ),
                    ),
                    Expanded(
                      child: found
                          ? Column(
                              children: lessons.map((lesson) {
                                return glassCard(
                                  color: _isToDay(curr),
                                  child: ListTile(
                                    title: Text(
                                      lesson.tenHP,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lesson.thoiGian ?? '',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),

                                        Text(
                                          "Giảng viên: ${lesson.giangVien}",
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        if (lesson.meet.length > 8)
                                          Text.rich(
                                            TextSpan(
                                              text: "${nhan}: ${lesson.meet}",
                                              style: const TextStyle(
                                                color: Colors.white70,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () =>
                                                    _launchUrl(lesson.meet),
                                            ),
                                          ),
                                        Text(
                                          "Tiết: ${lesson.tietHoc}",
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        Text(
                                          "Phòng: ${RegExp(r'<[^>]+>').hasMatch(lesson.diaDiem) ? "Online" : lesson.diaDiem}",
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        Text(
                                          "Buổi số: ${lesson.buoiSo}",
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            )
                          : glassCard(
                              color: _isToDay(curr),
                              child: const ListTile(
                                title: Text(
                                  "Bạn không có lịch học...",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
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
        body: Stack(
          fit: StackFit.expand,
          children: [
            // hình nền
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/lqglss.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // overlay gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.6),
                    Colors.black.withOpacity(0.4),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // nội dung glassmorphism
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    width: 300,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset("assets/oops.png", height: 120),
                        const SizedBox(height: 20),
                        const Text(
                          "Bạn không có lịch học!",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.withOpacity(0.7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Đăng Nhập Lại",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: _appBarTitle(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/lqglss.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.6),
                  Colors.black.withOpacity(0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          RefreshIndicator(
            onRefresh: _fetch,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(children: content),
            ),
          ),
        ],
      ),
    );
  }

  String convertToLunar(DateTime date) {
    final lunar = convertSolar2Lunar(date.day, date.month, date.year, 7);
    return "${lunar[0]}/${lunar[1]} ${lunar[3] == 1 ? 'N' : ''}";
  }

  bool isSpecialLunarDay(String lunar) {
    return lunar.startsWith('1/') || lunar.startsWith('15/');
  }

  Widget _buildDayCell({
    required DateTime day,
    required String lunar,
    required bool isSpecial,
    Color? textColor,
    Color? lunarColor,
    Color? backgroundColor,
    int? lessonCount = 0,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width < 600
          ? 60
          : 95, // 👈 tăng kích thước
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: (backgroundColor ?? Colors.white.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${List.filled(lessonCount ?? 0, '•').join()}",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color:
                        textColor ??
                        (isSpecial ? Colors.deepOrange : Colors.white),
                  ),
                ),
                Text(
                  '${day.day}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        textColor ??
                        (isSpecial ? Colors.deepOrange : Colors.white),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lunar,
                  style: TextStyle(
                    fontSize: 10,
                    color:
                        lunarColor ??
                        (isSpecial
                            ? Colors.red[600]
                            : const Color.fromARGB(255, 218, 218, 218)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<BuoiHoc> lessons) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lessons.map((lesson) {
          return glassCard(
            color: _isToDay(_selectedDay ?? _focusedDay),
            child: ListTile(
              title: Text(
                lesson.tenHP ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.thoiGian ?? '',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Giảng viên: ${lesson.giangVien}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  if ((lesson.meet ?? "").length > 8)
                    Text.rich(
                      TextSpan(
                        text: "$nhan: ${lesson.meet}",
                        style: const TextStyle(color: Colors.white70),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _launchUrl(lesson.meet ?? ''),
                      ),
                    ),
                  Text(
                    "Tiết: ${lesson.tietHoc}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    "Phòng: ${RegExp(r'<[^>]+>').hasMatch(lesson.diaDiem ?? '') ? "Online" : lesson.diaDiem}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    "Buổi số: ${lesson.buoiSo}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget renderLichThang() {
    return Scaffold(
      appBar: _appBarTitle(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/lqglss.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.6),
                  Colors.black.withOpacity(0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          RefreshIndicator(
            onRefresh: _fetch,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        rowHeight: 80,
                        locale: 'vi_VN',
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        calendarFormat: CalendarFormat.month,
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false, // để thấy nút chọn
                          formatButtonTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          formatButtonDecoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          titleCentered: true,
                          leftChevronIcon: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                          ),
                          rightChevronIcon: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),
                          titleTextStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          titleTextFormatter: (date, locale) =>
                              'Tháng ${date.month}, ${date.year}',
                        ),
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(color: Colors.white),
                          weekendStyle: TextStyle(
                            color: Color.fromARGB(255, 255, 74, 74),
                          ),
                        ),

                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) {
                            final lunar = convertToLunar(day);
                            final isSpecial = isSpecialLunarDay(lunar);

                            return _buildDayCell(
                              day: day,
                              lunar: lunar,
                              isSpecial: isSpecial,
                              textColor: Colors.white,
                              lessonCount:
                                  _lessons['${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}/${day.year}']
                                      ?.length,
                            );
                          },

                          selectedBuilder: (context, day, focusedDay) {
                            final lunar = convertToLunar(day);
                            final isSpecial = isSpecialLunarDay(lunar);

                            return _buildDayCell(
                              day: day,
                              lunar: lunar,
                              isSpecial: isSpecial,
                              textColor: isSpecial
                                  ? Colors.deepOrange
                                  : Colors.white,
                              backgroundColor: const Color.fromARGB(
                                255,
                                255,
                                255,
                                255,
                              ).withOpacity(0.3),
                              lessonCount:
                                  _lessons['${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}/${day.year}']
                                      ?.length,
                            );
                          },

                          todayBuilder: (context, day, focusedDay) {
                            final lunar = convertToLunar(day);
                            final isSpecial = isSpecialLunarDay(lunar);

                            return _buildDayCell(
                              day: day,
                              lunar: lunar,
                              isSpecial: isSpecial,
                              backgroundColor: const Color.fromARGB(
                                255,
                                0,
                                255,
                                225,
                              ).withOpacity(0.3),
                              lessonCount:
                                  _lessons['${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}/${day.year}']
                                      ?.length,
                            );
                          },

                          // ✅ Thêm outsideBuilder để hiển thị ngày âm cho ngày mờ
                          outsideBuilder: (context, day, focusedDay) {
                            final lunar = convertToLunar(day);
                            final isSpecial = isSpecialLunarDay(lunar);

                            return _buildDayCell(
                              day: day,
                              lunar: lunar,
                              isSpecial: isSpecial,
                              textColor: const Color.fromARGB(
                                255,
                                195,
                                195,
                                195,
                              ),
                              lunarColor: const Color.fromARGB(
                                255,
                                191,
                                191,
                                191,
                              ),
                              lessonCount:
                                  _lessons['${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}/${day.year}']
                                      ?.length,
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 10),
                      if (_lessons['${_selectedDay!.day.toString().padLeft(2, '0')}/${_selectedDay!.month.toString().padLeft(2, '0')}/${_selectedDay!.year}'] !=
                          null)
                        _buildCard(
                          _lessons['${_selectedDay!.day.toString().padLeft(2, '0')}/${_selectedDay!.month.toString().padLeft(2, '0')}/${_selectedDay!.year}']!,
                        )
                      else
                        glassCard(
                          color: _isToDay(_focusedDay),
                          child: const ListTile(
                            title: Text(
                              "Bạn không có lịch học...",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget glassCard({required Widget child, Color? color}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (color ?? Colors.white.withOpacity(0.15)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  bool isSameOrBefore(DateTime a, DateTime b) {
    return a.year < b.year ||
        (a.year == b.year && a.month < b.month) ||
        (a.year == b.year && a.month == b.month && a.day <= b.day);
  }

  Widget _buildActions() {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            (_danhsach ? Icons.calendar_month : Icons.list),
            color: Colors.white,
          ),
          tooltip: "Chuyển đổi giao diện",
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            setState(() {
              _danhsach = !_danhsach;
              prefs.setBool('lich_danhsach', _danhsach);
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white), // màu trắng
          tooltip: "Làm mới lịch học",
          onPressed: _fetch,
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white), // màu trắng
          tooltip: "Đăng xuất",
          onPressed: _logout,
        ),
      ],
    );
  }

  PreferredSizeWidget _appBarTitle() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: ClipRRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // hình nền cho AppBar
            Image.asset("assets/lqglss.jpg", fit: BoxFit.fitWidth),
            // hiệu ứng kính mờ
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: Colors.black.withOpacity(0.3), // overlay để chữ dễ đọc
              ),
            ),
            // AppBar thật
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                "Lịch học",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 8,
                      color: Colors.black26,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
              actions: [_buildActions()],
            ),
          ],
        ),
      ),
    );
  }
}
