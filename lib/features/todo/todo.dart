import 'package:flutter/material.dart';
import 'package:focus/ThemeManager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TodoApp extends StatefulWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      try {
        setState(() {
          _tasks = List<Map<String, dynamic>>.from(json.decode(tasksJson));
        });
      } catch (e) {
        print("Error decoding tasks: $e");
      }
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', json.encode(_tasks));
  }

  void _addTask(String taskText) {
    if (taskText.isNotEmpty) {
      setState(() {
        _tasks.add({'title': taskText, 'completed': false});
        _controller.clear();
      });
      _saveTasks();
    }
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index]['completed'] = !_tasks[index]['completed'];
    });
    _saveTasks();
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(builder: (context, theme, _) {
      final isLightMode = theme.getMode() == 'light';

      return Container(
        padding: const EdgeInsets.all(12.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Text(
                'Todo list',
                style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500),
              ),
              Expanded(
                child: _tasks.isEmpty
                    ? const Center(
                        child: Text(
                          'No tasks added yet!',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
                          return ListTile(
                            title: Text(
                              task['title'],
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                decoration: task['completed']
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            leading: Checkbox(
                              checkColor: Theme.of(context).primaryColor,
                              fillColor: WidgetStateProperty.all(
                                isLightMode
                                    ? Color(0XffF4F4F5)
                                    : Colors.grey[800],
                              ),
                              value: task['completed'],
                              onChanged: (_) => _toggleTaskCompletion(index),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeTask(index),
                            ),
                          );
                        },
                      ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          filled: true,
                          hintText: 'Enter a task',
                          fillColor: isLightMode
                              ? const Color(0xfff4f4f5)
                              : const Color(0xff27272A)),
                      onSubmitted: (_) => _addTask(_controller.text),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.add,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () => _addTask(_controller.text),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    );
  }
}
