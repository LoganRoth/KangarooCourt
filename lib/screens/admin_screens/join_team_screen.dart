import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:kangaroo_court/screens/admin_screens/splash_screen.dart';

class JoinTeamScreen extends StatefulWidget {
  static const routeName = '/join';

  @override
  _JoinTeamScreenState createState() => _JoinTeamScreenState();
}

class _JoinTeamScreenState extends State<JoinTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;
  var _isSuccessful = false;
  var _joinedNewTeam = false;
  var _teamName = '';
  var _joinPwd = '';
  var _uid = '';

  void _infoPopUp(String msg) {
    showDialog<Null>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred'),
        content: Text(msg),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Okay'),
          )
        ],
      ),
    );
    setState(() {});
  }

  void _teamPopUp() {
    showDialog<Null>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Team Joined!'),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Okay'),
          )
        ],
      ),
    );
    setState(() {
      _joinedNewTeam = true;
      _isSuccessful = false;
      _isLoading = false;
    });
  }

  Future<void> _createTeam() async {
    final isValid = _formKey.currentState.validate();
    setState(() {
      _isLoading = true;
    });
    if (isValid) {
      _formKey.currentState.save();
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        try {
          final teamCol =
              await FirebaseFirestore.instance.collection('teams').get();
          final teamDocs = teamCol.docs;
          final teamIdx =
              teamDocs.indexWhere((element) => element.id == _teamName);
          if (teamIdx < 0) {
            _infoPopUp('Team does not exist.');
            setState(() {
              _isSuccessful = false;
              _isLoading = false;
            });
            return;
          } else if (teamDocs[teamIdx].get('joinPwd') != _joinPwd) {
            _infoPopUp('Join Password is incorrect.');
            setState(() {
              _isSuccessful = false;
              _isLoading = false;
            });
            return;
          }
          final thisUser =
              await FirebaseFirestore.instance.doc('users/$_uid').get();
          final userName = thisUser.get('name');
          final List<dynamic> userTeams = thisUser.get('teams');
          userTeams.add(_teamName);
          await FirebaseFirestore.instance
              .collection('teams/$_teamName/members')
              .doc(_uid)
              .set(
            {
              'currentPoints': 0,
              'winner': false,
              'name': userName,
            },
          );
          await FirebaseFirestore.instance.doc('users/$_uid').set(
            {
              'name': userName,
              'teams': userTeams,
            },
          );
          _isSuccessful = true;
        } catch (error) {
          _infoPopUp('Unable to join team');
        }
      } else {
        _infoPopUp('No Connection, check your network connection');
      }
      setState(() {
        if (_formKey.currentState != null) {
          _formKey.currentState.reset();
        }
      });
    }
    _teamName = '';
    _joinPwd = '';
    if (_isSuccessful) {
      Navigator.of(context).pop();
      _teamPopUp();
    }

    setState(() {
      _isSuccessful = false;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _uid = ModalRoute.of(context).settings.arguments as String;
    return _joinedNewTeam
        ? SplashScreen(_uid)
        : Scaffold(
            backgroundColor: Color(0xedffffff),
            appBar: AppBar(
              title: Text('Join A Team'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Team Name'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.name,
                        autocorrect: false,
                        onFieldSubmitted: (_) {
                          // Do Nothing
                        },
                        onSaved: (value) {
                          _teamName = value;
                        },
                        validator: (value) {
                          var text;
                          if (value.isEmpty) {
                            text = 'Team Name cannot be empty';
                          } else {
                            text = null;
                          }
                          return text;
                        },
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Join Password'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.visiblePassword,
                        autocorrect: false,
                        onFieldSubmitted: (_) {
                          // Do Nothing
                        },
                        onSaved: (value) {
                          _joinPwd = value;
                        },
                        validator: (value) {
                          var text;
                          if (value.isEmpty) {
                            text = 'Join Password cannot be empty';
                          } else {
                            text = null;
                          }
                          return text;
                        },
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      _isLoading
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : Container(
                              width: MediaQuery.of(context).size.width * 0.60,
                              height: MediaQuery.of(context).size.height * 0.07,
                              child: Card(
                                margin: EdgeInsets.all(0.0),
                                child: FlatButton(
                                  onPressed: _createTeam,
                                  child: Text(
                                    'Join',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 25),
                                  ),
                                ),
                                color: Theme.of(context).accentColor,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
