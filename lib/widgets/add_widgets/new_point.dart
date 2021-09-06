import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kangaroo_court/widgets/add_widgets/challenge_button.dart';

class NewPoint extends StatefulWidget {
  final String to;
  final String from;
  final String reason;
  final int points;
  final Timestamp timestamp;
  final bool challenged;
  final String docId;
  final String teamId;
  final String uid;
  final bool isMe;

  NewPoint({
    @required this.to,
    @required this.from,
    @required this.reason,
    @required this.points,
    @required this.timestamp,
    @required this.challenged,
    @required this.docId,
    @required this.teamId,
    @required this.uid,
    @required this.isMe,
  });

  @override
  _NewPointState createState() => _NewPointState();
}

class _NewPointState extends State<NewPoint> {
  void _pointPopUp({
    String to,
    String from,
    int points,
    String reason,
  }) {
    showDialog<Null>(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        content: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.15,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'To: ',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      to,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'From: ',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      from,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Points: ',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      points.toString(),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Reason:',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  reason,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
        contentPadding: EdgeInsets.only(
          top: 24.0,
          left: 24.0,
          right: 24.0,
          bottom: 0,
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Done',
              style: TextStyle(fontSize: 17),
            ),
          )
        ],
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text(
            '${DateFormat.yMMMd().format(widget.timestamp.toDate()).toString()} - ${DateFormat.jms().format(widget.timestamp.toDate()).toString()}',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Card(
            elevation: 6.0,
            child: ListTile(
                tileColor: widget.challenged
                    ? Theme.of(context).primaryColor
                    : Colors.white,
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).accentColor,
                  child: Text(
                    widget.points.toString(),
                    style: TextStyle(fontSize: 25),
                  ),
                  radius: 30.0,
                ),
                title: GestureDetector(
                  onTap: () => _pointPopUp(
                    from: widget.from,
                    to: widget.to,
                    points: widget.points,
                    reason: widget.reason,
                  ),
                  child: Card(
                    color: widget.challenged
                        ? Theme.of(context).primaryColor
                        : Colors.white,
                    elevation: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'To: ',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              widget.to,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'From: ',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              widget.from,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Reason:',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.reason,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                trailing: ChallengeButton(
                  challenged: widget.challenged,
                  teamId: widget.teamId,
                  uid: widget.uid,
                  docId: widget.docId,
                  isMe: widget.isMe,
                )),
          ),
        ),
      ],
    );
  }
}
