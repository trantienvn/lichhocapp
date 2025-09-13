import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lichhocapp/services/cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../component/button.dart';
import '../../models/buoi_hoc.dart';
import '../../models/mon_thi.dart';
import '../../services/api_service.dart';
import '../login_screen.dart';
import '../../lunar_converter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;
import 'package:flutter/gestures.dart';
import '../../component/dialog.dart';

class ListSchedulePage extends StatefulWidget {
  const ListSchedulePage({super.key});

  @override
  State<ListSchedulePage> createState() => _ListSchedulePageState();
}

class _ListSchedulePageState extends State<ListSchedulePage> {
  List<BuoiHoc> _lich = [];
  bool _loading = true;
  bool _hasAnError = false;
  String loaitruong = '';
  String nhan = '';
  String studentID = '';
  String fullName = '';

  final _today = DateTime.now();
  final _daysOfWeek = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ Nhật'];

  @override
  void initState() {
    super.initState();
    html.document.title = "Lịch Học";
    _loadFirst();
  }

  Future<void> _loadFirst() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    loaitruong = prefs.getString('university') ?? 'DTC';
    final msv = prefs.getString('msv') ?? '';
    final pwd = prefs.getString('pwd') ?? '';
    _checkLichThi();
    studentID = msv.toUpperCase();
    fullName = prefs.getString('name') ?? '';
    showFirstTimeDialog();
    try {
      final result = await ApiService.getLichHocFromCache(msv, pwd);
      setState(() {
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
    studentID = msv.toUpperCase();
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
    prefs.clear();
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
                  GlassmorphismButton(
                    onPressed: () => _logout(),
                    child: const Text(
                      "Đăng nhập lại",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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

 
  void showFirstTimeDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShownDialog = prefs.getBool('hasShownFirstTimeDialog') ?? false;
    if (hasShownDialog) return;
    showDialog(
      context: this.context,
      builder: (BuildContext context) {
        return LiquidGlassDialog(
          maxWidth: 650,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Xin chào!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Chào mừng bạn đến với ứng dụng Lịch Học Sinh Viên được phát triển bởi Trần Tiến!",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Add other widgets like buttons here
                const Text(
                  "Bạn có thể xem lịch học của mình theo tháng hoặc danh sách.\n Sử dụng biểu tượng lịch ở góc trên bên phải để chuyển đổi giữa các chế độ xem.",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                GlassmorphismButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    "Đóng",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    prefs.setBool('hasShownFirstTimeDialog', true);
  }

  List<MonThi> _lichThi = [];
  void _checkLichThi() async {
    final prefs = await SharedPreferences.getInstance();
    final msv = prefs.getString('msv') ?? '';
    final pwd = prefs.getString('pwd') ?? '';
    _lichThi = await ApiService.fetchLichThi(msv, pwd);
    fullName = prefs.getString('name') ?? '';
    setState(() {
      fullName = fullName;
      studentID = msv.toUpperCase();
    });
    if (_lichThi.length > 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return LiquidGlassDialog(
            maxWidth: 650,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Bạn có ${_lichThi.length} môn thi sắp tới",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: _lichThi
                            .map(
                              (mon) => glassCard(
                                child: ListTile(
                                  title: Text(
                                    mon.tenHP,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Mã HP: ${mon.maHP}",
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      Text(
                                        "Ngày Thi: ${mon.ngayThi} - Ca: ${mon.caThi}",
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      Text(
                                        "Hình Thức: ${mon.hinhThucThi}",
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      Text(
                                        "Phòng Thi: ${mon.phongThi}",
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      if (mon.soBaoDanh.isNotEmpty)
                                        Text(
                                          "Số Báo Danh: ${mon.soBaoDanh}",
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      if (mon.ghiChu.isNotEmpty)
                                        Text(
                                          "Ghi Chú: ${mon.ghiChu}",
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  GlassmorphismButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "Đóng",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    return;
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
            Image.asset("assets/lqglss.jpg", fit: BoxFit.cover),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: Colors.black.withOpacity(
                  0.3,
                ), // Overlay for better readability
              ),
            ),
            // Actual AppBar
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
              title: Column(
                // Use a Column to stack the title, name, and ID
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: TextStyle(
                      fontSize: 20,
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
                  Text(
                    studentID, // User ID
                    style: const TextStyle(fontSize: 14, color: Colors.white60),
                  ),
                ],
              ),
              actions: [_buildActions()],
            ),
          ],
        ),
      ),
    );
  }
}
