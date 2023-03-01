import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:collection';
import 'package:firebase_core/firebase_core.dart';

class Financing extends StatefulWidget {
  @override
  _FinancingState createState() => _FinancingState();
}

class _FinancingState extends State<Financing> {
  CollectionReference _collectionRef = FirebaseFirestore.instance
      .collection('categories')
      .doc('tnD84mdEdVvBvQ3bOY1f')
      .collection('questions');

  bool _isSubmitted = false;
  int _questionIndex = 0;
  int _correctAnswers = 0;
  List<Map<String, dynamic>> allData = [];
  bool _isLoading = true;
  String _userAnswer = "";
  TextEditingController _textController = TextEditingController();
  Color _submitButtonColor = Colors.blue;
  bool _fadeOut = false;

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

  void _checkAnswer() async {
    if (allData[_questionIndex]['multiAnswer'] == true) {
      // Handle multiple-answer questions
      if (allData[_questionIndex]['multiCorrect'] == true) {
        _checkMultipleAnswer();
      } else {
        _checkSingleAnswer();
      }
    } else {
      // Handle free-text questions
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
          setState(() {
            _correctAnswers++;
            _submitButtonColor = Colors.green; // Set color to green
          });
        } else {
          setState(() {
            _submitButtonColor = Colors.red; // Set color to red
          });
        }

        _userAnswer = "";
        _textController.clear();
        Future.delayed(const Duration(milliseconds: 500), () async {
          setState(() {
            _questionIndex++;
            _submitButtonColor = Colors.blue; // Reset color to blue
          });
          if (_questionIndex >= allData.length) {
            final user = FirebaseAuth.instance.currentUser;
            final scoreRef = FirebaseFirestore.instance
                .collection('users')
                .doc(user!.uid)
                .collection('scores')
                .doc('financing');
            await scoreRef.set({'score': _correctAnswers});
          }
        });
      } else {
        setState(() {
          _submitButtonColor =
              Colors.red; // Set color to red if the answer is empty
        });
      }
    }
  }

  Future<void> _writeScoreToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    final scoreRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('scores')
        .doc('financing');
    await scoreRef.set({'score': _correctAnswers});
  }

  Widget _buildQuestionWidget() {
    if (_questionIndex >= allData.length) {
      // All questions have been answered, so write score to Firebase
      _writeScoreToFirebase();

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              "You had $_correctAnswers correct answers out of ${allData.length} questions",
              style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ],
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
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Text(
            question,
            style: const TextStyle(
                fontSize: 25, fontFamily: 'Elgiganten8', color: Colors.white),
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _textController,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontFamily: 'Elgiganten3'),
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(
                          22, 43, 117, 1.0), // Change the border color to red
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  hintText: "Type your answer here...",
                  hintStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Elgiganten3'),
                ),
                onChanged: (value) {
                  setState(() {
                    _userAnswer = value;
                  });
                },
              ),
            ),
          ),
        ),
        ElevatedButton(
          child: const Text("Submit"),
          onPressed: () {
            setState(() {
              _checkAnswer();
            });
          },
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
    int maxLength = answers.fold(
        0, (prev, curr) => curr.length > prev ? curr.length : prev);
    bool allOneWord = answers.every((answer) => answer.split(' ').length == 1);
    bool allOneChar = answers.every((answer) => answer.length == 1);
    bool centerText = allOneWord || allOneChar;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
          child: Text(
            question,
            style: const TextStyle(
                fontSize: 25, fontFamily: 'Elgiganten8', color: Colors.white),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: answers.length,
            itemBuilder: (BuildContext context, int index) {
              Color buttonColor = const Color.fromRGBO(22, 43, 117, 0);
              String userAnswer = answers[index];
              String correctAnswer = allData[_questionIndex]['correctAnswer'];
              if (_isSubmitted && _userAnswer == userAnswer) {
                if (userAnswer == correctAnswer) {
                  buttonColor = const Color.fromRGBO(119, 162, 69, 1.0);
                  _correctAnswers++;
                } else {
                  buttonColor = const Color.fromRGBO(211, 53, 48, 1.0);
                }
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ElevatedButton(
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
                  style: ElevatedButton.styleFrom(
                    primary: buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 22.0, horizontal: 50.0),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Align(
                        alignment: centerText
                            ? Alignment.center
                            : Alignment.centerLeft,
                        child: Text(
                          answers[index],
                          style: const TextStyle(
                              fontSize: 18, fontFamily: 'elgiganten3'),
                          textAlign:
                              centerText ? TextAlign.center : TextAlign.left,
                        ),
                      ),
                    ),
                  ),
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
    ScrollController _scrollController = ScrollController();
    bool _showScrollbar = true;

    void _showScrollbarTimer() {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showScrollbar = false;
          });
        }
      });
    }

    bool allAnswersOneWord =
        answers.every((answer) => answer.split(' ').length == 1);
    bool anyAnswerOneChar = answers.any((answer) => answer.length == 1);
    bool centerText = allAnswersOneWord || anyAnswerOneChar;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Text(
            question,
            style: const TextStyle(
                fontSize: 25, fontFamily: 'Elgiganten8', color: Colors.white),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(0, 14, 82, 1.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Scrollbar(
              thumbVisibility: _showScrollbar,
              controller: _scrollController,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: answers.length,
                itemBuilder: (BuildContext context, int index) {
                  Color buttonColor = Colors.blue;
                  String userAnswer = answers[index];
                  if (_selectedAnswers.contains(userAnswer)) {
                    if (multiCorrects.contains(userAnswer)) {
                      correct = true;
                    } else {
                      correct = false;
                    }
                  } else {
                    correct = multiCorrects.contains(userAnswer) ? false : true;
                  }

                  if (_isSubmitted) {
                    if (_selectedAnswers.contains(userAnswer)) {
                      buttonColor = correct ? Colors.green : Colors.red;
                    } else {
                      buttonColor = multiCorrects.contains(userAnswer)
                          ? Colors.green
                          : Colors.blue;
                    }
                  } else {
                    buttonColor = _selectedAnswers.contains(userAnswer)
                        ? Colors.blue
                        : const Color.fromRGBO(3, 10, 54, 1.0);
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: _fadeOut ? 0.5 : 1.0,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (_selectedAnswers.contains(userAnswer)) {
                              _selectedAnswers.remove(userAnswer);
                            } else {
                              _selectedAnswers.add(userAnswer);
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          primary: buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 22.0, horizontal: 50.0),
                        ),
                        child: Align(
                          alignment: allAnswersOneWord || anyAnswerOneChar
                              ? Alignment.center
                              : Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text(
                              answers[index],
                              style: const TextStyle(
                                  fontSize: 18, fontFamily: 'Elgiganten8'),
                              textAlign: centerText
                                  ? TextAlign.center
                                  : TextAlign.left,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        ElevatedButton(
          child: const Text("Submit"),
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
      backgroundColor: const Color.fromRGBO(3, 14, 78, 1.0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/elgiganten-logo.jpeg',
              fit: BoxFit.contain,
              height: 100.0,
            ),
            const SizedBox(width: 50),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildQuestionWidget(),
                    ),
                    const SizedBox(height: 30),
                    LinearProgressIndicator(
                      value: (_questionIndex + 1) / allData.length,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
