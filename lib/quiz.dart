import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:core';

class Quiz extends StatefulWidget {
  @override
  _QuizState createState() => _QuizState();
}

Future<void> signOut() async {
  try {
    await FirebaseAuth.instance.signOut();
  } catch (e) {
    print(e.toString());
  }
}

class _QuizState extends State<Quiz> {
  CollectionReference _collectionRef = FirebaseFirestore.instance
      .collection('categories')
      .doc('tnD84mdEdVvBvQ3bOY1f')
      .collection('questions');

  int _questionIndex = 0;
  int _correctAnswers = 0;
  List<Map<String, dynamic>> allData = [];
  bool _isLoading = true;
  String _userAnswer = "";

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

  void _checkAnswer() {
    if (allData[_questionIndex]['multiAnswer'] == true) {
      if (allData[_questionIndex]['correctAnswer'].compareTo(_userAnswer) ==
          0) {
        _correctAnswers++;
      }
    } else {
      if (_userAnswer.isNotEmpty) {
        if (allData[_questionIndex]['correctAnswer']
                .toLowerCase()
                .compareTo(_userAnswer.toLowerCase().trim()) ==
            0) {
          _correctAnswers++;
        }
      }
    }
    setState(() {
      _questionIndex++;
      _userAnswer = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_questionIndex >= allData.length) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Image.asset(
            'assets/elgiganten-logo.jpeg',
            fit: BoxFit.contain,
            height: 100.0,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(
                    "You had $_correctAnswers correct answers out of ${allData.length} questions",
                    style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  // Action for gesture detector
                  Navigator.pushNamed(context, '/home');
                  print("hemma");
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(Icons.home),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Action for gesture detector
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(Icons.settings),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Action for gesture detector
                  Navigator.popAndPushNamed(context, '/');
                  signOut();
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(Icons.logout),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Image.asset(
          'assets/elgiganten-logo.jpeg',
          fit: BoxFit.contain,
          height: 100.0,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                allData[_questionIndex]['question'],
                style: TextStyle(fontSize: 25),
              ),
            ),
          ),
          Expanded(
            child: allData[_questionIndex]['multiAnswer'] == true
                ? ListView.builder(
                    itemCount: allData[_questionIndex]['answers'].length,
                    itemBuilder: (context, index) {
                      return ElevatedButton(
                        child: Text(allData[_questionIndex]['answers'][index]),
                        onPressed: () {
                          setState(() {
                            _userAnswer = allData[_questionIndex]['answers']
                                    [index]
                                .toString();
                            _checkAnswer();
                          });
                        },
                      );
                    },
                  )
                : Visibility(
                    visible: false,
                    child: ListView.builder(
                      itemCount: allData[_questionIndex]['answers'].length,
                      itemBuilder: (context, index) {
                        return ElevatedButton(
                          child:
                              Text(allData[_questionIndex]['answers'][index]),
                          onPressed: () {
                            setState(() {
                              _userAnswer = allData[_questionIndex]['answers']
                                      [index]
                                  .toString();
                              _checkAnswer();
                            });
                          },
                        );
                      },
                    ),
                  ),
          ),
          Expanded(
            child: allData[_questionIndex]['multiAnswer'] == false
                ? Column(
                    children: [
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _userAnswer = value;
                          });
                        },
                      ),
                      ElevatedButton(
                        child: Text('Submit'),
                        onPressed: () {
                          _checkAnswer();
                        },
                      ),
                    ],
                  )
                : Visibility(
                    visible: false,
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              _userAnswer = value;
                            });
                          },
                        ),
                        ElevatedButton(
                          child: Text('Submit'),
                          onPressed: () {
                            _checkAnswer();
                          },
                        ),
                      ],
                    ),
                  ),
          ),
          // Container(
          //   padding: EdgeInsets.all(8.0),
          //   child: ElevatedButton(
          //     child: Text('Submit'),
          //     onPressed: _checkAnswer,
          //   ),
          // )
        ],
      ),
      bottomNavigationBar: Container(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                // Action for gesture detector
                Navigator.pushNamed(context, '/home');
                print("hemma 2");
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(Icons.home),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.popAndPushNamed(context, '/home');

                // Action for gesture detector
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(Icons.settings),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Action for gesture detector
                Navigator.popAndPushNamed(context, '/');
                signOut();
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(Icons.logout),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
