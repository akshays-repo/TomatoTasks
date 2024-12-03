import 'package:flutter/material.dart';
import 'package:focus/ThemeManager.dart';
import 'package:focus/features/sessions/utils.dart';
import 'package:focus/main.dart';
import 'package:provider/provider.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:audioplayers/audioplayers.dart';

import 'session.storage.dart';

// utils
const disabledButtonOpacity = 0.35;

const focusColor = Color(0xFF84CC16);
const shortBreakColor = Color(0xFFF59E0B);
const longBreakColor = Color(0xFF06B6D4);

// Enum to represent different session types
enum SessionType { focus, shortBreak, longBreak }

// Enum to represent different countdown status
enum CountdownStatus { notStarted, started, paused, finished }

// dart method convert seconds to minutes
String timeToDisplay(int time) {
  int minutes = time ~/ 60;
  int seconds = time % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

class Session extends StatefulWidget {
  const Session({super.key});

  @override
  State<Session> createState() => _SessionState();
}

class _SessionState extends State<Session> {
  final mainPlayer = AudioPlayer(playerId: 'main-player');
  final finishedPlayer = AudioPlayer(playerId: 'finished-player');

  final CountdownController _controller =
      new CountdownController(autoStart: false);

  // Controllers for the dialog fields
  late TextEditingController _focusTimeController;
  late TextEditingController _shortBreakController;
  late TextEditingController _longBreakController;

// states
  SessionType sessionType = SessionType.focus;

  int counterTimeDuration = focusDurationDefault;

  Color countDownRingColor = focusColor;

  CountdownStatus countdownStatus = CountdownStatus.notStarted;

  int totalStreaks = 0;

  int focusTime = focusDurationDefault; // Default: 25 minutes
  int shortBreakTime = shortBreakDurationDefault; // Default: 5 minutes
  int longBreakTime = longBreakDurationDefault; // Default: 15 minutes

  // getters
  bool get isPlaying =>
      countdownStatus == CountdownStatus.started ? true : false;

  bool get isPaused => countdownStatus == CountdownStatus.paused;

  bool get isFocus => sessionType == SessionType.focus;

  bool get isShortBreak => sessionType == SessionType.shortBreak;

  bool get isLongBreak => sessionType == SessionType.longBreak;

  bool get isNotStarted => countdownStatus == CountdownStatus.notStarted;

  bool get isFinished => countdownStatus == CountdownStatus.finished;

  bool Function(bool isActive) get isSessionButtonEnabled =>
      (bool isActive) => isNotStarted || isActive || isPaused || isFinished;

  String get currentSessionType {
    switch (sessionType) {
      case SessionType.focus:
        return 'Focus';
      case SessionType.shortBreak:
        return 'Short Break';
      case SessionType.longBreak:
        return 'Long Break';
    }
  }

  IconData get sessionIcon {
    switch (sessionType) {
      case SessionType.focus:
        return Icons.center_focus_strong_outlined;
      case SessionType.shortBreak:
        return Icons.coffee_maker_outlined;
      case SessionType.longBreak:
        return Icons.gamepad_outlined;
    }
  }

  // handle click play button
  Future<void> startTimer() async {
    _controller.start();
    setState(() {
      countdownStatus = CountdownStatus.started;
    });

    await mainPlayer.stop();
    await mainPlayer.setSource(AssetSource('sounds/ticking-clock.mp3'));
    await mainPlayer.setReleaseMode(ReleaseMode.loop);
    await mainPlayer.resume();
  }

  // handle click pause button
  Future<void> pauseTimer() async {
    _controller.pause();

    await mainPlayer.pause();

    setState(() {
      countdownStatus = CountdownStatus.paused;
    });
  }

  // handle click reset button
  Future<void> resetTimer() async {
    _controller.restart();
    _controller.pause();
    await mainPlayer.pause();

    setState(() {
      countdownStatus = CountdownStatus.notStarted;
      counterTimeDuration = focusTime;
      sessionType = SessionType.focus;
      countDownRingColor = focusColor;
    });
  }

  Future<void> handleOnFinished() async {
    _controller.restart();
    _controller.pause();
    await mainPlayer.pause();
    await finishedPlayer.setSource(AssetSource('sounds/success.mp3'));
    await finishedPlayer.resume();
    setState(() {
      countdownStatus = CountdownStatus.finished;
      totalStreaks++;

      if (isFocus) {
        changeSessionType(SessionType.shortBreak);
      } else {
        changeSessionType(SessionType.focus);
      }
    });
  }

  // handle click session type button
  void changeSessionType(SessionType newSessionType) {
    setState(() {
      sessionType = newSessionType;
    });

    switch (sessionType) {
      case SessionType.focus:
        setState(() {
          counterTimeDuration = focusTime;
          countDownRingColor = focusColor;
        });
        break;
      case SessionType.shortBreak:
        setState(() {
          counterTimeDuration = shortBreakTime;
          countDownRingColor = shortBreakColor;
        });
        break;
      case SessionType.longBreak:
        setState(() {
          counterTimeDuration = longBreakTime;
          countDownRingColor = longBreakColor;
        });
        break;
    }
  }

  Future<void> loadTimerDurations() async {
    Map<String, int> timers = await TimerPreferences.loadTimerDurations();
    setState(() {
      focusTime = timers['focusTime'] ?? focusDurationDefault;
      shortBreakTime = timers['shortBreakTime'] ?? shortBreakDurationDefault;
      longBreakTime = timers['longBreakTime'] ?? longBreakDurationDefault;

      switch (sessionType) {
        case SessionType.focus:
          counterTimeDuration = focusTime;
          break;
        case SessionType.shortBreak:
          counterTimeDuration = shortBreakTime;
          break;
        case SessionType.longBreak:
          counterTimeDuration = longBreakTime;
          break;
        default:
      }

      // Initialize controllers with loaded values
      _focusTimeController =
          TextEditingController(text: (focusTime ~/ 60).toString());
      _shortBreakController =
          TextEditingController(text: (shortBreakTime ~/ 60).toString());
      _longBreakController =
          TextEditingController(text: (longBreakTime ~/ 60).toString());
      _controller.restart();
      _controller.pause();
    });
  }

  // Save data using TimerPreferences class
  Future<void> saveTimerDurations() async {
    await TimerPreferences.saveTimerDurations(
      focusTime: int.parse(_focusTimeController.text) * 60,
      shortBreakTime: int.parse(_shortBreakController.text) * 60,
      longBreakTime: int.parse(_longBreakController.text) * 60,
    );

    // Reload values to update the UI
    loadTimerDurations();
  }

  @override
  void initState() {
    super.initState();
    loadTimerDurations(); // Load data when the widget initializes
  }

  // dispose players , counter
  @override
  void dispose() {
    // Release any resources held by this object.
    // For example, stop any active animations.
    super.dispose(); // Always call super.dispose() at the end.

    mainPlayer.dispose();
    finishedPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(builder: (context, theme, _) {
      final isLightMode = theme.getMode() == 'light';


      return SingleChildScrollView(
        child: Container(
          // width: MediaQuery.of(context).size.width * 0.5,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
              color: isLightMode
                  ? const Color(0xFFFAFAFA)
                  : const Color(0xFF18181B),
              border: isLargerDevice(context)
                  ? Border.all(
                color: const Color(0xFFE4E4E7), // Border color
                width: 1.0, // Border width
                    )
                  : null,
              borderRadius: BorderRadius.circular(15.0)),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Mode',
                    style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500),
                  ),
                  Row(
                    children: [
                      Text(
                        '$currentSessionType',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: countDownRingColor),
                      ),
                      SizedBox(width: 8),
                      Icon(sessionIcon, color: countDownRingColor, size: 20)
                    ],
                  ),
                ],
              ),
              const Divider(
                color: Color(0xFFE4E4E7),
                thickness: 1.0,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Countdown(
                    controller: _controller,
                    seconds: counterTimeDuration,
                    build: (BuildContext context, double time) =>
                        new CircularPercentIndicator(
                      radius: (MediaQuery.of(context).size.height * 0.3) / 2,
                      animation: false,
                      animationDuration: 0,
                      lineWidth: 15.0,
                      percent: 1.0 - time / counterTimeDuration,
                      center: Text(
                        timeToDisplay(time.toInt()),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 44.0),
                      ),
                      circularStrokeCap: CircularStrokeCap.butt,
                      backgroundColor: const Color(0xFFF4F4F5),
                      progressColor: countDownRingColor,
                    ),
                    interval: const Duration(seconds: 1),
                    onFinished: handleOnFinished,
                  ),

                  // Session type
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 0.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      direction: Axis.horizontal,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Opacity(
                          opacity: !isSessionButtonEnabled(isFocus)
                              ? disabledButtonOpacity
                              : 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextButton.icon(
                              style: ButtonStyle(
                                side: WidgetStateProperty.all<BorderSide>(
                                  const BorderSide(
                                    color: Color(0xFF84CC16),
                                    width: 1.0,
                                  ),
                                ),
                                backgroundColor: WidgetStateProperty.all<Color>(
                                  const Color.fromARGB(17, 131, 204, 22),
                                ),
                                shape: WidgetStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                              ),
                              onPressed: isSessionButtonEnabled(isFocus)
                                  ? () {
                                      changeSessionType(SessionType.focus);
                                    }
                                  : null,
                              label: Text(
                                'Focus : ${timeToDisplay(focusTime.toInt())} min',
                                style: const TextStyle(
                                    color: focusColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              icon: const Icon(
                                Icons.center_focus_strong_outlined,
                                color: focusColor,
                                size: 12,
                              ),
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: !isSessionButtonEnabled(isShortBreak)
                              ? disabledButtonOpacity
                              : 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextButton.icon(
                              style: ButtonStyle(
                                side: WidgetStateProperty.all<BorderSide>(
                                  const BorderSide(
                                    color: shortBreakColor,
                                    width: 1.0,
                                  ),
                                ),
                                backgroundColor: WidgetStateProperty.all<Color>(
                                  const Color.fromRGBO(245, 159, 11, 0.103),
                                ),
                                shape: WidgetStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                              ),
                              onPressed: isSessionButtonEnabled(isShortBreak)
                                  ? () {
                                      changeSessionType(SessionType.shortBreak);
                                    }
                                  : null,
                              label: Text(
                                'Short Break :  ${timeToDisplay(shortBreakTime.toInt())} min',
                                style: const TextStyle(
                                    color: shortBreakColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              icon: const Icon(
                                Icons.coffee_maker_outlined,
                                color: shortBreakColor,
                                size: 12,
                              ),
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: !isSessionButtonEnabled(isLongBreak)
                              ? disabledButtonOpacity
                              : 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextButton.icon(
                              style: ButtonStyle(
                                side: WidgetStateProperty.all<BorderSide>(
                                  const BorderSide(
                                    color: longBreakColor,
                                    width: 1.0,
                                  ),
                                ),
                                backgroundColor: WidgetStateProperty.all<Color>(
                                  const Color.fromRGBO(6, 181, 212, 0.103),
                                ),
                                shape: WidgetStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                              ),
                              onPressed: isSessionButtonEnabled(isLongBreak)
                                  ? () {
                                      changeSessionType(SessionType.longBreak);
                                    }
                                  : null,
                              label: Text(
                                'Long Break :  ${timeToDisplay(longBreakTime.toInt())} min',
                                style: const TextStyle(
                                    color: longBreakColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              icon: const Icon(
                                Icons.gamepad_outlined,
                                color: longBreakColor,
                                size: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Play, Pause, and reset buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          tooltip: 'Settings',
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(
                              isLightMode
                                  ? const Color(0xFFF4F4F5)
                                  : const Color(0xFF52525B),
                            ),
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          icon: Icon(
                            Icons.settings,
                            color:
                                isLightMode ? Colors.black12 : Colors.white38,
                          ),
                          onPressed:
                              isPlaying ? null : () => _dialogBuilder(context),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            tooltip: isPlaying ? 'Pause' : 'Play',
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                isLightMode
                                    ? const Color(0xFFF4F4F5)
                                    : const Color(0xFF52525B),
                              ),
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                            icon: Icon(
                              isPlaying
                                  ? Icons.pause_circle_filled_outlined
                                  : Icons.play_arrow_outlined,
                              color: countDownRingColor,
                              size: 44,
                            ),
                            onPressed: () {
                              if (isPlaying) {
                                pauseTimer();
                              } else {
                                startTimer();
                              }
                            },
                          ),
                        ),
                        IconButton(
                            tooltip: 'Reset',
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                isLightMode
                                    ? const Color(0xFFF4F4F5)
                                    : const Color(0xFF52525B),
                              ),
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                            icon: Icon(
                              Icons.restore,
                              color:
                                  isLightMode ? Colors.black12 : Colors.white38,
                            ),
                            onPressed: resetTimer),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      );
    }
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Focus timer input field
              TextFormField(
                controller: _focusTimeController,
                decoration: const InputDecoration(
                  labelText: 'Focus Timer (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),

              // Short break timer input field
              TextFormField(
                controller: _shortBreakController,
                decoration: const InputDecoration(
                  labelText: 'Short Break Timer (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),

              // Long break timer input field
              TextFormField(
                controller: _longBreakController,
                decoration: const InputDecoration(
                  labelText: 'Long Break Timer (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Apply'),
              onPressed: () {
                saveTimerDurations(); // Save changes
                Navigator.of(context).pop(); // Close dialog
              },
            ),
          ],
        );
      },
    );
  }
}
