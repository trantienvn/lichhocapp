import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lich_hoc_screen.dart';
import 'dart:html' as html;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _msvController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  bool _obscurePwd = true;

  void _login(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final msv = _msvController.text.trim();
    final pwd = _pwdController.text.trim();
    if (msv.isEmpty || pwd.isEmpty) return;
    await prefs.setString('msv', msv);
    await prefs.setString('pwd', pwd);
    await prefs.setString('university', msv.substring(0, 3).toUpperCase());
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LichHocScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    html.document.title = "Lịch Học - Đăng Nhập";
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ảnh nền
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/lqglss.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay màu
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
          // Nội dung login
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

                      // Ô nhập MSV
                      SizedBox(
                        width: 350,
                        child: TextFormField(
                          controller: _msvController,
                          autofillHints: const [AutofillHints.username],
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Mã sinh viên",
                            labelStyle:
                                const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(Icons.person,
                                color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Ô nhập mật khẩu
                      SizedBox(
                        width: 350,
                        child: TextFormField(
                          controller: _pwdController,
                          autofillHints: const [AutofillHints.password],
                          obscureText: _obscurePwd,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Mật khẩu",
                            labelStyle:
                                const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(Icons.lock,
                                color: Colors.white),
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
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Nút đăng nhập
                      SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: ()=>_login(context),
                          child: const Text(
                            "Đăng Nhập",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
