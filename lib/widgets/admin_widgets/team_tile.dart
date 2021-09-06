import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kangaroo_court/screens/admin_screens/team_settings_screen.dart';

class TeamTile extends StatefulWidget {
  final String teamId;
  final String uid;
  final bool inSession;
  final String teamName;
  final String award;
  final String pointName;
  final String judgePwd;
  final String joinPwd;
  final Function pickFn;

  TeamTile({
    @required this.teamId,
    @required this.uid,
    @required this.inSession,
    @required this.teamName,
    @required this.award,
    @required this.pointName,
    @required this.judgePwd,
    @required this.joinPwd,
    @required this.pickFn,
  });
  @override
  _TeamTileState createState() => _TeamTileState();
}

class _TeamTileState extends State<TeamTile> {
  var _isLeaving = false;

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

  Future<void> _leaveTeam() async {
    setState(() {
      _isLeaving = true;
    });
    /**
     * Get user data and remove this team from the users list of teams
     */
    final thisUser =
        await FirebaseFirestore.instance.doc('users/${widget.uid}').get();
    List<dynamic> teamList = thisUser.get('teams');
    teamList.remove('${widget.teamId}');
    await FirebaseFirestore.instance.doc('users/${widget.uid}').update(
      {'teams': teamList},
    );

    /**
     * Get points & court, remove any docs with this user marked as the "to"
     */
    await FirebaseFirestore.instance
        .collection('teams/${widget.teamId}/court')
        .get()
        .then(
      (snapshot) {
        snapshot.docs.forEach(
          (element) {
            if (element.get('toId') == widget.uid) {
              element.reference.delete();
            }
          },
        );
      },
    );
    await FirebaseFirestore.instance
        .collection('teams/${widget.teamId}/points')
        .get()
        .then(
      (snapshot) {
        snapshot.docs.forEach(
          (element) {
            if (element.get('toId') == widget.uid) {
              element.reference.delete();
            }
          },
        );
      },
    );

    /**
     * Get the members and remove this user from the list of members
     */
    await FirebaseFirestore.instance
        .collection('teams/${widget.teamId}/members')
        .get()
        .then(
      (snapshot) {
        snapshot.docs.forEach(
          (element) {
            if (element.id == widget.uid) {
              element.reference.delete();
            }
          },
        );
      },
    );
  }

  void _leaveTeamPopUp() {
    showDialog<Null>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Are you sure?'),
        actions: <Widget>[
          FlatButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _leaveTeam();
            },
            child: Text(
              'Yes',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(
              'No',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToTeamSettings() async {
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
                if (widget.judgePwd == _passwordController.text) {
                  Navigator.of(ctx).pop();
                  Navigator.of(ctx).pushNamed(
                    TeamSettingsScreen.routeName,
                    arguments: {
                      'name': widget.teamId,
                      'joinPwd': widget.joinPwd,
                      'judgePwd': widget.judgePwd,
                      'award': widget.award,
                      'pointName': widget.pointName,
                    },
                  );
                } else {
                  _errorPopUp('Password was incorrect.');
                  setState(() {});
                }
                _passwordController.text = '';
              },
              child: Text(
                'Done',
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      height: MediaQuery.of(context).size.width * 0.8,
      child: Card(
        margin: EdgeInsets.all(5.0),
        child: ListTile(
          title: Column(
            children: [
              Row(
                children: [
                  Text(widget.teamName),
                  Expanded(child: Text('')),
                  if (widget.inSession)
                    Card(
                      elevation: 7,
                      color: Theme.of(context).primaryColor,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text('Court Is In Session!'),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  child: Card(
                    shape: CircleBorder(),
                    color: Theme.of(context).accentColor,
                    child: Icon(
                      Icons.people,
                      size: MediaQuery.of(context).size.width * 0.4,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  _isLeaving
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : FlatButton.icon(
                          onPressed: _leaveTeamPopUp,
                          icon: Icon(Icons.logout),
                          label: Text('Leave Team'),
                        ),
                  Expanded(
                    child: Text(''),
                  ),
                  FlatButton.icon(
                    onPressed: _goToTeamSettings,
                    icon: Icon(Icons.settings),
                    label: Text('Team Settings'),
                  ),
                ],
              )
            ],
          ),
          onTap: _isLeaving
              ? () {}
              : () => widget.pickFn(
                    widget.teamId,
                    widget.award,
                    widget.pointName,
                  ),
        ),
      ),
    );
  }
}
