import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kangaroo_court/screens/admin_screens/account_settings_screen.dart';
import 'package:kangaroo_court/screens/admin_screens/auth_screen.dart';
import 'package:kangaroo_court/screens/admin_screens/create_team_screen.dart';
import 'package:kangaroo_court/screens/admin_screens/explanation_screen.dart';
import 'package:kangaroo_court/screens/admin_screens/join_team_screen.dart';
import 'package:kangaroo_court/screens/admin_screens/splash_screen.dart';
import 'package:kangaroo_court/screens/admin_screens/team_settings_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // .. TODO handle error
          return MaterialApp(
            home: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'Kangaroo Court',
            theme: ThemeData(
              primarySwatch: Colors.amber,
              accentColor: Colors.blueGrey,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (ctx, snapshot) {
                if (snapshot.hasData) {
                  return SplashScreen(snapshot.data.uid);
                } else {
                  return AuthScreen();
                }
              },
            ),
            routes: {
              ExplanationScreen.routeName: (ctx) => ExplanationScreen(),
              CreateTeamScreen.routeName: (ctx) => CreateTeamScreen(),
              JoinTeamScreen.routeName: (ctx) => JoinTeamScreen(),
              TeamSettingsScreen.routeName: (ctx) => TeamSettingsScreen(),
              AccountSettingsScreen.routeName: (ctx) => AccountSettingsScreen(),
            },
          );
        }
        return MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.amber,
            accentColor: Colors.blueGrey,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
