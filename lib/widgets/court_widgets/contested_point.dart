import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ContestedPoint extends StatefulWidget {
  final String to;
  final String from;
  final String reason;
  final int points;
  final Timestamp timestamp;
  final String docId;
  final int rejectVotes;
  final int acceptVotes;
  final bool hasVoted;
  final String toId;
  final String teamId;
  final String uid;

  ContestedPoint({
    @required this.to,
    @required this.from,
    @required this.reason,
    @required this.points,
    @required this.timestamp,
    @required this.docId,
    @required this.rejectVotes,
    @required this.acceptVotes,
    @required this.hasVoted,
    @required this.toId,
    @required this.teamId,
    @required this.uid,
  });

  @override
  _ContestedPointState createState() => _ContestedPointState();
}

class _ContestedPointState extends State<ContestedPoint> {
  Future<void> _sendVote(
    BuildContext ctx,
    String type,
    int currVal,
  ) async {
    int newVal = currVal + 1;
    final courtDoc = await FirebaseFirestore.instance
        .doc('teams/${widget.teamId}/court/${widget.docId}')
        .get();
    final List<dynamic> hasVotedList = courtDoc.get('hasVoted');
    hasVotedList.add(widget.uid);
    await FirebaseFirestore.instance
        .doc('teams/${widget.teamId}/court/${widget.docId}')
        .update(
      {
        type: newVal,
        'hasVoted': hasVotedList,
      },
    );
    Navigator.of(ctx).pop();
    setState(() {});
  }

  void _castVote(String docId) {
    showDialog<Null>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Vote'),
        content: SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.20,
                child: Card(
                  elevation: 5.0,
                  color: Color(0xffff7076),
                  child: IconButton(
                    onPressed: () => _sendVote(
                      ctx,
                      'reject',
                      widget.rejectVotes,
                    ),
                    icon: Icon(Icons.cancel),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.20,
                child: Card(
                  elevation: 5.0,
                  color: Colors.lightGreen,
                  child: IconButton(
                    onPressed: () => _sendVote(
                      ctx,
                      'accept',
                      widget.acceptVotes,
                    ),
                    icon: Icon(Icons.check_circle),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 17,
                color: Colors.black,
              ),
            ),
          ),
        ],
        contentPadding: EdgeInsets.only(
          top: 24.0,
          left: 24.0,
          right: 24.0,
          bottom: 0,
        ),
      ),
    );
    setState(() {});
  }

  void _msgPopUp({
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
              style: TextStyle(
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              '${DateFormat.yMMMd().format(widget.timestamp.toDate()).toString()} - ${DateFormat.jms().format(widget.timestamp.toDate()).toString()}',
            ),
          ),
          Card(
            elevation: 6.0,
            child: Column(
              children: [
                ListTile(
                  onTap: () => _msgPopUp(
                    to: widget.to,
                    from: widget.from,
                    points: widget.points,
                    reason: widget.reason,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).accentColor,
                    child: Text(
                      widget.points.toString(),
                      style: TextStyle(fontSize: 25),
                    ),
                    radius: 30.0,
                  ),
                  title: Card(
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
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(5.0),
                        color: Color(0xffff7076),
                        child: Text(
                          'Reject: ${widget.rejectVotes}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(5.0),
                        color: Colors.lightGreen,
                        child: Text(
                          'Accept: ${widget.acceptVotes}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: widget.hasVoted
                      ? Text(
                          'Vote has been cast!',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        )
                      : Card(
                          color: Theme.of(context).primaryColor,
                          elevation: 5,
                          child: FlatButton.icon(
                            onPressed: () => _castVote(widget.docId),
                            icon: Icon(Icons.how_to_vote),
                            label: Text(
                              'Cast Vote',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
