import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sharewallpaper/util/SizeConfig.dart';
import 'package:sharewallpaper/util/data-repository.dart';
import 'package:sharewallpaper/util/helper.dart';
import 'package:get/get.dart';
import 'package:sharewallpaper/util/pref-mngr.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final int MAX_SIZE = 1024 * 1024 * 10; //10MB
  List<Map<String, dynamic>> cats = [];
  final String _imagePlaceholder = "assets/placeholder1.png";
  Uint8List? bytes;
  final DataRepository repository = DataRepository();
  final Helper helper = Helper();
  bool isAddNew = false;
  String? catNameEn, catNameAr;
  final PrefMngr _mngr = PrefMngr();

  addNewCat() async {
    helper.showLoader();
    String id = await repository.getDeviceId();
    Map<String, String> payload = {
      "device_id": id,
      "name_en": catNameEn!,
      "name_ar": catNameAr!
    };
    helper.postGeneric("cats", payload).then((v) {
      setState(() {
        isAddNew = false;
        var id = (json.decode(v.body) as Map)["NEW_ID"];
        print(id);
        _selectedcat = id;
        cats.add({"label": catNameEn, "value": id});
      });
      helper.hideLoader();
    });
  }

  _upload() async {
    String userId = await helper.getUserId();
    // String id = repository.createId();
    // String deviceId = await repository.getDeviceId();

    helper.showLoader();
    // repository.fsStorage
    //     .ref("files/${id}.png")
    //     .putData(bytes!)
    //     .whenComplete(() {
    helper.compressImage(bytes!, 200, 200, 20).then((compressedImage) {
      String img = helper.uint8ListTob64(bytes!);
      String thumb = helper.uint8ListTob64(compressedImage);
      // print(img);
      // print(img.length);
      // print(thumb.length);
      helper.postGeneric("post", {
        "CAT_ID": _selectedcat.toString(),
        "IMAGE_DATA": img,
        "IMAGE_THUMBNAIL": thumb,
        "USER_ID": userId
      }).then((value) {
        print(value.body);
        helper.hideLoader();
        _mngr.setString("Category", _selectedcat.toString()).then((value) {
          Navigator.pop(context, true);
        });
      });
    });
    //     repository.fsStorage
    //         .ref("files/${id}.thumbnail.png")
    //         .putData(compressedImage)
    //         .whenComplete(() {
    //       var payload = {
    //         "image": id,
    //         "deviceId": deviceId,
    //         "cat_id": _selectedcat,
    //         "uploadedAt": Timestamp.now()
    //       };
    //       repository.fs.collection("images").doc(id).set(payload).then((value) {
    //         helper.hideLoader();
    //         Navigator.pushReplacementNamed(context, "/profile");
    //       });
    //     });
    //   });
    // });
  }

  _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );

    setState(() {
      if (result != null && result.files.first.path != null) {
        // bytes = result.files.first.bytes;
        String? path = result.files.first.path;
        print(path);
        File file = File(path!);
        int size = result.files.first.size;
        print(size);
        if (size > MAX_SIZE) {
          //print file bigger than 5mb
          helper.showToast("selected file ($size byte) bigger than 5MB");
        } else {
          bytes = file.readAsBytesSync();
        }
        file.delete();
      } else {
        bytes = null;
      }
    });
  }

  var _selectedcat;

  @override
  void initState() {
    getCats();
  }

  getCats() {
    helper.getGeneric("cats", {"--accept-language": "EN"}).then((value) {
      Map json = jsonDecode(value.body);
      if (mounted)
        setState(() {
          List ls = json["items"];
          cats = ls
              .where((e) => e["is_dynamic"] == 1)
              .map((e) => ({"label": e["name"], "value": e["id"]}))
              .toList();
          // items =  as ;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        _headerCard(),
        Padding(
          padding: EdgeInsets.only(top: 25 * SizeConfig.heightMultiplier),
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30.0),
                topLeft: Radius.circular(30.0),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _imageCard(),
                  _catCard(),
                  isAddNew ? _addNewCard() : _btnCard(),
                ],
              ),
            ),
          ),
        )
      ],
    )
        //   Scaffold(
        //   backgroundColor: const Color(0xffF8F8FA),
        //   appBar: AppBar(
        //     title: const Text('Upload'),
        //   ),
        //   body: Padding(
        //     padding: const EdgeInsets.all(8.0),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.center,
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         GestureDetector(
        //           onTap: _uploadImage,
        //           child: Container(
        //             padding: const EdgeInsets.all(16.0),
        //             height: 22 * SizeConfig.heightMultiplier,
        //             width: 44 * SizeConfig.widthMultiplier,
        //             decoration: BoxDecoration(
        //               shape: BoxShape.rectangle,
        //               image: DecorationImage(
        //                   fit: BoxFit.cover,
        //                   image: bytes == null
        //                       ? Image.asset(_imagePlaceholder).image
        //                       : Image.memory(bytes!).image),
        //             ),
        //           ),
        //         ),
        //         DropdownButton(
        //           // Initial Value
        //           value: _selectedcat,
        //
        //           // Down Arrow Icon
        //           icon: const Icon(Icons.keyboard_arrow_down),
        //
        //           // Array list of items
        //           items: items.map((item) {
        //             return DropdownMenuItem(
        //               value: item["value"],
        //               child: Text(item["label"].toString()),
        //             );
        //           }).toList(),
        //           // After selecting the desired option,it will
        //           // change button value to selected value
        //           onChanged: (newValue) {
        //             setState(() {
        //               _selectedcat = newValue;
        //             });
        //           },
        //         ),
        //         FlatButton(
        //           onPressed: _upload,
        //           color: Colors.orange,
        //           padding: EdgeInsets.all(10.0),
        //           child: Column(
        //             // Replace with a Row for horizontal icon + text
        //             children: <Widget>[Icon(Icons.cloud_upload), Text("Upload")],
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // )
        ;
  }

  Widget _headerCard() {
    return Container(
      color: Colors.blue[600],
      height: 30 * SizeConfig.heightMultiplier,
      child: Padding(
          padding: EdgeInsets.only(
              left: 30.0, right: 30.0, top: 5 * SizeConfig.heightMultiplier),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                  )),
              Center(
                child: Column(
                  children: [
                    Text(
                      "Upload Image",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 3 * SizeConfig.textMultiplier,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 3 * SizeConfig.heightMultiplier,
                    ),
                    Text(
                      "Please upload high quality image so it can be used as wallpaper",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 2 * SizeConfig.textMultiplier,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }

  Widget _imageCard() {
    return GestureDetector(
      onTap: _pickImage,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
    );
  }

  Widget _catCard() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const Text("Select Category"),
          Spacer(),
          ConstrainedBox(
            constraints: const BoxConstraints(
              // minHeight: 5.0,
              minWidth: 200.0,
              // maxHeight: 30.0,
              // maxWidth: 30.0,
            ),
            child: DropdownButton(
              alignment: Alignment.center,
              // Initial Value
              value: _selectedcat,

              // Down Arrow Icon
              icon: const Icon(Icons.keyboard_arrow_down),

              // Array list of items
              items: cats.map((item) {
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
          ),
          GestureDetector(
            onTap: () => setState(() {
              isAddNew = !isAddNew;
            }),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                isAddNew ? Icons.remove : Icons.add,
                color: Colors.blue[600],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _addNewCard() {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Enter category name in english',
              ),
              onChanged: (value) => catNameEn = value,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Enter category name in arabic',
              ),
              onChanged: (value) => catNameAr = value,
            ),
          ),
          FlatButton(onPressed: addNewCat, child: const Text("Save Category"))
        ],
      ),
    );
  }

  Widget _btnCard() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.lightBlueAccent),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: FlatButton(
        padding: const EdgeInsets.all(8.0),
        onPressed: _selectedcat == null || bytes == null ? null : _upload,
        child: Text(
          "Upload Image",
          style: TextStyle(
              color: Colors.blue[600],
              fontSize: 1.8 * SizeConfig.textMultiplier),
        ),
      ),
    );
  }
}
