import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mku_gossip/widgets/header.dart';
import 'package:mku_gossip/widgets/progress.dart';

final userRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  void initState() {
    // getUser();
    createUser();
    super.initState();
  }

  createUser() async {
    await userRef.add({
      "username": "Kevin",
      "postCount": 0,
      "isAdmin": false,
    });
  }

  updateUser() async {
    final DocumentSnapshot doc = await userRef.document('').get();
    if (doc.exists) {
      doc.reference.updateData({
        "username": "John",
        "postCount": 0,
        "isAdmin": false,
      });
    }
  }

  deleteUser() async {
    final DocumentSnapshot doc = await userRef.document('').get();
    if (doc.exists) {
      doc.reference.delete();
    }
  }

  // getUser() async {
  //   final QuerySnapshot snapshot = await userRef
  //       .where(
  //         'isAdmin',
  //         isEqualTo: false,
  //       )
  //       .where('username', isEqualTo: 'Kevin')
  //       .getDocuments();
  //
  //   snapshot.documents.forEach((DocumentSnapshot doc) {
  //     print(doc.data);
  //     print(doc.documentID);
  //   });
  // }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(
        context,
        isAppTittle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: userRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          final List<Text> children = snapshot.data.documents
              .map((doc) => Text(doc['username']))
              .toList();
          return Container(
            child: ListView(
              children: children,
            ),
          );
        },
      ),
    );
  }
}
