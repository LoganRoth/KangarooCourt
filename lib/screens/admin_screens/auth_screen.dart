import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kangaroo_court/widgets/admin_widgets/auth_form.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  void _submitAuthForm(
    String email,
    String password,
    String name,
    bool isLogin,
    BuildContext ctx,
  ) async {
    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(cred.user.uid)
            .set(
          {
            'name': name,
            'teams': [],
          },
        );
      }
    } catch (err) {
      var msg = 'An error occurred, please check your credentials';
      if (err.message != null) {
        msg = err.message;
      }
      Scaffold.of(ctx).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(ctx).errorColor,
      ));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Card(
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
            AuthForm(
              _submitAuthForm,
              _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
