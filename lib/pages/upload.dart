import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sharewallpaper/util/SizeConfig.dart';
import 'package:sharewallpaper/util/data-repository.dart';
import 'package:sharewallpaper/util/helper.dart';
import 'package:get/get.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final String _imagePlaceholder = "assets/upload.png";
  Uint8List? bytes;
  final DataRepository repository = DataRepository();
  final Helper helper = Helper();

  _upload() async {
    String id = repository.createId();
    String deviceId = await repository.getDeviceId();

    helper.showLoader();
    repository.fsStorage
        .ref("files/${id}.png")
        .putData(bytes!)
        .whenComplete(() {
      helper.compressImage(bytes!, 400, 400, 10).then((compressedImage) {
        repository.fsStorage
            .ref("files/${id}.thumbnail.png")
            .putData(compressedImage)
            .whenComplete(() {
            var payload = {
              "image": id,
              "deviceId": deviceId,
              "cat_id": _selectedcat
            };
          repository.fs.collection("images").doc(id).set(payload).then((value){
            helper.hideLoader();
            //back/redirect to profile
            String prev = Get.previousRoute;
            print(prev);
            Navigator.pushReplacementNamed(context, "/profile");
          });
        });
      });
    });

    //start upload details
    // helper.compressImage(bytes!, 400, 400, 20).then((compressedImage) {
    //   helper.showLoader();
    //   var payload = {
    //     "id": id,
    //     "image": compressedImage,
    //     "deviceId": deviceId,
    //     "cat_id": _selectedcat
    //   };
    //   repository.fs.collection("images").doc(id).set(payload).then((value) {
    //     print("Uploaded");
    //     helper.hideLoader();
    //   });
    // });
  }

  _uploadImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );

    setState(() {
      if (result != null && result.files.first.path != null) {
        // bytes = result.files.first.bytes;
        String? path = result.files.first.path;
        File file = File(path!);
        bytes = file.readAsBytesSync();
        file.delete();
      } else {
        print("Test2");
        bytes = null;
      }
    });
  }

  List<Map<String, dynamic>> items = [];

  //   // {"label": "Recent Uploads", "value": "1"},
  //   // {"label": "Top Rate", "value": "2"},
  //   {"label": "Nature", "value": "3"},
  //   {"label": "Quran", "value": "4"},
  //   {"label": "Desert", "value": "5"},
  //   {"label": "Girls", "value": "6"},
  //   {"label": "Babies", "value": "7"},
  //   {"label": "Persons", "value": "8"},
  //   {"label": "TEST TEST TEST TEST TEST TEST", "value": "9"},
  // ];
  var _selectedcat;

  @override
  void initState() {
    repository.fs.collection("cats").get().then((value) {
      setState(() {
        items = value.docs.map((e) {
          return {"value": e.data()["id"], "label": e.data()["name_en"]};
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8FA),
      appBar: AppBar(
        title: const Text('Upload'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _uploadImage,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                height: 22 * SizeConfig.heightMultiplier,
                width: 44 * SizeConfig.widthMultiplier,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: bytes == null
                          ? Image.asset(_imagePlaceholder).image
                          : Image.memory(bytes!).image),
                ),
              ),
            ),
            DropdownButton(
              // Initial Value
              value: _selectedcat,

              // Down Arrow Icon
              icon: const Icon(Icons.keyboard_arrow_down),

              // Array list of items
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item["value"],
                  child: Text(item["label"].toString()),
                );
              }).toList(),
              // After selecting the desired option,it will
              // change button value to selected value
              onChanged: (newValue) {
                setState(() {
                  _selectedcat = newValue;
                });
              },
            ),
            FlatButton(
              onPressed: _upload,
              color: Colors.orange,
              padding: EdgeInsets.all(10.0),
              child: Column(
                // Replace with a Row for horizontal icon + text
                children: <Widget>[Icon(Icons.cloud_upload), Text("Upload")],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
