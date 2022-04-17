import 'package:flutter/material.dart';
import 'package:sharewallpaper/util/helper.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';
import 'package:http/http.dart' as http;

class CardGrid extends StatelessWidget {
  final String id;
  final List likes;
  final String logo;
  final VoidCallback? onPress;
  final VoidCallback? onLikePress;
  final String placeholder;
  final String? deviceId;

  CardGrid({
    required this.id,
    required this.likes,
    required this.logo,
    this.onPress,
    this.onLikePress,
    required this.placeholder,
    required this.deviceId,
  });

  final Helper helper = Helper();

  @override
  Widget build(BuildContext context) {
    return _card2();
  }

  void shareImage() async {
    String appId = "com.swiftapps.sharewallpaper";
    // Share.shareFiles([logo], text: 'Great picture');
    String url =
        "https://firebasestorage.googleapis.com/v0/b/shareimages-b9e75.appspot.com/o/files%2F$id.png?alt=media";
    http.Response response = await http.get(Uri.parse(url));

    await WcFlutterShare.share(
      sharePopupTitle: 'share',
      subject: 'This is subject',
      text:
          'shared from Sharewallpaper App download from https://play.google.com/store/apps/details?id=$appId',
      fileName: 'image.png',
      mimeType: 'image/png',
      bytesOfFile: response.bodyBytes,
    );
  }

  // Widget _card1() {
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: GestureDetector(
  //       onTap: onPress,
  //       child: Container(
  //         width: double.infinity,
  //         height: 500,
  //         decoration: BoxDecoration(
  //           image: DecorationImage(
  //             image:
  //                 // FadeInImage.assetNetwork(
  //                 //   placeholder: placeholder,
  //                 //   image: logo,
  //                 //   fit: BoxFit.cover,
  //                 // ).image,
  //
  //                 NetworkImage(
  //               logo,
  //             ),
  //             fit: BoxFit.cover,
  //           ),
  //           borderRadius: BorderRadius.all(Radius.circular(10)),
  //         ),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: <Widget>[
  //             Expanded(child: SizedBox()),
  //             // Padding(
  //             //   padding: const EdgeInsets.only(left: 4.0),
  //             //   child: Text(title, style: headStyle1),
  //             // ),
  //             GestureDetector(
  //               onTap: onLikePress,
  //               child: Container(
  //                   height: 40,
  //                   width: 80,
  //                   decoration: BoxDecoration(
  //                     color: Colors.blue[600],
  //                     borderRadius: BorderRadius.all(Radius.circular(20)),
  //                   ),
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: Center(
  //                         child: Row(
  //                       children: <Widget>[
  //                         Icon(
  //                           rating % 2 == 0
  //                               ? Icons.thumb_up_alt_outlined
  //                               : Icons.thumb_up,
  //                           color: Colors.white,
  //                         ),
  //                         SizedBox(
  //                           width: 10,
  //                         ),
  //                         Text(
  //                           rating.toString(),
  //                           style: TextStyle(fontSize: 15, color: Colors.white),
  //                         ),
  //                       ],
  //                     )),
  //                   )),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _card2() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Stack(
        children: [
          GestureDetector(
            onTap: onPress,
            child: SizedBox(
              width: double.infinity,
              height: 500,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: FadeInImage.assetNetwork(
                  placeholder: placeholder,
                  image: logo,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: onLikePress,
                    child: Container(
                        height: 40,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                              child: Row(
                            children: <Widget>[
                              Icon(
                                !likes.contains(deviceId)
                                    ? Icons.thumb_up_alt_outlined
                                    : Icons.thumb_up,
                                color: Colors.blue,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                likes.length.toString(),
                                style: TextStyle(
                                    fontSize: 15, color: Colors.white),
                              ),
                            ],
                          )),
                        )),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.5),
                        shape: BoxShape.circle),
                    // padding: const EdgeInsets.all(8.0),
                    child: PopupMenuButton(
                      onSelected: (itemValue) {
                        switch (itemValue) {
                          case 0:
                            shareImage();
                            break;
                          case 1:
                            helper.showToast("Hello!");
                            break;
                          case 2:
                            break;
                          case 3:
                            helper.showToast("download started");
                            helper.downloadFromUrl(logo).then((res) {
                              helper.showToast("Download completed");
                              print(res);
                            });
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(
                                Icons.share,
                                color: Colors.blue[600],
                              ),
                              const Text("Share")
                            ],
                          ),
                          value: 0,
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(
                                Icons.report,
                                color: Colors.blue[600],
                              ),
                              const Text("Report")
                            ],
                          ),
                          value: 1,
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(
                                Icons.image,
                                color: Colors.blue[600],
                              ),
                              Text("Set As")
                            ],
                          ),
                          value: 2,
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(
                                Icons.download,
                                color: Colors.blue[600],
                              ),
                              const Text("Download")
                            ],
                          ),
                          value: 3,
                        ),
                      ],
                    )
                    // const Icon(
                    //   Icons.more_vert,
                    //   color: Colors.white,
                    // )
                    ,
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
