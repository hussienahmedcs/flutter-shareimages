import 'package:flutter/material.dart';
import 'package:sharewallpaper/common/cats-dialog.dart';
import 'package:sharewallpaper/util/pref-mngr.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? cat = "";
  PrefMngr _mngr = new PrefMngr();

  @override
  void initState() {
    init();
    // print(cat);
  }

  void init(){
    _mngr.getString("Category").then((_cat) {
      setState(() {
        cat = _cat;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          PopupMenuButton(
            onSelected: (itemValue) {
              switch (itemValue) {
                case 0:
                  //select category
                  showDialog(
                      context: context,
                      builder: (ctx) => const CatsDialog()).then((value) => setState((){
                        init();
                  }));
                  break;
                case 1:
                  //GO TO UPLOAD PAGE
                Navigator.pushNamed(context, "/upload");
                  break;
                case 2:
                  Navigator.pushNamed(context, "/profile");
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                child: Text("Category"),
                value: 0,
              ),
              const PopupMenuItem(
                child: Text("Upload"),
                value: 1,
              ),
              const PopupMenuItem(
                child: Text("Profile"),
                value: 2,
              ),
            ],
          )
        ],
      ),
      body: Center(
        child: Text('Hello $cat'),
      ),
    );
  }
}
