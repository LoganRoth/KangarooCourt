import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kangaroo_court/screens/add_screens/add_point_screen.dart';
import 'package:kangaroo_court/screens/court_screens/court_screen.dart';
import 'package:kangaroo_court/screens/member_screens/members_screen.dart';
import 'package:kangaroo_court/screens/admin_screens/team_screen.dart';
import 'package:kangaroo_court/widgets/add_widgets/add_point.dart';
import 'package:kangaroo_court/widgets/admin_widgets/main_drawer.dart';

class BaseScreen extends StatefulWidget {
  static const routeName = '/base';
  final String teamId;
  final String uid;
  final String award;
  final String pointName;
  final List<dynamic> teams;

  BaseScreen({
    @required this.teamId,
    @required this.uid,
    @required this.award,
    @required this.pointName,
    @required this.teams,
  });

  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _selectedPageIdx = 0;
  List<Map<String, Object>> _pages;

  var _goToHome = false;

  @override
  void initState() {
    super.initState();
    _pages = [
      {
        'page': AddPointScreen(
          teamId: widget.teamId,
          uid: widget.uid,
        ),
        'title': 'Kangaroo Court',
        'id': 'add-points',
      },
      {
        'page': CourtScreen(
          teamId: widget.teamId,
          uid: widget.uid,
        ),
        'title': 'Kangaroo Court',
        'id': 'court',
      },
      {
        'page': MembersScreen(
          teamId: widget.teamId,
          uid: widget.uid,
          award: widget.award,
        ),
        'title': 'Members',
        'id': 'members',
      },
    ];
  }

  void _selectPage(int idx) {
    setState(() {
      _selectedPageIdx = idx;
    });
  }

  Future<void> _addNewPoint(BuildContext ctx) async {
    var data = [];
    String name = '';

    final QuerySnapshot futureData = await FirebaseFirestore.instance
        .collection('teams/${widget.teamId}/members')
        .get();
    final dataDocs = futureData.docs;
    dataDocs.forEach((element) {
      if (element.id != widget.uid) {
        data.add({
          'name': element.get('name'),
          'uid': element.id,
        });
      } else {
        name = element.get('name');
      }
    });
    showModalBottomSheet(
      isScrollControlled: true,
      context: ctx,
      builder: (_) {
        return GestureDetector(
          child: AddPoint(
            teamId: widget.teamId,
            uid: widget.uid,
            name: name,
            pointName: widget.pointName,
            data: data,
          ),
          onTap: () {},
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  void _sendToHome() {
    _goToHome = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _goToHome
        ? TeamScreen(uid: widget.uid, teams: widget.teams)
        : Scaffold(
            backgroundColor: Color(0xedffffff),
            appBar: AppBar(
              title: Text(
                _pages[_selectedPageIdx]['title'],
                textAlign: TextAlign.center,
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _addNewPoint(context),
                ),
                IconButton(
                  icon: Icon(Icons.more_horiz_outlined),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) {
                        return GestureDetector(
                          child: MainDrawer(
                            uid: widget.uid,
                            sendToHome: _sendToHome,
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
            body: _pages[_selectedPageIdx]['page'],
            floatingActionButton: Platform.isIOS
                ? Container()
                : _pages[_selectedPageIdx]['id'] == 'add-points'
                    ? FloatingActionButton(
                        onPressed: () => _addNewPoint(context),
                        child: Icon(
                          Icons.add,
                          color: Theme.of(context).primaryColorLight,
                        ),
                        elevation: 10,
                      )
                    : null,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedPageIdx,
              onTap: _selectPage,
              iconSize: 30.0,
              backgroundColor: Colors.white,
              elevation: 10,
              items: [
                BottomNavigationBarItem(
                  label: "Feed",
                  icon: Icon(Icons.person_add),
                ),
                BottomNavigationBarItem(
                  label: "Court",
                  icon: Icon(Icons.gavel),
                ),
                BottomNavigationBarItem(
                  label: "Members",
                  icon: Icon(Icons.people),
                ),
              ],
            ),
          );
  }
}
