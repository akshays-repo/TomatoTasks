import 'package:flutter/material.dart';
import 'package:focus/features/sessions/session.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: (ThemeData(
        primaryColor: const Color(0xFF84CC16),
        scaffoldBackgroundColor: Colors.white,
      )),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'Pomodoro Timer',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
          ),
          actions: [
            // IconButton(
            //   icon: const Icon(Icons.sunny),
            //   onPressed: () {
            //     print('Settings button is pressed');
            //   },
            // ),
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
    ),
  );
}
