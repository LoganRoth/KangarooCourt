import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kangaroo_court/screens/court_screens/in_session_screen.dart';

class CourtScreen extends StatefulWidget {
  final String teamId;
  final String uid;

  CourtScreen({
    @required this.teamId,
    @required this.uid,
  });
  @override
  _CourtScreenState createState() => _CourtScreenState();
}

class _CourtScreenState extends State<CourtScreen> {
  bool _isInSession;
  String _judgePwd;
  var _isLoading = false;

  void _errorPopUp(String errMsg) {
    showDialog<Null>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occured'),
        content: Text(errMsg),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Okay',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
    );
  }

  void _putCourtInSession() async {
    showDialog<Null>(
        context: context,
        builder: (ctx) {
          final _passwordController = TextEditingController();
          final GlobalKey<FormState> _formKey = GlobalKey();
          return AlertDialog(
            content: TextFormField(
              key: _formKey,
              decoration: InputDecoration(labelText: 'Judge Password'),
              obscureText: true,
              controller: _passwordController,
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  if (_judgePwd == _passwordController.text) {
                    Navigator.of(ctx).pop();
                    await FirebaseFirestore.instance
                        .doc('teams/${widget.teamId}')
                        .update(
                      {
                        'inSession': true,
                      },
                    );
                  } else {
                    _errorPopUp('Password was incorrect.');
                    setState(() {
                      _isLoading = false;
                    });
                  }
                  _passwordController.text = '';
                  setState(() {
                    _isLoading = false;
                  });
                },
                child: Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )
            ],
          );
        });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream:
          FirebaseFirestore.instance.doc('teams/${widget.teamId}').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final DocumentSnapshot courtDoc = snapshot.data;
        _isInSession = courtDoc.get('inSession');
        _judgePwd = courtDoc.get('judgePwd');

        return !_isInSession
            ? _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Center(
                    child: GestureDetector(
                      onTap: _putCourtInSession,
                      child: Card(
                        shape: CircleBorder(),
                        color: Color(0xffff7076),
                        child: Card(
                          elevation: 8,
                          shape: CircleBorder(),
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            radius: 95,
                            child: Card(
                              child: CircleAvatar(
                                child: Text(
                                  'Hold Court',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.black,
                                  ),
                                ),
                                radius: 75,
                                backgroundColor: Theme.of(context).accentColor,
                              ),
                              shape: CircleBorder(),
                              elevation: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
            : InSessionScreen(
                teamId: widget.teamId,
                uid: widget.uid,
                judgePwd: _judgePwd,
              );
      },
    );
  }
}
