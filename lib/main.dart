import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project_e/quiz.dart';
import 'firebase_options.dart';

import 'package:project_e/accessories.dart';
import 'package:project_e/financing.dart';
import 'package:project_e/services_home.dart';
import 'package:project_e/services_store.dart';
import 'tree.dart';
import 'securities.dart';
import 'login_page.dart';

import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

late String userUid;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => TreePage(),
        '/financing': (context) => Quiz(),
        '/securities': (context) => SecuritiesPage(),
        '/servicesHome': (context) => ServicesHomePage(),
        '/servicesStore': (context) => ServicesStorePage(),
        '/accessories': (context) => AccessoriesPage()
      },
    );
  }
}
