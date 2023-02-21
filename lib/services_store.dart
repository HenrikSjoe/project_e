import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:collection';

class ServicesStore extends StatefulWidget {
  @override
  _ServicesStoreState createState() => _ServicesStoreState();
}

Future<void> signOut() async {
  try {
    await FirebaseAuth.instance.signOut();
  } catch (e) {
    print(e.toString());
  }
}

class _ServicesStoreState extends State<ServicesStore> {
  CollectionReference _collectionRef = FirebaseFirestore.instance
      .collection('categories')
      .doc('BKVP2YeUoX11f5BZbSTZ')
      .collection('questions');

  bool _isSubmitted = false;
  int _questionIndex = 0;
  int _correctAnswers = 0;
  List<Map<String, dynamic>> allData = [];
  bool _isLoading = true;
  String _userAnswer = "";
  TextEditingController _textController = TextEditingController();
  Color _submitButtonColor = Colors.blue;

  List<String> _selectedAnswers = [];
  bool _multiAnswerCheck(
      List<String> selectedAnswers, List<String> correctAnswers) {
    Set<String> selectedSet = Set.from(selectedAnswers);
    Set<String> correctSet = Set.from(correctAnswers);
    return selectedSet.length == correctSet.length &&
        selectedSet.containsAll(correctSet);
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await _collectionRef.get();

    // Get data from docs and convert map to List
    allData = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    setState(() {
      _isLoading = false;
    });
  }

  void _checkSingleAnswer() {
    _userAnswer = "";
    _textController.clear();
    if (allData[_questionIndex]['correctAnswer'].compareTo(_userAnswer) == 0) {
      setState(() {
        _correctAnswers++;
      });
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _questionIndex++;
      });
    });
  }

  void _checkMultipleAnswer() {
    List<String> multiCorrects =
        allData[_questionIndex]['multiCorrects'].cast<String>();
    Set<String> selectedSet = Set.from(_selectedAnswers);
    Set<String> correctSet = Set.from(multiCorrects);
    bool allCorrect = selectedSet.length == correctSet.length &&
        selectedSet.containsAll(correctSet);
    if (allCorrect) {
      _correctAnswers++;
      setState(() {
        _submitButtonColor = Colors.green; // set color to green
      });
    } else {
      setState(() {
        _submitButtonColor = Colors.red; // set color to red
      });
    }
    _selectedAnswers.clear();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _questionIndex++;
        _submitButtonColor = Colors.blue; // reset color to blue
      });
    });
  }

  void _checkAnswer() {
    if (allData[_questionIndex]['multiAnswer'] == true) {
      if (allData[_questionIndex]['multiCorrect'] == true) {
        _checkMultipleAnswer();
      } else {
        _checkSingleAnswer();
      }
    } else {
      if (_userAnswer.isNotEmpty) {
        List<String> keywords =
            (allData[_questionIndex]['keywords'] as List<dynamic>)
                .map((k) => k.toString().toLowerCase().trim())
                .toList();

        int count = 0;
        for (String keyword in keywords) {
          if (_userAnswer.toLowerCase().contains(keyword)) {
            count++;
          }
        }

        double keywordMatch = count / keywords.length;

        if (keywordMatch >= 0.5 ||
            _userAnswer == allData[_questionIndex]['correctAnswer']) {
          _correctAnswers++;
        }
        _userAnswer = "";
        _textController.clear();
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            _questionIndex++;
          });
        });
      }
    }
  }

  Widget _buildQuestionWidget() {
    if (_questionIndex >= allData.length) {
      return Center(
        child: Text(
          "You had $_correctAnswers correct answers out of ${allData.length} questions",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      );
    }

    final isMultiAnswer = allData[_questionIndex]['multiAnswer'];
    final isMultiCorrect = allData[_questionIndex]['multiCorrect'];
    final question = allData[_questionIndex]['question'];

    if (isMultiAnswer) {
      if (isMultiCorrect) {
        return _buildMultipleCorrectAnswersQuestion(question);
      } else {
        return _buildSingleCorrectAnswerQuestion(question);
      }
    } else {
      return _buildFreeTextQuestion(question);
    }
  }

  Widget _buildFreeTextQuestion(String question) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Text(
            question,
            style: TextStyle(fontSize: 25, fontFamily: 'Elgiganten8'),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(20),
            child: TextField(
              style: TextStyle(fontSize: 25, fontFamily: 'Elgiganten3'),
              controller: _textController,
              onChanged: (value) {
                setState(() {
                  _userAnswer = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Type your answer here",
              ),
            ),
          ),
        ),
        ElevatedButton(
          child: Text("Submit"),
          onPressed: _userAnswer.isNotEmpty
              ? () {
                  setState(() {
                    _checkAnswer();
                    if (_correctAnswers > 0) {
                      _submitButtonColor = Colors.green;
                    } else {
                      _submitButtonColor = Colors.red;
                    }
                  });
                }
              : null,
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(_submitButtonColor),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleCorrectAnswerQuestion(String question) {
    List<String> answers = allData[_questionIndex]['answers'].cast<String>();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Text(
            question,
            style: TextStyle(fontSize: 25, fontFamily: 'Elgiganten8'),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: answers.length,
            itemBuilder: (BuildContext context, int index) {
              Color buttonColor = Colors.blue;
              String userAnswer = answers[index];
              String correctAnswer = allData[_questionIndex]['correctAnswer'];
              if (_isSubmitted && _userAnswer == userAnswer) {
                if (userAnswer == correctAnswer) {
                  buttonColor = Colors.green;
                  _correctAnswers++;
                } else {
                  buttonColor = Colors.red;
                }
              }
              return ElevatedButton(
                onPressed: () {
                  if (!_isSubmitted) {
                    setState(() {
                      _userAnswer = answers[index];
                      _isSubmitted = true;
                    });
                    Future.delayed(const Duration(milliseconds: 500), () {
                      setState(() {
                        _questionIndex++;
                        _isSubmitted = false;
                      });
                    });
                  }
                },
                style: ElevatedButton.styleFrom(primary: buttonColor),
                child: Text(
                  answers[index],
                  style: TextStyle(fontSize: 18, fontFamily: 'Elgiganten8'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleCorrectAnswersQuestion(String question) {
    List<String> multiCorrects =
        allData[_questionIndex]['multiCorrects']?.cast<String>() ?? [];
    List<String> answers = allData[_questionIndex]['answers'].cast<String>();
    bool correct = false;
    bool _isSubmitted = false;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Text(
            question,
            style: TextStyle(fontSize: 25, fontFamily: 'Elgiganten8'),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: answers.length,
            itemBuilder: (BuildContext context, int index) {
              bool isSelected = _selectedAnswers.contains(answers[index]);
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (isSelected) {
                      _selectedAnswers.remove(answers[index]);
                    } else {
                      _selectedAnswers.add(answers[index]);
                    }
                  });
                },
                style: isSelected
                    ? ElevatedButton.styleFrom(primary: Colors.blue)
                    : ElevatedButton.styleFrom(primary: Colors.grey),
                child: Text(
                  answers[index],
                  style: TextStyle(fontSize: 18, fontFamily: 'Elgiganten8'),
                ),
              );
            },
          ),
        ),
        ElevatedButton(
          child: Text("Submit"),
          onPressed: _selectedAnswers.isNotEmpty && !_isSubmitted
              ? () {
                  setState(() {
                    _isSubmitted = true;
                  });
                  _checkMultipleAnswer();
                }
              : null,
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(_submitButtonColor),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Services Store"),
        actions: [
          TextButton(
            onPressed: signOut,
            child: Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _buildQuestionWidget(),
    );
  }
}
