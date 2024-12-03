import 'package:flutter/material.dart';
import 'package:quiz_app/screens/home_page.dart';
import 'package:quiz_app/screens/quiz_screen.dart';
import 'screens/quiz_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trivia Quiz App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: QuizHomePage(),
      initialRoute: '/home',
      routes: {
        '/quiz': (context) => QuizScreen(),
        '/home': (context) => QuizHomePage(),
      },
    );
  }
}
