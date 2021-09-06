import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kangaroo_court/widgets/court_widgets/contested_point.dart';

class InSessionScreen extends StatefulWidget {
  final String teamId;
  final String uid;
  final String judgePwd;

  InSessionScreen({
    @required this.teamId,
    @required this.uid,
    @required this.judgePwd,
  });
  @override
  _InSessionScreenState createState() => _InSessionScreenState();
}

class _InSessionScreenState extends State<InSessionScreen> {
  var _isLoading = false;

  void _infoPopUp() {
    showDialog<Null>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occured'),
        content: Text('Password was incorrect.'),
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
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _tryAdjurnCourt() async {
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
                  if (widget.judgePwd == _passwordController.text) {
                    Navigator.of(ctx).pop();
                    await _adjurnCourt();
                  } else {
                    _infoPopUp();
                    setState(() {
                      _isLoading = false;
                    });
                  }
                  _passwordController.text = '';
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
  }

  bool _getIfVoted(List<dynamic> votedList) {
    final int idx = votedList.indexWhere((element) => element == widget.uid);
    return (idx >= 0);
  }

  Future<void> _adjurnCourt() async {
    setState(() {
      _isLoading = true;
    });
    /**
     * Get member docs and prep toIgnore and winner name
     */
    Map<String, int> toIgnore = {};
    Map<String, int> memberPts = {};
    String winner = '';
    List<String> winners = [''];
    bool multiWinners = false;
    bool winnerPicked = false;
    final memCol = await FirebaseFirestore.instance
        .collection('teams/${widget.teamId}/members')
        .get();
    final memDocs = memCol.docs;
    memDocs.forEach((element) {
      toIgnore[element.id] = 0;
    });

    /**
     * Determine points to ignore based on court
     */
    final QuerySnapshot courtCol = await FirebaseFirestore.instance
        .collection('teams/${widget.teamId}/court')
        .get();
    final courtDocs = courtCol.docs;
    courtDocs.forEach((element) {
      if (element.get('reject') > element.get('accept')) {
        int x = element.get('points');
        toIgnore[element.get('toId')] = toIgnore[element.get('toId')] + x;
      }
    });

    /**
     * Determine "winner"
     */
    memDocs.forEach((element) {
      memberPts[element.id] =
          element.get('currentPoints') - toIgnore[element.id];
      winner = element.id; // Prep winner variable for checking
    });
    memberPts.forEach((key, value) {
      if (value > memberPts[winner]) {
        winnerPicked = true;
        if (multiWinners) {
          winners = [];
          multiWinners = false;
        }
        winner = key;
      } else if (value == memberPts[winner]) {
        winners.addAll([key, winner]);
        winner = key;
        multiWinners = true;
      }
    });

    /** 
     * Clean up the team database
     * Remove all the points, set winner and everyone else to "winner" field to
     * false, and set inSession to false 
     */
    await FirebaseFirestore.instance
        .collection('teams/${widget.teamId}/points')
        .get()
        .then(
      (snapshot) {
        snapshot.docs.forEach((element) {
          element.reference.delete();
        });
      },
    );
    await FirebaseFirestore.instance
        .collection('teams/${widget.teamId}/court')
        .get()
        .then(
      (snapshot) {
        snapshot.docs.forEach((element) {
          element.reference.delete();
        });
      },
    );
    if (!winnerPicked) {
      winner = '';
    }
    memDocs.forEach((element) async {
      bool isWinner = (winner == element.id);
      await FirebaseFirestore.instance
          .doc('teams/${widget.teamId}/members/${element.id}')
          .update(
        {
          'currentPoints': 0,
          'winner': isWinner,
        },
      );
    });
    await FirebaseFirestore.instance.doc('teams/${widget.teamId}').update(
      {
        'inSession': false,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : StreamBuilder<Object>(
            stream: FirebaseFirestore.instance
                .collection('teams/${widget.teamId}/court')
                .orderBy(
                  'timestamp',
                  descending: true,
                )
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              final QuerySnapshot courtDocs = snapshot.data;
              final data = courtDocs.docs;
              return Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    width: double.infinity,
                    child: Card(
                      elevation: 10,
                      color: Theme.of(context).accentColor,
                      child: FlatButton.icon(
                        onPressed: _tryAdjurnCourt,
                        icon: Icon(Icons.gavel),
                        label: Text('Adjurn Court'),
                      ),
                    ),
                  ),
                  data.length == 0
                      ? Text(
                          'No points have been challenged...',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (ctx, idx) => ContestedPoint(
                              to: data[idx].get('to'),
                              from: data[idx].get('from'),
                              reason: data[idx].get('reason'),
                              points: data[idx].get('points'),
                              timestamp: data[idx].get('timestamp'),
                              rejectVotes: data[idx].get('reject'),
                              acceptVotes: data[idx].get('accept'),
                              hasVoted: _getIfVoted(data[idx].get('hasVoted')),
                              docId: data[idx].id,
                              toId: data[idx].get('toId'),
                              teamId: widget.teamId,
                              uid: widget.uid,
                            ),
                          ),
                        ),
                ],
              );
            },
          );
  }
}
