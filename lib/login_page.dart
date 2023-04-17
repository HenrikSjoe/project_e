import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late String email;
  late String password;
  late String confirmPassword;
  late String userUid;
  bool showNameFields = false;
  late String firstName;
  late String surname;

  Future<DocumentSnapshot> fetchUserData(String userUid) async {
  return await FirebaseFirestore.instance.collection('users').doc(userUid).get();
}

  

  void _createUser() async {
    setState(() {
      showNameFields = true;
    });
  }

  void _submitUser() async {
    if (password != confirmPassword) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Error'),
            content: Text('Lösenorden stämmer inte överens.'),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  primary: Color.fromRGBO(123, 179, 55, 1.0),
                ),
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
      return;
    }

    try {
      final newUser = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (newUser != null) {
        userUid = FirebaseAuth.instance.currentUser!.uid;
        print("New user created: $userUid");
        await _firestore.collection('users').doc(userUid).set({
          'firstName': firstName,
          'surname': surname,
          'email': email,
        });
        await _firestore
            .collection('users')
            .doc(userUid)
            .collection('scores')
            .doc('financing')
            .set({'score': 0});
        await _firestore
            .collection('users')
            .doc(userUid)
            .collection('scores')
            .doc('warranties')
            .set({'score': 0});
        await _firestore
            .collection('users')
            .doc(userUid)
            .collection('scores')
            .doc('servicesStore')
            .set({'score': 0});
        await _firestore
            .collection('users')
            .doc(userUid)
            .collection('scores')
            .doc('servicesHome')
            .set({'score': 0});
        await _firestore
            .collection('users')
            .doc(userUid)
            .collection('scores')
            .doc('accessories')
            .set({'score': 0});
        Navigator.popAndPushNamed(context, '/home');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Image.asset(
          'assets/elgiganten-logo.jpeg',
          fit: BoxFit.contain,
          height: 100.0,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (showNameFields)
              TextField(
                decoration: InputDecoration(
                  labelText: 'Förnamn',
                  labelStyle:
                      TextStyle(fontSize: 20, fontFamily: 'Elgiganten3'),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    firstName = value;
                  });
                },
              ),
            if (showNameFields) SizedBox(height: 12),
            if (showNameFields)
              TextField(
                decoration: InputDecoration(
                  labelText: 'Efternamn',
                  labelStyle:
                      TextStyle(fontSize: 20, fontFamily: 'Elgiganten3'),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    surname = value;
                  });
                },
              ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'E-postadress',
                labelStyle: TextStyle(fontSize: 20, fontFamily: 'Elgiganten3'),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
            ),
            SizedBox(height: 12),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Lösenord',
                labelStyle: TextStyle(fontSize: 20, fontFamily: 'Elgiganten3'),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
            ),
            SizedBox(height: 12),
            if (showNameFields)
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Bekräfta lösenord',
                  labelStyle:
                      TextStyle(fontSize: 20, fontFamily: 'Elgiganten3'),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    confirmPassword = value;
                  });
                },
              ),
            SizedBox(height: 24),
            if (!showNameFields)
              ElevatedButton(
                onPressed: () async {
                  try {
                    final user = await _auth.signInWithEmailAndPassword(
                        email: email, password: password);
                    userUid = FirebaseAuth.instance.currentUser!.uid;
                    if (user != null) {
                      Navigator.popAndPushNamed(context, '/home');
                      print("UID: $userUid");
                    }
                  } catch (e) {
                    print('$e UID: $userUid');
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Color.fromRGBO(123, 179, 55, 1.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  minimumSize: Size(150, 50),
                ),
                child: Text(
                  'Logga in',
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Elgiganten4',
                      color: Color.fromRGBO(0, 14, 81, 1.0)),
                ),
              ),
            if (showNameFields)
              ElevatedButton(
                onPressed: _submitUser,
                style: ElevatedButton.styleFrom(
                  primary: Color.fromRGBO(123, 179, 55, 1.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  minimumSize: Size(200, 50),
                ),
                child: Text(
                  'Skapa konto och logga in',
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Elgiganten7',
                      color: Color.fromRGBO(0, 14, 81, 1.0)),
                ),
              ),
            SizedBox(height: 12),
            if (!showNameFields)
              ElevatedButton(
                onPressed: _createUser,
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Colors.pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  minimumSize: Size(150, 50),
                ),
                child: Text(
                  'Skapa konto',
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Elgiganten5',
                      color: Color.fromRGBO(0, 14, 81, 1.0)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


