import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> signOut() async {
  try {
    await FirebaseAuth.instance.signOut();
  } catch (e) {
    print(e.toString());
  }
}

CollectionReference _collectionRef = FirebaseFirestore.instance
    .collection('categories')
    .doc('tnD84mdEdVvBvQ3bOY1f')
    .collection('questions');

Future<void> getData() async {
  // Get docs from collection reference
  QuerySnapshot querySnapshot = await _collectionRef.get();

  // Get data from docs and convert map to List
  final allData = querySnapshot.docs.map((doc) => doc.data()).toList();

  print(allData);
}

class ServicesHomePage extends StatelessWidget {
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
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.black),
            onPressed: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(1, 0, 1, 0),
                items: [
                  PopupMenuItem(
                    child: InkWell(
                      onTap: () {
                        signOut();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/', (Route<dynamic> route) => false);
                      },
                      child: ListTile(
                        leading: Icon(Icons.exit_to_app),
                        title: Text('Logout',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            getData();
            Navigator.pop(context);
            print("bakåtpilen");
          },
          color: Colors.black87,
        ),
      ),
      body: const Center(
        child: Text(
          "Här kommer frågor om tjänster hemma",
          style: TextStyle(
              fontSize: 40, fontFamily: 'Elgiganten3', color: Colors.black),
        ),
      ),
      // bottomNavigationBar: Container(
      //   height: 60,
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //     children: <Widget>[
      //       GestureDetector(
      //         onTap: () {
      //           // Action for gesture detector
      //         },
      //         child: Container(
      //           width: 50,
      //           height: 50,
      //           decoration: BoxDecoration(
      //             color: Colors.transparent,
      //             borderRadius: BorderRadius.circular(25),
      //           ),
      //           child: const Icon(Icons.home),
      //         ),
      //       ),
      //       GestureDetector(
      //         onTap: () {
      //           // Action for gesture detector
      //         },
      //         child: Container(
      //           width: 50,
      //           height: 50,
      //           decoration: BoxDecoration(
      //             color: Colors.transparent,
      //             borderRadius: BorderRadius.circular(25),
      //           ),
      //           child: Icon(Icons.settings),
      //         ),
      //       ),
      //       GestureDetector(
      //         onTap: () {
      //           // Action for gesture detector
      //           Navigator.of(context).pushNamedAndRemoveUntil(
      //               '/', (Route<dynamic> route) => false);
      //         },
      //         child: Container(
      //           width: 50,
      //           height: 50,
      //           decoration: BoxDecoration(
      //             color: Colors.transparent,
      //             borderRadius: BorderRadius.circular(25),
      //           ),
      //           child: const Icon(Icons.logout),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
