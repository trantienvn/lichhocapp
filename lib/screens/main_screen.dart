import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/about.dart';
import 'pages/calendar_schedule.dart';
import 'pages/list_schedule.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

  static const List<Widget> _widgetOptions = <Widget>[
    CalendarSchedulePage(),
    ListSchedulePage(),
    AboutPage(),
  ];

  void _onItemTapped(int index) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('last_tab', index);
    setState(() {
      _selectedIndex = index;
    });
  }

  void runFirst() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedIndex = prefs.getInt('last_tab') ?? 1;
    });
  }

  @override
  void initState() {
    super.initState();
    runFirst();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // để nền ảnh extend ra sau navigation bar
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
          // Lớp kính mờ cho body
          Center(
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white.withOpacity(0.1),
                  child: _widgetOptions.elementAt(_selectedIndex),
                ),
              ),
            ),
          ),
        ],
      ),
      // >>> Kính mờ cho BottomNavigationBar <<<
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 80, // tăng chiều cao thanh nav
            padding: const EdgeInsets.only(bottom: 10), // khoảng cách dưới
            color: const Color.fromARGB(255, 190, 190, 190).withOpacity(0.2),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent, // giữ trong suốt
              elevation: 0,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 6), // đẩy icon lên
                    child: Icon(Icons.calendar_month),
                  ),
                  label: 'Lịch tháng',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Icon(Icons.list),
                  ),
                  label: 'Danh sách',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Icon(Icons.info),
                  ),
                  label: 'Thông tin',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white60,
              onTap: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}
