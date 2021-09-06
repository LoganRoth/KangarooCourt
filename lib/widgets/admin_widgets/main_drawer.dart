import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kangaroo_court/screens/admin_screens/account_settings_screen.dart';
import 'package:kangaroo_court/screens/admin_screens/explanation_screen.dart';

class MainDrawer extends StatelessWidget {
  final String uid;
  final Function sendToHome;
  MainDrawer({
    @required this.uid,
    @required this.sendToHome,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(
          color: Colors.black,
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text(
            'Home',
            style: TextStyle(fontSize: 17),
          ),
          onTap: () {
            Navigator.of(context).pop();
            sendToHome();
          },
        ),
        Divider(
          color: Colors.black,
        ),
        ListTile(
          leading: Icon(Icons.help_outline),
          title: Text(
            'Help',
            style: TextStyle(
              fontSize: 17,
            ),
          ),
          onTap: () => Navigator.of(context)
              .popAndPushNamed(ExplanationScreen.routeName),
        ),
        ListTile(
          leading: Icon(Icons.person),
          title: Text(
            'Account Settings',
            style: TextStyle(fontSize: 17),
          ),
          onTap: () => Navigator.of(context)
              .popAndPushNamed(AccountSettingsScreen.routeName),
        ),
        ListTile(
          leading: Icon(Icons.logout),
          title: Text(
            'Logout',
            style: TextStyle(fontSize: 17),
          ),
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
