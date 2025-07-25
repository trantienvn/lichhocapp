import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lich_hoc_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _msvController = TextEditingController();
  final _pwdController = TextEditingController();
  bool _obscurePwd = true;

  void _login(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final msv = _msvController.text.trim();
    final pwd = _pwdController.text.trim();
    if (msv.isEmpty || pwd.isEmpty) return;
    await prefs.setString('msv', msv);
    await prefs.setString('pwd', pwd);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LichHocScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 228, 255), // nền trắng
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Đăng nhập vào Lịch Học",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 107, 0, 114),
                ),
              ),
              const SizedBox(height: 32),

              // Card chứa ô nhập
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color.fromARGB(
                    255,
                    244,
                    172,
                    255,
                  ), // tím nhạt giống lich_hoc_screen
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _msvController,
                      decoration: InputDecoration(
                        labelText: "Mã sinh viên",
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _pwdController,
                      obscureText: _obscurePwd,
                      decoration: InputDecoration(
                        labelText: "Mật khẩu",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePwd
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePwd = !_obscurePwd;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: const Text(
                    "Vào lịch học",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                      255,
                      114,
                      0,
                      156,
                    ), // hoặc tím đậm nếu muốn đồng bộ hơn
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _login(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
