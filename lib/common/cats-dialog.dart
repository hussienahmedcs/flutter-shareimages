import 'package:flutter/material.dart';
import 'package:sharewallpaper/util/data-repository.dart';
import 'package:sharewallpaper/util/pref-mngr.dart';

class CatsDialog extends StatefulWidget {
  const CatsDialog({Key? key}) : super(key: key);

  @override
  _CatsDialogState createState() => _CatsDialogState();
}

class _CatsDialogState extends State<CatsDialog> {
  String cat = "";
  final DataRepository repository = DataRepository();
  final PrefMngr _mngr =  PrefMngr();
  List<Map<String, String>> cats = [];

  @override
  void initState() {
    repository.fs.collection("cats").get().then((value) {
      setState(() {
        cats = [
          {"label": "Recent", "value": "RECENT"},
          {"label": "Top Rate", "value": "TOP_RATE"},
        ];
        cats.addAll(value.docs
            .map((e) => e.data())
            .map((e) => ({
                  "label": e["name_en"].toString(),
                  "value": e["id"].toString()
                }))
            .toList());

        _mngr.getString("Category").then((_cat) {
          setState(() {
            // if (_cat) cat = _cat;
            cat = _cat;
          });
        });
      });
    });
    super.initState();
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
                  title: Text(e['label'].toString()),
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
