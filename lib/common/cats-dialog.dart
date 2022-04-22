import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sharewallpaper/util/data-repository.dart';
import 'package:sharewallpaper/util/helper.dart';
import 'package:sharewallpaper/util/pref-mngr.dart';

class CatsDialog extends StatefulWidget {
  const CatsDialog({Key? key}) : super(key: key);

  @override
  _CatsDialogState createState() => _CatsDialogState();
}

class _CatsDialogState extends State<CatsDialog> {
  String cat = "";
  final DataRepository repository = DataRepository();
  final PrefMngr _mngr = PrefMngr();
  List<Map<String, String>> cats = [];
  final Helper helper = Helper();

  getCats() async {
    String? _cat = await _mngr.getString("Category");
    setState(() {
      cat = _cat ?? "";
    });
    helper.getGeneric("cats", {"--accept-language": "EN"}).then((value) {
      Map json = jsonDecode(value.body);
      if (mounted) {
        setState(() {
          List ls = json["items"];
          cats = ls
              // .where((e) => e["is_dynamic"] == 1)
              .map((e) => ({
                    "label": e["name"].toString(),
                    "value": e["id"].toString()
                  }))
              .toList();
        });
      }
    });
  }

  @override
  void initState() {
    getCats();
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
