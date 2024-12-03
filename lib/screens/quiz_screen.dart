import 'package:flutter/material.dart';
import '../models/question.dart';
import 'dart:async';
import 'home_page.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _loading = true;
  bool _answered = false;
  String _selectedAnswer = "";
  String _feedbackText = "";

  int _remainingTime = 15; // Timer for 30 seconds
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer when widget is disposed
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await ApiService.fetchQuestions();
      setState(() {
        _questions = questions;
        _loading = false;
      });
      _startTimer(); // Start the timer after questions are loaded
    } catch (e) {
      print(e);
      // Handle error appropriately
    }
  }

  void _startTimer() {
    _remainingTime = 15; // Reset the timer
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          timer.cancel();
          _autoNextQuestion(); // Auto move to next question if time runs out
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _submitAnswer(String selectedAnswer) {
    _stopTimer(); // Stop the timer when an answer is submitted
    setState(() {
      _answered = true;
      _selectedAnswer = selectedAnswer;

      final correctAnswer = _questions[_currentQuestionIndex].correctAnswer;
      if (selectedAnswer == correctAnswer) {
        _score++;
        _feedbackText = "Correct! The answer is $correctAnswer.";
      } else {
        _feedbackText = "Incorrect. The correct answer is $correctAnswer.";
      }
    });
  }

  void _autoNextQuestion() {
    setState(() {
      _answered = true;
      _selectedAnswer = "Time's up!";
      _feedbackText =
          "Time's up! The correct answer is ${_questions[_currentQuestionIndex].correctAnswer}.";
    });
    //Future.delayed(Duration(seconds: 2), _nextQuestion); // Wait before moving to next
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _answered = false;
        _selectedAnswer = "";
        _feedbackText = "";
        _currentQuestionIndex++;
      });
      _startTimer(); // Restart the timer for the next question
    } else {
      // Quiz ends
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('Quiz Finished! Your Score: $_score/${_questions.length}'),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildOptionButton(String option) {
    return ElevatedButton(
      onPressed: _answered ? null : () => _submitAnswer(option),
      child: Text(option),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentQuestionIndex >= _questions.length) {
      return Scaffold(
        body: Center(
          child: Text('Quiz Finished! Your Score: $_score/${_questions.length}',
          style: TextStyle(fontSize: 18),),
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Quiz App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timer Display
            Text(
              "Time Remaining: $_remainingTime seconds",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Question ${_currentQuestionIndex + 1}/${_questions.length}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            if (_answered)
              Text(
                'Score ${((_score/(_currentQuestionIndex + 1))*100).round()}%',
                style: TextStyle(
                  fontSize: 18,
                  color: (_score/(_currentQuestionIndex+1)*100) > 75 
                  ? Colors.green
                  : (_score/(_currentQuestionIndex+1)*100) <=50 
                  ? Colors.red : Colors.yellow
                ),
                ),
            SizedBox(height: 16),
            Text(
              question.question,
              style: TextStyle(fontSize: 18),
            ),
            
            SizedBox(height: 16),
            ...question.options.map((option) => _buildOptionButton(option)),
            SizedBox(height: 20),
            if (_answered)
              Text(
                _feedbackText,
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedAnswer == question.correctAnswer
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            if (_answered)
              ElevatedButton(
                onPressed: _nextQuestion,
                child: Text('Next Question'),
              ),
          ],
        ),
      ),
    );
  }
}
