
import 'package:flutter/material.dart';
import 'package:focus/ThemeManager.dart';
import 'package:focus/features/sessions/session.dart';
import 'package:provider/provider.dart';



void main() {
  return runApp(ChangeNotifierProvider<ThemeNotifier>(
    create: (_) => new ThemeNotifier(),
    child: TomatoTasks(),
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
                    )
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
              // IconButton(
              //   icon: const Icon(Icons.code),
              //   onPressed: () {
              //     print('Settings button is pressed');
              //   },
              // ),
            ],
          ),
          body: const SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Session(),

                // Todo()
              ],
            ),
          ),
        ),
      );
    });
  }
}
