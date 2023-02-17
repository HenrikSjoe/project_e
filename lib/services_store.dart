import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:core';
import 'package:collection/collection.dart';

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

  int _questionIndex = 0;
  int _correctAnswers = 0;
  List<Map<String, dynamic>> allData = [];
  bool _isLoading = true;
  String _userAnswer = "";
  TextEditingController _textController = TextEditingController();
  Color _color = Colors.blue;
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
    // Get docs from collection reference_userAnswer
    QuerySnapshot querySnapshot = await _collectionRef.get();

    // Get data from docs and convert map to List
    allData = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    setState(() {
      _isLoading = false;
    });
  }

  void _checkMultiAnswer() {
    List<String> multiCorrects =
        allData[_questionIndex]['multiCorrects'].cast<String>();
    Set<String> selectedSet = Set.from(_selectedAnswers);
    Set<String> correctSet = Set.from(multiCorrects);
    bool allCorrect = selectedSet.length == correctSet.length &&
        selectedSet.containsAll(correctSet);
    if (allCorrect) {
      _correctAnswers++;
      setState(() {
        _color = Colors.green;
      });
    } else {
      setState(() {
        _color = Colors.red;
      });
    }

    _selectedAnswers.clear();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _questionIndex++;
        _userAnswer = "";
        setState(() {
          _color = Colors.blue;
        });
      });
    });
  }

  void _checkAnswer() {
    if (allData[_questionIndex]['multiAnswer'] == true) {
      if (allData[_questionIndex]['multiCorrect'] == true) {
        _checkMultiAnswer();
        return;
      } else {
        if (_userAnswer.isNotEmpty) {
          if (allData[_questionIndex]['correctAnswer'].compareTo(_userAnswer) ==
              0) {
            _correctAnswers++;
            setState(() {
              _color = Colors.green;
            });
          } else {
            setState(() {
              _color = Colors.red;
            });
          }
        }
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
          setState(() {
            _color = Colors.green;
          });
        } else {
          setState(() {
            _color = Colors.red;
          });
        }
      }
    }

    _selectedAnswers.clear();
    _textController.clear();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _questionIndex++;
        _userAnswer = "";
        setState(() {
          _color = Colors.blue;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_questionIndex >= allData.length) {
      return Scaffold(
        body: Center(
          child: Text(
            "You had $_correctAnswers correct answers out of ${allData.length} questions",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final isMultiAnswer = allData[_questionIndex]['multiAnswer'];
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                allData[_questionIndex]['question'],
                style: TextStyle(fontSize: 25, fontFamily: 'Elgiganten8'),
              ),
            ),
          ),
          Expanded(
            child: isMultiAnswer ? _buildMultiAnswer() : _buildTextField(),
          ),
          if (!isMultiAnswer) Expanded(child: _buildSubmitButton()),
        ],
      ),
    );
  }

  Widget _buildMultiAnswer() {
    final isMultiCorrect = allData[_questionIndex]['multiCorrect'] == true;
    final multiCorrects =
        allData[_questionIndex]['multiCorrects']?.cast<String>() ?? [];
    final answers = allData[_questionIndex]['answers'].cast<String>();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: answers.length,
            itemBuilder: (BuildContext context, int index) {
              final isSelected = _selectedAnswers.contains(answers[index]);

              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (isMultiCorrect) {
                      if (isSelected) {
                        _selectedAnswers.remove(answers[index]);
                      } else {
                        _selectedAnswers.add(answers[index]);
                      }
                    } else {
                      _selectedAnswers.clear();
                      _selectedAnswers.add(answers[index]);
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  primary: isSelected ? Colors.blue : Colors.grey[300],
                ),
                child: Text(
                  answers[index],
                  style: TextStyle(fontSize: 18, fontFamily: 'Elgiganten8'),
                ),
              );
            },
          ),
        ),
        if (isMultiCorrect)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: _color,
            ),
            child: Text("Submit"),
            onPressed: () {
              if (_multiAnswerCheck(_selectedAnswers, multiCorrects)) {
                _correctAnswers++;
                setState(() {
                  _color = Colors.green;
                });
              } else {
                setState(() {
                  _color = Colors.red;
                });
              }
              _selectedAnswers.clear();
              Future.delayed(const Duration(milliseconds: 500), () {
                setState(() {
                  _questionIndex++;
                  _userAnswer = "";
                  setState(() {
                    _color = Colors.blue;
                  });
                });
              });
            },
          ),
        if (!isMultiCorrect)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: _color,
            ),
            child: Text("Submit"),
            onPressed: () {
              final isAnswerCorrect = allData[_questionIndex]
                      ['correctAnswer'] ==
                  _selectedAnswers[0];
              if (isAnswerCorrect) {
                _correctAnswers++;
                setState(() {
                  _color = Colors.green;
                });
              } else {
                setState(() {
                  _color = Colors.red;
                });
              }
              _selectedAnswers.clear();
              _textController.clear();
              Future.delayed(const Duration(milliseconds: 500), () {
                setState(() {
                  _questionIndex++;
                  _userAnswer = "";
                  setState(() {
                    _color = Colors.blue;
                  });
                });
              });
            },
          ),
      ],
    );
  }

  Widget _buildTextField() {
    return Container(
      child: TextField(
        style: TextStyle(fontFamily: 'Elgiganten3', fontSize: 25),
        controller: _textController,
        onChanged: (value) {
          setState(() {
            _userAnswer = value;
          });
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: _color),
      child: Text("Submit"),
      onPressed: () {
        setState(() {
          _color = _userAnswer == allData[_questionIndex]['correctAnswer']
              ? Colors.green
              : Colors.red;
          _checkAnswer();
        });
      },
    );
  }
}
