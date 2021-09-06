import 'package:flutter/material.dart';

class Member extends StatelessWidget {
  final String name;
  final bool isMe;
  final int currentPoints;
  final bool winner;

  Member({
    @required this.name,
    @required this.isMe,
    @required this.currentPoints,
    @required this.winner,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      child: Card(
        elevation: 6.0,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                child: Text(
                  currentPoints.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                child: Icon(winner
                    ? Icons.military_tech
                    : isMe
                        ? Icons.person
                        : Icons.check_box_outline_blank),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
