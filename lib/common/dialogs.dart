import 'package:flutter/material.dart';

class Dialogs {
  showLoginAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
       AlertDialog(
        title: const Text('You are not Registered?'),
        content: const Text('Do you want login or create new account?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: new Text('Yes'),
          ),
        ],
      ),
    ).then((value){
      if(value) {
        Navigator.pushNamed(context, "/login");
      }
    });
  }
}