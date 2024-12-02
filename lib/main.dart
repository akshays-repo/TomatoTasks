
import 'package:flutter/material.dart';
import 'package:focus/ThemeManager.dart';
import 'package:focus/features/sessions/session.dart';
import 'package:focus/features/todo/todo.dart';
import 'package:provider/provider.dart';



void main() {
  return runApp(ChangeNotifierProvider<ThemeNotifier>(
    create: (_) => new ThemeNotifier(),
    child: const TomatoTasks(),
  ));
}

class TomatoTasks extends StatefulWidget {
  const TomatoTasks({super.key});

  @override
  State<TomatoTasks> createState() => _TomatoTasksState();
}

class _TomatoTasksState extends State<TomatoTasks> {
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image(image: AssetImage('icons/icon.png')),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tomato tasks',
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    Text(
                      'Manage your time in a magical way!',
                      style: TextStyle(
                          height: 1.5,
                          leadingDistribution:
                              TextLeadingDistribution.proportional,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                          fontSize: 14),
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
          body: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                      Expanded(
                          child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Session(),
                      )), // Added Expanded for layout constraint
                      Expanded(
                          child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: TodoApp(),
                      )), // Added Expanded for layout constraint
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

    });
  }
}
