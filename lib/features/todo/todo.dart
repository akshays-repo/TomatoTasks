import 'package:flutter/material.dart';

class Todo extends StatelessWidget {
  const Todo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text('Todo'),
          Text('Task 1'),
          Text('Task 2'),
          Text('Task 3'),
          ElevatedButton(
            onPressed: () {
              print('Add button is pressed');
            },
            child: Text('Add'),
          ),
          ElevatedButton(
            onPressed: () {
              print('Remove button is pressed');
            },
            child: Text('Remove'),
          ),
        ],
      ),
    );
  }
}
