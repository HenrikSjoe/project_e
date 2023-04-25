import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_e/accessories.dart';
import 'package:project_e/financing.dart';
import 'package:project_e/services_home.dart';
import 'package:project_e/services_store.dart';
import 'package:project_e/warranties.dart';


Future<void> signOut() async {
  try {
    await FirebaseAuth.instance.signOut();
  } catch (e) {
    print(e.toString());
  }
}

class TreePage extends StatefulWidget {
  @override
  _TreePageState createState() => _TreePageState();
}

class _TreePageState extends State<TreePage> {
  final _users = FirebaseFirestore.instance.collection('users');
  final _currentUser = FirebaseAuth.instance.currentUser!;
  int financingScore = 0;
  int warrantiesScore = 0;
  int servicesHomeScore = 0;
  int servicesStoreScore = 0;
  int accessoriesScore = 0;

  @override
  void initState() {
    super.initState();
    _subscribeToScores();
  }

  void _subscribeToScores() {
    _users
        .doc(_currentUser.uid)
        .collection('scores')
        .snapshots()
        .listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        final score = change.doc.data()!['score'] as int?;
        switch (change.doc.id) {
          case 'financing':
            setState(() {
              financingScore = score ?? 0;
            });
            break;
          case 'warranties':
            setState(() {
              warrantiesScore = score ?? 0;
            });
            break;
          case 'servicesHome':
            setState(() {
              servicesHomeScore = score ?? 0;
            });
            break;
          case 'servicesStore':
            setState(() {
              servicesStoreScore = score ?? 0;
            });
            break;
          case 'accessories':
            setState(() {
              accessoriesScore = score ?? 0;
            });
            break;
        }
        setState(() {}); // update the UI with the new cumulative score
      });
    });
  }

  void _getScore(String scoreType, void Function(int) onScore) {
    final scoreRef =
        _users.doc(_currentUser.uid).collection('scores').doc(scoreType);
    scoreRef.get().then((scoreDoc) {
      if (scoreDoc.exists) {
        final score = scoreDoc.data()?['score'] as int?;
        onScore(score ?? 0);
      }
    }).catchError((error) {
      print('Error fetching $scoreType score: $error');
    });
  }

  int get cumulativeScore {
    return financingScore +
        warrantiesScore +
        servicesHomeScore +
        servicesStoreScore +
        accessoriesScore;
  }

  bool get isWarrantiesEnabled {
    return cumulativeScore >= 6;
  }

  bool get isServicesHomeEnabled {
    return cumulativeScore >= 12;
  }

  bool get isServicesStoreEnabled {
    return cumulativeScore >= 16;
  }

  bool get isAccessoriesEnabled {
    return cumulativeScore >= 22;
  }

  Widget _buildButton({
    required String text,
    required VoidCallback? onTap,
    required String scoreType,
  }) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _users
          .doc(_currentUser.uid)
          .collection('scores')
          .doc(scoreType)
          .snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        int currentScore = 0;
        if (snapshot.hasData && snapshot.data?.exists == true) {
          currentScore = snapshot.data?.get('score') as int;
        }

        int requiredScore;
        switch (scoreType) {
          case 'financing':
            requiredScore = 0;
            break;
          case 'warranties':
            requiredScore = 6;
            break;
          case 'servicesHome':
            requiredScore = 12;
            break;
          case 'servicesStore':
            requiredScore = 16;
            break;
          case 'accessories':
            requiredScore = 22;
            break;
          default:
            requiredScore = 0;
        }

        bool isEnabled = cumulativeScore >= requiredScore;

        return GestureDetector(
          onTap: isEnabled ? onTap : null,
          child: Container(
            width: 150,
            height: 45,
            decoration: BoxDecoration(
              color: isEnabled
                  ? Colors.white.withOpacity(0.3)
                  : Colors.transparent,
              borderRadius: isEnabled ? BorderRadius.circular(25) : null,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    text,
                    style: TextStyle(
                      color: isEnabled ? Colors.black : Colors.transparent,
                      fontSize: 20,
                      fontFamily: 'Elgiganten3',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
      body: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Image.asset(
              "assets/tradet.png",
              fit: BoxFit.fill,
              // width: double.infinity,
              // height: double.infinity,
              // alignment: Alignment.center,
              height: double.infinity,
              width: 600,
            ),
          ),
    //        Positioned(
    //   top: 20,
    //   left: 20,
    //   child: Text(
    //     _currentUser.displayName ?? _currentUser.email ?? '',
    //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    //   ),
    // ),
    Positioned(
      top: 40,
      left: 20,
      child: Text(
        'Total Score: $cumulativeScore',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Elgiganten2', color: Color.fromRGBO(18, 21, 88, 1.0)),
      ),
    ),
          Positioned(
            top: 210,
            left: 20,
            child: _buildButton(
              text: 'Finansiering',
              onTap: () {
                // Navigator.pushNamed(context, '/financing');
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) => Financing()), // TreePage() is the widget for your '/home' route
                  (Route<dynamic> route) => route.settings.name == '/financing',
                );

                print('tapped Finansiering');
              },
              scoreType: 'financing',
            ),
          ),
          Positioned(
            top: 105,
            left: 115,
            child: _buildButton(
                text: 'Trygghet & förlängda garantier',
                onTap: () {
                  // Navigator.pushNamed(context, '/warranties');
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) => Warranties()), // TreePage() is the widget for your '/home' route
                    (Route<dynamic> route) => route.settings.name == '/warranties',
                  );

                  print('tapped Trygghet & förlängda garantier');
                },
                scoreType: 'warranties'),
          ),
          Positioned(
            top: 300,
            left: 230,
            child: _buildButton(
                text: 'Tjänster hemma',
                onTap: () {
                  // Navigator.pushNamed(context, '/servicesHome');
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) => ServicesHome()), // TreePage() is the widget for your '/home' route
                    (Route<dynamic> route) => route.settings.name == '/servicesHome',
                  );

                  print('tapped Tjänster hemma');
                },
                scoreType: 'servicesHome'),
          ),
          Positioned(
            top: 315,
            left: -15,
            child: _buildButton(
                text: 'Tjänster i butik',
                onTap: () {
                  // Navigator.pushNamed(context, '/servicesStore');
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) => ServicesStore()), // TreePage() is the widget for your '/home' route
                    (Route<dynamic> route) => route.settings.name == '/servicesStore',
                  );

                  print('tapped Tjänster i butik');
                },
                scoreType: 'servicesStore'),
          ),
          Positioned(
            top: 180,
            left: 250,
            child: _buildButton(
                text: 'Tillbehör',
                onTap: () {
                  // Navigator.pushNamed(context, '/accessories');
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) => AccessoriesPage()), // TreePage() is the widget for your '/home' route
                    (Route<dynamic> route) => route.settings.name == '/accessories',
                  );

                  print('tapped Tillbehör');
                },
                scoreType: 'accessories'),
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
                print("financing $financingScore");
                print('cumulative score = $cumulativeScore');
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const FaIcon(FontAwesomeIcons.solidStar),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Action for gesture detector
                Navigator.popAndPushNamed(context, '/weekly');
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: FaIcon(FontAwesomeIcons.solidCalendarCheck),
              ),
            ),
            GestureDetector(
              onTap: () {
                print(cumulativeScore);
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
                child: const FaIcon(FontAwesomeIcons.signOutAlt),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
