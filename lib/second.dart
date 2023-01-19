import 'dart:developer';

import 'package:flutter/material.dart';
import 'main.dart';
// import 'third.dart';
// import 'fourth.dart';

class NextPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('my first app'),
        centerTitle: true,
        backgroundColor: Colors.red[600],
      ),
      body: Row(
        children: <Widget>[
          // Expanded(child: Image.asset('assets/space3.jpeg')),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(30.0),
              color: Colors.cyan,
              child: Text('1'),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(30.0),
              color: Colors.pinkAccent,
              child: const Text('2'),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(30.0),
              color: Colors.amber,
              child: const Text('3'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          {
            log('tryckt');
            // Navigator.push(
            //     //öppnar nästa route och poppar denna
            //     context,
            //     MaterialPageRoute(builder: (context) => NinjaCard()));
          }
          ;
        },
        child: Text('Click'),
        backgroundColor: Colors.red[600],
      ),
    );
  }
}
