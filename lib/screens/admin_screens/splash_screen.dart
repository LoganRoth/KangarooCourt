import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kangaroo_court/screens/admin_screens/team_screen.dart';

class SplashScreen extends StatefulWidget {
  final String uid;

  SplashScreen(this.uid);
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.doc('users/${widget.uid}').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final DocumentSnapshot teamData = snapshot.data;
          return TeamScreen(uid: widget.uid, teams: teamData.data()['teams']);
        } else {
          return Container(
            color: Theme.of(context).primaryColor,
            child: Center(
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                margin: EdgeInsets.all(25),
                color: Theme.of(context).accentColor,
                elevation: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Text(
                    'Kangaroo Court',
                    style: TextStyle(
                      fontSize: 45,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
