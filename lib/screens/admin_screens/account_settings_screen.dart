import 'package:flutter/material.dart';

class AccountSettingsScreen extends StatefulWidget {
  static const routeName = '/account';
  @override
  _AccountSettingsScreenState createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xedffffff),
      appBar: AppBar(
        title: Text('Account Settings'),
      ),
      body: Text(''),
    );
  }
}
