import 'package:shared_preferences/shared_preferences.dart';

class TimerPreferences {
  static const String _focusTimeKey = 'focusTime';
  static const String _shortBreakKey = 'shortBreakTime';
  static const String _longBreakKey = 'longBreakTime';

  // Save durations
  static Future<void> saveTimerDurations({
    required int focusTime,
    required int shortBreakTime,
    required int longBreakTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_focusTimeKey, focusTime);
    await prefs.setInt(_shortBreakKey, shortBreakTime);
    await prefs.setInt(_longBreakKey, longBreakTime);
  }

  // Load durations with default values
  static Future<Map<String, int>> loadTimerDurations() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'focusTime': prefs.getInt(_focusTimeKey) ?? 1500, // Default 25 mins
      'shortBreakTime': prefs.getInt(_shortBreakKey) ?? 300, // Default 5 mins
      'longBreakTime': prefs.getInt(_longBreakKey) ?? 900, // Default 15 mins
    };
  }
}
