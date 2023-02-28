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
  late String userUid;

  void _createUser() async {
    try {
      final newUser = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (newUser != null) {
        userUid = FirebaseAuth.instance.currentUser!.uid;
        print("New user created: $userUid");
        await _firestore.collection('users').doc(userUid).set({
          'name': email,
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
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle:
                      TextStyle(fontSize: 20, fontFamily: 'Elgiganten3')),
              onChanged: (value) {
                email = value;
              },
            ),
            SizedBox(height: 12),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle:
                      TextStyle(fontSize: 20, fontFamily: 'Elgiganten3')),
              onChanged: (value) {
                password = value;
              },
            ),
            SizedBox(height: 12),
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
              child: Text(
                'Login',
                style: TextStyle(fontSize: 20, fontFamily: 'Elgiganten3'),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _createUser,
              child: Text(
                'Create User',
                style: TextStyle(fontSize: 20, fontFamily: 'Elgiganten3'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
