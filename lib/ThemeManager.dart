import 'package:flutter/material.dart';
import 'package:focus/StorageManager.dart';

class ThemeNotifier with ChangeNotifier {
  final darkTheme = ThemeData(
  
    primaryColor: const Color(0xFF84CC16),
    brightness: Brightness.dark,
    iconTheme: const IconThemeData(color: Color(0xFF84CC16)),

  );

  final lightTheme = ThemeData(
    primaryColor: const Color(0xFF84CC16),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
    ),
      textTheme:
          const TextTheme(bodyMedium: TextStyle(color: Color(0xFF71717A))),
    iconTheme: const IconThemeData(color: Color(0xFF84CC16)),

  );

  late ThemeData _themeData = lightTheme;

  ThemeData getTheme() => _themeData;

  getMode() => _themeData == darkTheme ? 'dark' : 'light';

  ThemeNotifier() {
    StorageManager.readData('themeMode').then((value) {
      print('value read from storage: ' + value.toString());
      var themeMode = value ?? 'light';
      if (themeMode == 'light') {
        _themeData = lightTheme;
      } else {
        print('setting dark theme');
        _themeData = darkTheme;
      }
      notifyListeners();
    });
  }

  void setDarkMode() async {
    _themeData = darkTheme;
    StorageManager.saveData('themeMode', 'dark');
    notifyListeners();
  }

  void setLightMode() async {
    _themeData = lightTheme;
    StorageManager.saveData('themeMode', 'light');
    notifyListeners();
  }
}
