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
      appBar: AppBar(
        title: const Text("Đăng nhập"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Lịch học ICTU",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _msvController,
              decoration: const InputDecoration(
                labelText: "Mã sinh viên",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pwdController,
              obscureText: _obscurePwd,
              decoration: InputDecoration(
                labelText: "Mật khẩu",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePwd ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePwd = !_obscurePwd;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text("Vào lịch học"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                ),
                onPressed: () => _login(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
