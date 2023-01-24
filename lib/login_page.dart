import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;
  // var userUid = FirebaseAuth.instance.currentUser!.uid;
  late String userUid;

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
                    // if (userUid != null) {
                    //   print(userUid);
                    // } else {
                    //   print('No user');
                    // }
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
          ],
        ),
      ),
    );
  }
}
