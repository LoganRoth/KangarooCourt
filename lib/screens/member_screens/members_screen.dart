import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kangaroo_court/widgets/member_widgets/member.dart';

class MembersScreen extends StatefulWidget {
  final String teamId;
  final String uid;
  final String award;

  MembersScreen({
    @required this.teamId,
    @required this.uid,
    @required this.award,
  });
  @override
  _MembersScreenState createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  var data = [];

  String _getWinner() {
    final int winIdx = data.indexWhere((element) => element['winner']);
    String name = '';
    if (!winIdx.isNegative) {
      name = data[winIdx]['name'];
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object>(
        future: FirebaseFirestore.instance
            .collection('teams/${widget.teamId}/members')
            .orderBy(
              'name',
            )
            .get(),
        builder: (context, futureSnapshot) {
          if (futureSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final QuerySnapshot futureData = futureSnapshot.data;
          final dataDocs = futureData.docs;
          data = [];
          dataDocs.forEach((element) {
            data.add({
              'name': element.get('name'),
              'uid': element.id,
              'winner': element.get('winner'),
              'currentPoints': element.get('currentPoints'),
            });
          });
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Card(
                    color: Theme.of(context).primaryColor,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, left: 8.0, right: 8.0),
                          child: Text(
                            '${widget.award}',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.military_tech),
                                  Expanded(
                                    child: Text(
                                      _getWinner(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.military_tech),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (ctx, idx) => Member(
                      name: data[idx]['name'],
                      isMe: data[idx]['uid'] == widget.uid,
                      currentPoints: data[idx]['currentPoints'],
                      winner: data[idx]['winner'],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
