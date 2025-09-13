import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../component/button.dart';
import 'main_screen.dart';
import '../services/api_service.dart';
import 'dart:html' as html;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _msvController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final FocusNode _msvFocusNode = FocusNode();
  final FocusNode _pwdFocusNode = FocusNode();
  bool _obscurePwd = true;
  bool _hasAnError = false;
  String msg = '';
  @override
  void dispose() {
    _msvController.dispose();
    _pwdController.dispose();
    _msvFocusNode.dispose();
    _pwdFocusNode.dispose();
    super.dispose();
  }

  void _login(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final msv = _msvController.text.trim();
    final pwd = _pwdController.text.trim();
    if (msv.isEmpty || pwd.isEmpty) {
      setState(() {
        _hasAnError = true;
        msg = "Vui lòng nhập đầy đủ thông tin.";
      });
      return;
    }
    await prefs.setString('msv', msv);
    await prefs.setString('pwd', pwd);
    await prefs.setString('university', msv.substring(0, 3).toUpperCase());
    try {
      // Thử lấy lịch để kiểm tra thông tin đăng nhập
      await ApiService.fetchLichThi(msv, pwd);
      await prefs.setBool('hasLogin', true);
      Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
    } catch (e) {
      setState(() {
        _hasAnError = true;
        msg = "Đăng nhập thất bại: $e";
      });
      return;
    }
    
  }

  @override
  Widget build(BuildContext context) {
    html.document.title = "Lịch Học - Đăng Nhập";
    return Scaffold(
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
                  Colors.black.withOpacity(0.6),
                  Colors.blue.withOpacity(0.3),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: AutofillGroup(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Đăng Nhập",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 350,
                        child: TextFormField(
                          controller: _msvController,
                          focusNode: _msvFocusNode,
                          autofillHints: const [AutofillHints.username],
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Mã sinh viên",
                            labelStyle: const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_pwdFocusNode);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 350,
                        child: TextFormField(
                          controller: _pwdController,
                          focusNode: _pwdFocusNode,
                          autofillHints: const [AutofillHints.password],
                          obscureText: _obscurePwd,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Mật khẩu",
                            labelStyle: const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.white,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePwd
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePwd = !_obscurePwd;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onFieldSubmitted: (_) {
                            _login(context);
                          },
                        ),
                      ),
                      // const SizedBox(height: 20),
                      ..._hasAnError? [const SizedBox(height: 20),Text(
                        msg,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 101, 101),
                          fontSize: 16,
                        ),
                      )] : [
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 200,
                        child: GlassmorphismButton(
                          onPressed: () => _login(context),
                          child: const Text(
                            "Đăng Nhập",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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
}

