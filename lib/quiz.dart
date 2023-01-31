import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  void _checkAnswer(int index) {
    if (allData[_questionIndex]['correctAnswer'] ==
        allData[_questionIndex]['answers'][index]) {
      _correctAnswers++;
    }
    setState(() {
      _questionIndex++;
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
              child: Text(allData[_questionIndex]['question'],
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.all(8),
              child: ListView.builder(
                itemCount: allData[_questionIndex]['answers'].length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 6),
                    child: ElevatedButton(
                      onPressed: () {
                        _checkAnswer(index);
                      },
                      child: Text(allData[_questionIndex]['answers'][index]),
                    ),
                  );
                },
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
