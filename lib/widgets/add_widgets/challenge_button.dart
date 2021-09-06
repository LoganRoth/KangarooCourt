import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

class ChallengeButton extends StatefulWidget {
  final String teamId;
  final String uid;
  final String docId;
  final bool challenged;
  final bool isMe;

  ChallengeButton({
    @required this.challenged,
    @required this.teamId,
    @required this.uid,
    @required this.docId,
    @required this.isMe,
  });
  @override
  _ChallengeButtonState createState() => _ChallengeButtonState();
}

class _ChallengeButtonState extends State<ChallengeButton> {
  bool _isChallenging = false;
  Future<void> _challengePoint(String docId) async {
    setState(() {
      _isChallenging = true;
    });
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('teams/${widget.teamId}/points')
            .doc(docId)
            .get();
        await FirebaseFirestore.instance
            .doc('teams/${widget.teamId}/points/$docId')
            .update({'challenged': true});
        await FirebaseFirestore.instance
            .collection('teams/${widget.teamId}/court')
            .add(
          {
            'to': doc.get('to'),
            'from': doc.get('from'),
            'reason': doc.get('reason'),
            'points': doc.get('points'),
            'timestamp': doc.get('timestamp'),
            'challenged': true,
            'toId': doc.get('toId'),
            'reject': 0,
            'accept': 0,
            'hasVoted': [],
          },
        );
      } catch (error) {
        // TODO: error pop up
      }
    } else {
      //_infoPopUp();
    }
    setState(() {
      _isChallenging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.challenged
        ? Card(
            elevation: 0,
            child: IconButton(
              icon: Icon(
                Icons.account_balance,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: null,
            ),
          )
        : widget.isMe
            ? Card(
                elevation: 5,
                child: IconButton(
                  icon: _isChallenging
                      ? Icon(Icons.more_horiz)
                      : Icon(Icons.gavel),
                  onPressed: () => _challengePoint(widget.docId),
                ),
              )
            : Card(
                elevation: 0,
              );
  }
}
