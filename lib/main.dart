import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/main_screen.dart';
void main() {
  initializeDateFormatting('vi_VN', null).then((_) {
    runApp(
      MaterialApp(
        title: 'Lịch Học',
        theme: ThemeData(primarySwatch: Colors.blue),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  });
}
