import 'package:flutter/material.dart';
import 'package:focus/ThemeManager.dart';
import 'package:focus/features/sessions/session.dart';
import 'package:focus/features/todo/todo.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Function to check if the user has already seen the onboarding screen
Future<bool> _hasSeenOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('hasSeenOnboarding') ?? false;
}

// Function to save the fact that onboarding has been shown
Future<void> _setOnboardingShown() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('hasSeenOnboarding', true);
}

bool isLargerDevice(BuildContext context) {
  return MediaQuery.of(context).size.width >= 1000;
}

void main() {
  runApp(ChangeNotifierProvider<ThemeNotifier>(
    create: (_) => ThemeNotifier(),
    child: const TomatoTasks(),
  ));
}

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // network image
                Center(
                  child: Image(
                    image: AssetImage('assets/images/pomodoro.png'),
                    fit: BoxFit.fitWidth,
                    height: MediaQuery.of(context).size.height * 0.8,
                  ),
                ),
                SizedBox(height: 16),
                OutlinedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                      Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    await _setOnboardingShown();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => TomatoTasks()),
                    );
                  },
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 18),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to mark onboarding as completed
  Future<void> _setOnboardingShown() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('hasSeenOnboarding', true);
  }
}

class TomatoTasks extends StatefulWidget {
  const TomatoTasks({super.key});

  @override
  State<TomatoTasks> createState() => _TomatoTasksState();
}

class _TomatoTasksState extends State<TomatoTasks> {
  int _selectedIndex = 0; // Track selected tab index

  // Widgets for bottom navigation
  static const List<Widget> _widgetOptions = <Widget>[
    Session(),
    TodoApp(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(builder: (context, theme, _) {
      final isLightMode = theme.getMode() == 'light';

      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme.getTheme(),
        home: FutureBuilder<bool>(
          future: _hasSeenOnboarding(),
          builder: (context, snapshot) {
            // Show the onboarding screen if it's the user's first time
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data == false) {
              return OnboardingScreen();
            }

            // Show the main app screen
            return Scaffold(
              appBar: AppBar(
                backgroundColor: isLightMode ? Colors.white : Colors.black,
                title: const Row(
                  children: [
                    Image(image: AssetImage('assets/icons/icon.png')),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tomato Tasks',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                        Text(
                          'Manage your time in a magical way!',
                          style: TextStyle(
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: isLightMode
                        ? const Icon(Icons.sunny)
                        : const Icon(Icons.nightlight_round),
                    onPressed: () {
                      isLightMode ? theme.setDarkMode() : theme.setLightMode();
                    },
                  ),
                ],
              ),
              body: isLargerDevice(context)
                  ? const Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Session(),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: TodoApp(),
                          ),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _widgetOptions[_selectedIndex],
                    ), // Display selected widget

              bottomNavigationBar: !isLargerDevice(context)
                  ? BottomNavigationBar(
                      backgroundColor:
                          isLightMode ? Colors.white : Colors.black,

                      currentIndex: _selectedIndex,
                      onTap: _onItemTapped,
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(
                            Icons.timer,
                            color: Color(0xFF84CC16),
                          ),
                          label: 'Session',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.checklist, color: Color(0xFF84CC16)),
                          label: 'To-do',
                        ),
                      ],
                    )
                  : null, // No bottom navigation on large devices
            );
          },
        ),
      );
    });
  }
}
