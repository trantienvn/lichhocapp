// pages/about.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lichhocapp/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});
  @override
  State<StatefulWidget> createState() => AboutPageState();
}

class AboutPageState extends State<AboutPage> {
  String fullName = '';
  String studentId = '';
  String major = '';
  String k = '';
  String className = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTT();
  }
  void getTT() async {
    
    final prefs = await SharedPreferences.getInstance();
    String msv = prefs.getString('msv') ?? '';
    String pwd = prefs.getString('pwd') ?? '';
    await ApiService.fetchLichThi(msv, pwd);

    // Lấy thông tin sinh viên từ nguồn dữ liệu nếu cần
    setState(() {
      // Cập nhật trạng thái nếu có thay đổi
      fullName = prefs.getString('name') ?? 'Chưa cập nhật';
      studentId = (prefs.getString('msv') ?? 'Chưa cập nhật').toUpperCase();
      major = prefs.getString('nganh') ?? 'Chưa cập nhật';
      k = prefs.getString('khoa') ?? 'Chưa cập nhật';
      className = prefs.getString('lop') ?? 'Chưa cập nhật';
    });
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
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
        // Lớp kính lỏng chính giữa
        Center(
          child: Container(
            margin: const EdgeInsets.all(30),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                20,
              ), // Bo góc nhiều hơn cho cảm giác "lỏng"
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 20,
                  sigmaY: 20,
                ), // Tăng cường độ blur
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(
                      0.15,
                    ), // Giảm độ trong suốt một chút
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3), // Viền nhẹ
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin sinh viên',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2, // Tăng khoảng cách chữ
                          shadows: [
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 5,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 25),
                      Text(
                        'Họ tên: $fullName',
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.white,
                          height: 1.5, // Tăng chiều cao dòng
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Mã sinh viên: $studentId',
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.white,
                          height: 1.5,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Ngành học: $major',
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.white,
                          height: 1.5,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),SizedBox(height: 12),
                      Text(
                        'Khóa học: $k',
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.white,
                          height: 1.5,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Lớp học: $className',
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.white,
                          height: 1.5,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
