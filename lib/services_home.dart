// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:core';

class ServicesHome extends StatefulWidget {
  @override
  _ServicesHomeState createState() => _ServicesHomeState();
}

Future<void> signOut() async {
  try {
    await FirebaseAuth.instance.signOut();
  } catch (e) {
    print(e.toString());
  }
}

class _ServicesHomeState extends State<ServicesHome> {
  CollectionReference _collectionRef = FirebaseFirestore.instance
      .collection('categories')
      .doc('y4llzktvesBzbfXoUP0r')
      .collection('questions');

  int _questionIndex = 0;
  int _correctAnswers = 0;
  List<Map<String, dynamic>> allData = [];
  bool _isLoading = true;
  String _userAnswer = "";
  TextEditingController _textController = TextEditingController();
  Color _color = Colors.blue;

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

  void _checkAnswer() {
    if (allData[_questionIndex]['multiAnswer'] == true) {
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
    } else {
      if (_userAnswer.isNotEmpty) {
        if (allData[_questionIndex]['correctAnswer']
                .toLowerCase()
                .compareTo(_userAnswer.toLowerCase().trim()) ==
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
    // Color _color = Colors.blue;

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
        bottomNavigationBar: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  // Action for gesture detector
                  Navigator.pushNamed(context, '/home');
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
              child: Center(
                child: Text(
                  allData[_questionIndex]['question'],
                  style: TextStyle(fontSize: 25, fontFamily: 'Elgiganten8'),
                ),
              ),
            ),
          ),
          Expanded(
            child: allData[_questionIndex]['multiAnswer'] == true
                ? ListView.builder(
                    itemCount: allData[_questionIndex]['answers'].length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _userAnswer = allData[_questionIndex]['answers']
                                      [index]
                                  .toString();
                              _checkAnswer();
                            });
                          },
                          style: _userAnswer ==
                                      allData[_questionIndex]['answers'][index]
                                          .toString() &&
                                  _questionIndex < allData.length &&
                                  allData[_questionIndex]['correctAnswer']
                                          .compareTo(_userAnswer) ==
                                      0
                              ? ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                )
                              : _userAnswer ==
                                          allData[_questionIndex]['answers']
                                                  [index]
                                              .toString() &&
                                      _questionIndex < allData.length
                                  ? ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    )
                                  : null,
                          child: Text(
                            allData[_questionIndex]['answers'][index],
                            style: TextStyle(
                                fontSize: 18, fontFamily: 'Elgiganten8'),
                          ),
                        ),
                      );
                    },
                  )
                : Visibility(
                    visible: false,
                    child: Column(
                      children: [
                        TextField(
                          controller: _textController,
                          onChanged: (value) {
                            setState(() {
                              _userAnswer = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
          ),
          Expanded(
            child: allData[_questionIndex]['multiAnswer'] == false
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: TextField(
                          style: TextStyle(
                              fontFamily: 'Elgiganten3', fontSize: 25),
                          controller: _textController,
                          onChanged: (value) {
                            setState(() {
                              _userAnswer = value;
                            });
                          },
                        ),
                      ),
                      ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(backgroundColor: _color),
                        child: Text("Submit"),
                        onPressed: () {
                          if (_userAnswer ==
                              allData[_questionIndex]['correctAnswer']) {
                            setState(() {
                              _color = Colors.green;
                            });
                          } else {
                            setState(() {
                              _color = Colors.red;
                            });
                          }
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
                          controller: _textController,
                          onChanged: (value) {
                            setState(() {
                              _userAnswer = value;
                              if (_userAnswer ==
                                  allData[_questionIndex]['correctAnswer']) {
                                _color = Colors.green;
                              } else {
                                _color = Colors.red;
                              }
                            });
                          },
                        ),
                      ],
                    ),
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
                child: Icon(Icons.bar_chart_rounded),
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
