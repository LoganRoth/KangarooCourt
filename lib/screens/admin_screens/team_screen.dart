import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kangaroo_court/screens/admin_screens/create_team_screen.dart';
import 'package:kangaroo_court/screens/admin_screens/join_team_screen.dart';
import 'package:kangaroo_court/screens/base_screen.dart';
import 'package:kangaroo_court/widgets/admin_widgets/main_drawer.dart';
import 'package:kangaroo_court/widgets/admin_widgets/team_tile.dart';

class TeamScreen extends StatefulWidget {
  final String uid;
  final List<dynamic> teams;

  TeamScreen({
    @required this.uid,
    @required this.teams,
  });

  @override
  _TeamScreenState createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  var _teamPicked = false;
  var _teamId;
  var _award;
  var _pointName;

  void _pickTeam(
    String teamId,
    String award,
    String pointName,
  ) {
    _teamPicked = true;
    _teamId = teamId;
    _award = award;
    _pointName = pointName;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _teamPicked
        ? BaseScreen(
            teamId: _teamId,
            uid: widget.uid,
            teams: widget.teams,
            award: _award,
            pointName: _pointName,
          )
        : Scaffold(
            backgroundColor: Color(0xedffffff),
            appBar: AppBar(
              title: Text('Teams'),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: Icon(Icons.more_horiz_outlined),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) {
                        return GestureDetector(
                          child: MainDrawer(
                            uid: widget.uid,
                            sendToHome: () {},
                          ),
                          onTap: () {},
                          behavior: HitTestBehavior.opaque,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            body: widget.teams.length > 0
                ? StreamBuilder<Object>(
                    stream: FirebaseFirestore.instance
                        .collection('teams')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final QuerySnapshot teamData = snapshot.data;
                      List<QueryDocumentSnapshot> teamDocs = teamData.docs;
                      List<QueryDocumentSnapshot> toUse = [];
                      teamDocs.forEach(
                        (element) {
                          if (widget.teams
                                  .indexWhere((el) => (el == element.id)) >=
                              0) {
                            toUse.add(element);
                          }
                        },
                      );

                      return Column(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      0.4775,
                                  child: Card(
                                    color: Theme.of(context).accentColor,
                                    child: ListTile(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                            CreateTeamScreen.routeName,
                                            arguments: widget.uid);
                                      },
                                      leading: Icon(Icons.create),
                                      title: Text('New'),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      0.4775,
                                  child: Card(
                                    color: Theme.of(context).accentColor,
                                    child: ListTile(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                            JoinTeamScreen.routeName,
                                            arguments: widget.uid);
                                      },
                                      leading: Icon(Icons.add),
                                      title: Text('Join'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.8,
                            child: ListView.builder(
                              itemCount: toUse.length,
                              itemBuilder: (ctx, idx) => TeamTile(
                                teamId: toUse[idx].id,
                                uid: widget.uid,
                                inSession: toUse[idx].get('inSession'),
                                teamName: toUse[idx].get('name'),
                                award: toUse[idx].get('award'),
                                pointName: toUse[idx].get('pointName'),
                                judgePwd: toUse[idx].get('judgePwd'),
                                joinPwd: toUse[idx].get('joinPwd'),
                                pickFn: _pickTeam,
                              ),
                            ),
                          ),
                        ],
                      );
                    })
                : Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.3,
                      left: MediaQuery.of(context).size.width * 0.15,
                    ),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.2,
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ListTile(
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                    CreateTeamScreen.routeName,
                                    arguments: widget.uid);
                              },
                              leading: Icon(Icons.create),
                              title: Text('Create a New Team'),
                            ),
                            Divider(
                              color: Colors.black,
                            ),
                            ListTile(
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                    JoinTeamScreen.routeName,
                                    arguments: widget.uid);
                              },
                              leading: Icon(Icons.add),
                              title: Text('Join a Team'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          );
  }
}
