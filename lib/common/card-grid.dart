import 'package:flutter/material.dart';
import 'package:sharewallpaper/util/helper.dart';
import 'package:sharewallpaper/util/sound-handler.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';
import 'package:http/http.dart' as http;

class CardGrid extends StatelessWidget {
  final String id;
  final String likes;
  final bool liked;
  final bool isFav;
  final String logo;
  final VoidCallback? onPress;
  final VoidCallback? onLikePress;
  final VoidCallback? onFavPress;
  final String placeholder;

  CardGrid({
    required this.id,
    required this.likes,
    required this.liked,
    required this.isFav,
    required this.logo,
    this.onPress,
    this.onLikePress,
    this.onFavPress,
    required this.placeholder,
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
        "https://firebasestorage.googleapis.com/v0/b/shareimages-b9e75.appspot.com/o/files%2F${id}.png?alt=media";
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
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            // mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FlatButton(
                onPressed: onFavPress,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: Colors.blue[600],
                    size: 36,
                  ),
                ),
              ),
              Spacer(),
              Row(
                children: [
                  SoundClick(
                    onTap: onLikePress,
                    child: Container(
                        height: 40,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.7),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                              child: Row(
                            children: <Widget>[
                              Icon(
                                liked
                                    ? Icons.thumb_up
                                    : Icons.thumb_up_alt_outlined,
                                color: Colors.blue,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                likes.toString(),
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )),
                        )),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.7),
                        shape: BoxShape.circle),
                    // padding: const EdgeInsets.all(8.0),
                    child: PopupMenuButton(
                      icon: Icon(Icons.more_vert, color: Colors.white),
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
