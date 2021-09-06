import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:kangaroo_court/screens/admin_screens/splash_screen.dart';

class CreateTeamScreen extends StatefulWidget {
  static const routeName = '/create';

  @override
  _CreateTeamScreenState createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;
  var _isSuccessful = false;
  var _createdNewTeam = false;
  var _teamName = '';
  var _joinPwd = '';
  var _judgePwd = '';
  var _award = '';
  var _pointName = '';
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
        title: Text('Team Created!'),
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
      _createdNewTeam = true;
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
          if (teamDocs
                  .indexWhere((element) => element.get('name') == _teamName) >=
              0) {
            _infoPopUp('Team name unavailable');
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
              .collection('teams')
              .doc(_teamName)
              .set(
            {
              'name': _teamName,
              'joinPwd': _joinPwd,
              'judgePwd': _judgePwd,
              'inSession': false,
              'award': _award,
              'pointName': _pointName,
            },
          );
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
          _infoPopUp('Unable to create team');
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
    _judgePwd = '';
    _award = '';
    _pointName = '';
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
    return _createdNewTeam
        ? SplashScreen(_uid)
        : Scaffold(
            backgroundColor: Color(0xedffffff),
            appBar: AppBar(
              title: Text('Create A New Team'),
            ),
            body: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Team Name'),
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
                                if (value.isEmpty ||
                                    value.length < 5 ||
                                    value.length > 20) {
                                  text =
                                      'Team name must be at least 5 characters and'
                                      ' no more than 20.';
                                } else {
                                  text = null;
                                }
                                return text;
                              },
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                                'Join Password is the password that is required when a user'
                                ' tries to join the team.'),
                            TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Join Password'),
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
                                if (value.isEmpty || value.length < 8) {
                                  text =
                                      'Join Password must be at least 8 characters.';
                                } else {
                                  text = null;
                                }
                                return text;
                              },
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                                'Judge Password is the password that is used to both Hold '
                                'Court and Adjurn Court. As well as the password needed '
                                'to change these settings in the future.'),
                            TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Judge Password'),
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.visiblePassword,
                              autocorrect: false,
                              onFieldSubmitted: (_) {
                                // Do Nothing
                              },
                              onSaved: (value) {
                                _judgePwd = value;
                              },
                              validator: (value) {
                                var text;
                                if (value.isEmpty || value.length < 8) {
                                  text =
                                      'Judge Password must be at least 8 characters.';
                                } else {
                                  text = null;
                                }
                                return text;
                              },
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              'Award Name is the name that will be given to the '
                              'team member with the most points after any court '
                              'session is adjurned.\nIt will show as <Award '
                              'Name>.\nFor example: "Current Shittiest Guy"',
                            ),
                            TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Award Name'),
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.name,
                              autocorrect: false,
                              onFieldSubmitted: (_) {
                                // Do Nothing
                              },
                              onSaved: (value) {
                                _award = value;
                              },
                              validator: (value) {
                                var text;
                                if (value.isEmpty) {
                                  text = 'Award Name is required.';
                                } else if (value.length > 30) {
                                  text =
                                      'Award Name must be 30 characters or less.';
                                } else {
                                  text = null;
                                }
                                return text;
                              },
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              'Point Name is the name of the points that are given '
                              'out by team members to each other.\nIt will show as '
                              'Give <Point Name> Points.\nFor example: "Give Shit Guy '
                              'Points"',
                            ),
                            TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Point Name'),
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.name,
                              autocorrect: false,
                              onFieldSubmitted: (_) {
                                // Do Nothing
                              },
                              onSaved: (value) {
                                _pointName = value;
                              },
                              validator: (value) {
                                var text;
                                if (value.isEmpty) {
                                  text = 'Point Name is required.';
                                } else if (value.length > 12) {
                                  text =
                                      'Point Name must be 12 characters or less';
                                } else {
                                  text = null;
                                }
                                return text;
                              },
                            ),
                            SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Divider(
                  color: Colors.black,
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
                              'Create',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 25),
                            ),
                          ),
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                )
              ],
            ),
          );
  }
}
