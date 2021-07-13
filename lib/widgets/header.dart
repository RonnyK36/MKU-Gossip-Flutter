import 'package:flutter/material.dart';

AppBar header(context, {bool isAppTittle = false, String titleText}) {
  return AppBar(
    title: Text(
      isAppTittle ? 'MKU Gossips' : titleText,
      style: TextStyle(
        fontFamily: isAppTittle ? 'Signatra' : '',
        fontSize: isAppTittle ? 40 : 22,
      ),
    ),
    centerTitle: true,
  );
}
