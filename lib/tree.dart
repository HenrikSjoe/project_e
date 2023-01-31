// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> signOut() async {
  try {
    await FirebaseAuth.instance.signOut();
  } catch (e) {
    print(e.toString());
  }
}

class TreePage extends StatelessWidget {
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
      body: Stack(
        children: <Widget>[
          // Background Image
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Image.asset(
              "assets/tree.jpeg",
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          // Transparent
          //button as Gesture Detector
          Positioned(
            top: 210,
            left: 20,
            child: GestureDetector(
              onTap: () {
                // Action for gesture detector
                Navigator.pushNamed(context, '/financing');
                print('tapped Finansiering');
              },
              child: Container(
                width: 90,
                height: 17,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Center(
                  child: Text(
                    "Finansiering",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Elgiganten3'),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 175,
            left: 110,
            child: GestureDetector(
              onTap: () {
                // Action for gesture detector
                Navigator.pushNamed(context, '/securities');
                print('tapped Trygghet & förlängda garantier');
              },
              child: Container(
                width: 205,
                height: 17,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Center(
                  child: Text(
                    "Trygghet & förlängda garantier",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Elgiganten3'),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 300,
            left: 180,
            child: GestureDetector(
              onTap: () {
                // Action for gesture detector
                Navigator.pushNamed(context, '/servicesHome');
                print('tapped Tjänster hemma');
              },
              child: Container(
                width: 120,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Center(
                  child: Text(
                    "Tjänster hemma",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Elgiganten3'),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 325,
            left: 30,
            child: GestureDetector(
              onTap: () {
                // Action for gesture detector
                Navigator.pushNamed(context, '/servicesStore');
                print('tapped Tjänster i butik');
              },
              child: Container(
                width: 120,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Center(
                  child: Text(
                    "Tjänster i butik",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Elgiganten3'),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 250,
            left: 280,
            child: GestureDetector(
              onTap: () {
                // Action for gesture detector
                Navigator.pushNamed(context, '/accessories');
                print('tapped Tillbehör');
              },
              child: Container(
                width: 70,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Center(
                  child: Text(
                    "Tillbehör",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Elgiganten3'),
                  ),
                ),
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
}
