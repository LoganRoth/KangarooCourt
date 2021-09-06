import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kangaroo_court/widgets/add_widgets/new_point.dart';

class AddPointScreen extends StatefulWidget {
  final String teamId;
  final String uid;

  AddPointScreen({
    @required this.teamId,
    @required this.uid,
  });
  @override
  _AddPointScreenState createState() => _AddPointScreenState();
}

class _AddPointScreenState extends State<AddPointScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: FirebaseFirestore.instance
            .collection('teams/${widget.teamId}/points')
            .orderBy(
              'timestamp',
              descending: true,
            )
            .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final QuerySnapshot ptDocs = snapshot.data;
          final data = ptDocs.docs;
          return data.length == 0
              ? Center(
                  child: Text(
                    'No points in feed...',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (ctx, idx) => NewPoint(
                    to: data[idx].get('to'),
                    from: data[idx].get('from'),
                    reason: data[idx].get('reason'),
                    points: data[idx].get('points'),
                    timestamp: data[idx].get('timestamp'),
                    challenged: data[idx].get('challenged'),
                    docId: data[idx].id,
                    teamId: widget.teamId,
                    uid: widget.uid,
                    isMe: data[idx].get('toId') == widget.uid,
                  ),
                );
        });
  }
}
