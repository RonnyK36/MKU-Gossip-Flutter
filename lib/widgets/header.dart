import 'package:flutter/material.dart';

AppBar header(context,
    {bool isAppTittle = false, String titleText, removeBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
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
