import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

class AddPoint extends StatefulWidget {
  final String teamId;
  final String uid;
  final String name;
  final String pointName;
  final List<dynamic> data;

  AddPoint({
    @required this.teamId,
    @required this.uid,
    @required this.name,
    @required this.pointName,
    @required this.data,
  });
  @override
  _AddPointState createState() => _AddPointState();
}

class _AddPointState extends State<AddPoint> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  var _points = [10, 5, 2, 1, -1, -2, -5, -10];

  var _selTo;
  var _selPoints;
  var _newReason;

  var _isLoading = false;

  Future<void> _addPoint() async {
    final isValid = formKey.currentState.validate();
    if (isValid) {
      formKey.currentState.save();
      setState(() {
        _isLoading = true;
      });

      final msg = {
        'to': widget.data[_selTo]['name'],
        'toId': widget.data[_selTo]['uid'],
        'from': widget.name,
        'fromId': widget.uid,
        'points': _points[_selPoints],
        'reason': _newReason,
        'challenged': false,
        'timestamp': Timestamp.now(),
      };
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        try {
          FirebaseFirestore.instance
              .collection('teams/${widget.teamId}/points')
              .add(msg);
          final mem = await FirebaseFirestore.instance
              .doc(
                  'teams/${widget.teamId}/members/${widget.data[_selTo]['uid']}')
              .get();
          await FirebaseFirestore.instance
              .doc(
                  'teams/${widget.teamId}/members/${widget.data[_selTo]['uid']}')
              .update({
            'currentPoints': mem.get('currentPoints') + _points[_selPoints]
          });
        } catch (error) {
          print(error);
          // TODO: Handle error
          //_infoPopUp();
        }
      } else {
        //_infoPopUp();
      }
      _selTo = null;
      _selPoints = null;
      _newReason = null;
      Navigator.of(context).pop();
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Card(
                      color: Theme.of(context).primaryColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 0.0),
                        child: Text(
                          'Give ${widget.pointName} Points',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                    ),
                  ),
                  _isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Card(
                          child: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: _addPoint,
                          ),
                          color: Theme.of(context).accentColor,
                        ),
                ],
              ),
            ),
            Card(
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      DropdownButtonFormField(
                        onChanged: (value) {
                          _selPoints = value;
                        },
                        value: _selPoints,
                        hint: Text('${widget.pointName} Points'),
                        items: List.generate(
                          _points.length,
                          (index) => DropdownMenuItem(
                            child: Text(_points[index].toString()),
                            value: index,
                          ),
                        ),
                        validator: (value) {
                          var text;
                          if ((value == null) ||
                              (value < 0) ||
                              (value >= _points.length)) {
                            text = 'How many points are you giving?';
                          } else {
                            text = null;
                          }
                          return text;
                        },
                      ),
                      DropdownButtonFormField(
                        onChanged: (value) {
                          _selTo = value;
                        },
                        value: _selTo,
                        hint: Text('Who Should Get These Points?'),
                        items: List.generate(
                          widget.data.length,
                          (index) => DropdownMenuItem(
                            child: Text(widget.data[index]['name']),
                            value: index,
                          ),
                        ),
                        validator: (value) {
                          var text;
                          if ((value == null) ||
                              (value < 0) ||
                              (value >= widget.data.length)) {
                            text = 'Who is getting the points?';
                          } else {
                            text = null;
                          }
                          return text;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Reason',
                          alignLabelWithHint: true,
                        ),
                        textInputAction: TextInputAction.done,
                        maxLines: 5,
                        onSaved: (value) {
                          _newReason = value;
                        },
                        validator: (value) {
                          var text;
                          if (value.isEmpty) {
                            text =
                                'Without a reason this will never stand up in court...';
                          } else {
                            text = null;
                          }
                          return text;
                        },
                      ),
                      SizedBox(
                        height: 25,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
