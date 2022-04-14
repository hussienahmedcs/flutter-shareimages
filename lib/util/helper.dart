import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';

class Helper {
  showLoader() {
    EasyLoading.show(status: 'loading...');
  }

  hideLoader() {
    EasyLoading.dismiss();
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
    //
    return _controller;
  }
}
