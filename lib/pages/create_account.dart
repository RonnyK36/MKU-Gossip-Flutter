import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mku_gossip/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String username;
  submit() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      Navigator.pop(context, username);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome $username, your account was created!'),
        ),
      );
      print(username);
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, username);
        print(username);
      });
    }

    // }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(
        context,
        titleText: "Set up your profile",
        removeBackButton: true,
      ),
      body: ListView(
        children: [
          Container(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 25),
                  child: Center(
                    child: Text(
                      'Add a username',
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Container(
                    child: Form(
                      // autovalidate: true,
                      key: _formKey,
                      child: TextFormField(
                        validator: (value) {
                          if (value.trim().length < 3) {
                            return 'Username is too short';
                          } else if (value.trim().length > 15) {
                            return 'Username is too long';
                          } else {
                            username = value;
                            return null;
                          }
                        },
                        onSaved: (value) => username = value,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Username",
                            labelStyle: TextStyle(fontSize: 15),
                            hintText: "At least 3 characters"),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submit,
                  child: Container(
                    height: 60,
                    width: 325,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(7)),
                    child: Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
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
