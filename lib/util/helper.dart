import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:sharewallpaper/util/data-repository.dart';
import 'package:sharewallpaper/util/pref-mngr.dart';

class Helper {
  final PrefMngr _mngr = PrefMngr();
  final DataRepository repository = DataRepository();
  String imagePlaceHolder = "assets/placeholder1.png";
  final String baseUrl =
      "https://apex.oracle.com/pls/apex/husseinapps/wallpaper/";

  Future<String> getUserId() async {
    String? id = await _mngr.getString("USER_ID");
    return id == null ? "-1" : id.toString().trim();
  }

  Future<bool> setUserId(id) async {
    return _mngr.setString("USER_ID", id);
  }

  Future<http.Response> getGeneric(String url, Map<String, String>? headers) {
    print(url);
    return http.get(Uri.parse(baseUrl + url), headers: headers);
  }

  Future<http.Response> postGeneric(String url, Map<String, String> payload,
      {Map<String, String>? headers = null}) {
    print(url);
    print(payload);
    return http.post(Uri.parse(baseUrl + url), body: payload);
  }

  showLoader() {
    EasyLoading.show(status: 'loading...');
  }

  hideLoader() {
    EasyLoading.dismiss();
  }

  downloadFromUrl(url) {
    return ImageDownloader.downloadImage(url);
  }

  Future<Uint8List> compressImage(
      Uint8List list, int height, int width, int quality) async {
    var result = await FlutterImageCompress.compressWithList(
      list,
      minHeight: height,
      minWidth: width,
      quality: quality,
      // rotate: 135,
    );
    return result;
  }

  String uint8ListTob64(Uint8List uint8list) {
    String base64String = base64Encode(uint8list);
    String header = ""; //"""data:image/png;base64,";
    return header + base64String;
  }

  AnimationController initPlaceholder(TickerProviderStateMixin mThis,
      double width, double height, Function cb) {
    AnimationController? _controller;
    Animation? gradientPosition;
    //iniate placeholder for albums
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: mThis);

    gradientPosition = Tween<double>(
      begin: -3,
      end: 10,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    )..addListener(() {
        var widget = Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment(gradientPosition!.value, 0),
                  end: const Alignment(-1, 0),
                  colors: [Colors.black12, Colors.black26, Colors.black12])),
        );
        cb(widget);
      });
    _controller.repeat();
    // _controller.forward();
    //
    return _controller;
  }

  showToast(text) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      // backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  //-----------
  pushNotification(String likes, String post_id) {
    Map<String, dynamic> payload = {
      "to": "/topics/likesTopic",
      "data": {"likes": likes, "post": post_id}
    };
    Map<String, String> headers = {
      "Authorization":
          "key=AAAAfrv63I0:APA91bEZBgMC_6HOBy_nDv7cngHtguBl7CB5ZKn7D-tQAXN3qGtueJ82skdHxlXpZO0jGIC8wpc4yF1gFkH41z6RVy2qEgiEIbVFs-pTmiKoT2z7PIPCIPnl1dq-8GPAWKkHb6UX6Ai5",
      "Content-Type": "application/json"
    };
    http
        .post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
            body: jsonEncode(payload), headers: headers)
        .then((value) {
      // print(value.body);
    }).catchError(print);
  }

  registerToken(token) {}

  numberFormat(num) {
    int n = int.parse(num);
    if (n < 1000) {
      return n.toString();
    } else if (n >= 1000 && n < 1000000) {
      return (n / 1000).toString() + "K";
    } else {
      return (n / 1000000).toString() + "M";
    }
  }

  // handleFav(id) {
  //   _mngr.getString("FAVORITES").then((_fav) {
  //     List fav = jsonDecode(_fav ?? "[]");
  //     if (fav.contains(id)) {
  //       fav.remove(id);
  //     } else {
  //       fav.add(id);
  //     }
  //     String favStr = jsonEncode(fav);
  //     _mngr.setString("FAVORITES", favStr);
  //   });
  // }
}
