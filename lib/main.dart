import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'second.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Named Routes Demo',
      // Start the app with the "/" named route. In this case, the app starts
      // on the FirstScreen widget.
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => HomeScreen(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/first': (context) => HomeScreen(),
        '/second': (context) => NextPage(),
        // '/third': (context) => NinjaCard(),
        // '/fourth': (context) => MyApp(),
      },
    ),
  );
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Image.asset(
          'assets/elgiganten-logo.jpeg',
          fit: BoxFit.contain,
          height: 100.0,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 150.0,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'E-post',
              ),
            ),
          ),
          // // SizedBox(
          // //   height: 20.0,
          // ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Lösenord',
                hintStyle: TextStyle(fontFamily: 'Elgiganten3'),
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NextPage()),
                );
              },
              child: Text(
                'Logga in',
                style: TextStyle(fontFamily: 'Elgiganten3'),
              )),
          TextButton(
              onPressed: () {
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => NinjaCard()));
              },
              child: Text(
                'Glömt inloggningsuppgifter',
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Elgiganten3',
                    fontSize: 15.0),
              )),
        ],
      ),
    );
  }
}


// runApp(const MyApp());
