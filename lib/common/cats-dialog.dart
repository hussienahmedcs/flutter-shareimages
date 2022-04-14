import 'package:flutter/material.dart';
import 'package:sharewallpaper/util/pref-mngr.dart';

class CatsDialog extends StatefulWidget {
  const CatsDialog({Key? key}) : super(key: key);

  @override
  _CatsDialogState createState() => _CatsDialogState();
}

class _CatsDialogState extends State<CatsDialog> {

  String cat = "";
  PrefMngr _mngr = new PrefMngr();
  List<Map<String, String>> cats = [
    {"title": "Cat1", "value": "CAT1"},
    {"title": "Cat2", "value": "CAT2"},
    {"title": "Cat3", "value": "CAT3"},
  ];

  @override
  void initState(){
    _mngr.getString("Category").then((_cat){
      print("cat:"+(_cat??"CAT1"));
      setState(() {
        cat = _cat;
      });
    });
    // print(cat);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Category'),
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: cats
            .map((e) => ListTile(
          title: Text(e['title'].toString()),
          leading: Radio(
            value: e['value'].toString(),
            groupValue: cat,
            onChanged: (value) {
              setState(() {
                cat = value.toString();
                print(cat);
                _mngr.setString("Category", cat);
              });
            },
          ),
        ))
            .toList(),
      ),
      actions: [],
    );
  }
}
