import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lich_hoc_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final msv = prefs.getString('msv');
    final pwd = prefs.getString('pwd');
    if (msv != null && pwd != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LichHocScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator()));
}
