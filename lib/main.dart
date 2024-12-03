import 'package:flutter/material.dart';
import 'package:focus/ThemeManager.dart';
import 'package:focus/features/sessions/session.dart';
import 'package:focus/features/todo/todo.dart';
import 'package:provider/provider.dart';

bool isLargerDevice(BuildContext context) {
  return MediaQuery.of(context).size.width >= 1000;
}

void main() {
  runApp(ChangeNotifierProvider<ThemeNotifier>(
    create: (_) => ThemeNotifier(),
    child: const TomatoTasks(),
  ));
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
        home: Scaffold(
          appBar: AppBar(
            title: const Row(
              children: [
                Image(image: AssetImage('icons/icon.png')),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tomato Tasks',
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
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
        ),
      );
    });
  }
}
