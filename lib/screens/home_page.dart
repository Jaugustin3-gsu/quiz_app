import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';





class QuizHomePage extends StatefulWidget {
  @override
  _QuizHomePageState createState() => _QuizHomePageState();
}

String UserApi ='';

class _QuizHomePageState extends State<QuizHomePage> {
  int numberOfQuestions = 10;
  String selectedCategory = "9"; // Default General Knowledge
  String selectedDifficulty = "easy";
  String selectedType = "multiple";
  List<dynamic> categories = [];
   

  @override
  void initState() {
    super.initState();
    fetchCategories();
  
  }

  // Fetch categories from API
  Future<void> fetchCategories() async {
    final url = Uri.parse("https://opentdb.com/api_category.php");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        categories = data['trivia_categories'];
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to load categories"),
      ));
    }

     UserApi = 'https://opentdb.com/api.php?amount=$numberOfQuestions&category=$selectedCategory&difficulty=$selectedDifficulty&type=$selectedType';
  }

  // Generate the API URL based on user input
  String generateApiUrl() {
     UserApi = 'https://opentdb.com/api.php?amount=$numberOfQuestions&category=$selectedCategory&difficulty=$selectedDifficulty&type=$selectedType';
    return UserApi;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trivia Quiz Generator"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: categories.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Number of Questions
                  Text("Number of Questions"),
                  Slider(
                    value: numberOfQuestions.toDouble(),
                    min: 1,
                    max: 20,
                    divisions: 19,
                    label: "$numberOfQuestions",
                    onChanged: (value) {
                      setState(() {
                        numberOfQuestions = value.toInt();
                      });
                    },
                  ),
                  SizedBox(height: 16),

                  // Category
                  Text("Category"),
                  DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    items: categories.map<DropdownMenuItem<String>>((category) {
                      return DropdownMenuItem<String>(
                        value: category['id'].toString(),
                        child: Text(category['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16),

                  // Difficulty
                  Text("Difficulty"),
                  DropdownButton<String>(
                    value: selectedDifficulty,
                    isExpanded: true,
                    items: ["easy", "medium", "hard"]
                        .map<DropdownMenuItem<String>>((difficulty) {
                      return DropdownMenuItem<String>(
                        value: difficulty,
                        child: Text(difficulty),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDifficulty = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16),

                  // Type
                  Text("Type"),
                  DropdownButton<String>(
                    value: selectedType,
                    isExpanded: true,
                    items: ["multiple", "boolean"]
                        .map<DropdownMenuItem<String>>((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedType = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16),

                  // Generate Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                          UserApi = 'https://opentdb.com/api.php?amount=$numberOfQuestions&category=$selectedCategory&difficulty=$selectedDifficulty&type=$selectedType';
                          Navigator.pushNamed(context, '/quiz');
                      },
                      child: Text("Start Quiz"),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class ApiService {

  static Future<List<Question>> fetchQuestions() async {
    
    final response = await http.get(
      Uri.parse(
          UserApi),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Question> questions = (data['results'] as List)
          .map((questionData) => Question.fromJson(questionData))
          .toList();
      return questions;
    } else {
      throw Exception('Failed to load questions');
    }
  }
}