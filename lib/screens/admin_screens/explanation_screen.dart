import 'package:flutter/material.dart';

class ExplanationScreen extends StatelessWidget {
  static const routeName = '/explanation';
  static const explanation =
      'This is a place holder for the explanation screen.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xedffffff),
      appBar: AppBar(
        title: Text('Kangaroo Court'),
      ),
      body: Text(explanation),
    );
  }
}
