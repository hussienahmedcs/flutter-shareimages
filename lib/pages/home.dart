import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sharewallpaper/common/card-grid.dart';
import 'package:sharewallpaper/common/cats-dialog.dart';
import 'package:sharewallpaper/common/dialogs.dart';
import 'package:sharewallpaper/util/SizeConfig.dart';
import 'package:sharewallpaper/util/data-repository.dart';
import 'package:sharewallpaper/util/helper.dart';
import 'package:sharewallpaper/util/pref-mngr.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isGrid = false;
  int selectedImageIndex = -1;
  String? cat = "";
  bool isGettingData = false;
  String title = "Share Wallpaper";
  final PrefMngr _mngr = PrefMngr();
  List imagesList = [];
  final Helper helper = Helper();
  final DataRepository repository = DataRepository();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  String? deviceId;
  String? reviewImage;
  final Dialogs dialogs = Dialogs();

  void listenToLikes() {
    DataRepository().msg.unsubscribeFromTopic("likesTopic");
    DataRepository().msg.subscribeToTopic("likesTopic");
    DataRepository().msg.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
    FirebaseMessaging.onMessage.listen((event) {
      String postId = event.data["post"].toString();
      String likes = event.data["likes"].toString();
      int index = imagesList
          .indexWhere((element) => element["id"].toString() == postId);
      if (index > -1 && mounted) {
        setState(() {
          imagesList[index]["likes"] = likes;
        });
      }
    });
  }

  void like(id) async {
    if (isGettingData) return;
    setState(() {
      isGettingData = true;
    });
    String USER_ID = await helper.getUserId();
    if (USER_ID == "-1") {
      dialogs.showLoginAlert(context);
      return;
    }
    int index =
        imagesList.indexWhere((element) => element["id"].toString() == id);
    if (index == -1) return;
    //--
    // setState(() {
    //   int __likes = int.parse(imagesList[index]["likes"]);
    //   if (imagesList[index]["liked"] == "1") {
    //     imagesList[index]["liked"] = "0";
    //     imagesList[index]["likes"] = (__likes - 1).toString();
    //   } else {
    //     imagesList[index]["liked"] = "1";
    //     imagesList[index]["likes"] = (__likes + 1).toString();
    //   }
    // });
    //--
    helper
        .postGeneric("like", {"USER_ID": USER_ID, "POST_ID": id}).then((value) {
      Map response = jsonDecode(value.body);
      helper.pushNotification(response["count"].toString(), id);
      setState(() {
        imagesList[index]["likes"] = response["count"].toString();
        imagesList[index]["liked"] = response["liked"].toString();
        isGettingData = false;
      });
    });
  }

  void favorite(id) async {
    String USER_ID = await helper.getUserId();
    if (USER_ID == "-1") {
      dialogs.showLoginAlert(context);
      return;
    }
    int index =
        imagesList.indexWhere((element) => element["id"].toString() == id);
    if (index == -1) return;
    helper.postGeneric("favorites/$USER_ID", {"POST_ID": id});
    setState(() {
      imagesList[index]["isFav"] = !imagesList[index]["isFav"];
    });
  }

  @override
  void initState() {
    if (mounted && !isGettingData) {
      getData(true);
    }
    listenToLikes();
    super.initState();
  }

  void getData(isNew) async {
    setState(() {
      isGettingData = true;
    });
    String userId = await helper.getUserId();
    if (isNew) imagesList = [];
    String? _cat = await _mngr.getString("Category");
    if (_cat == null) {
      await _mngr.setString("Category", "1");
      _cat = "1";
    }

    //-----favorites
    var favRes = await helper.getGeneric("favorites/$userId", {});
    var favsS = jsonDecode(favRes.body);
    List fav = favsS["items"].map((e) => e["post_id"].toString()).toList();
    //--------------

    // if (_cat == "1") {
    int start = imagesList.length;
    helper.getGeneric("posts/$_cat/$start/10",
        {"--accept-language": "AR", "USER_ID": userId}).then((value) {
      if (mounted) {
        setState(() {
          isGettingData = false;
        });
      }
      Map<String, dynamic> response = jsonDecode(value.body);
      List images = response["items"]
          .map((e) => ({
                "id": e["id"].toString(),
                "image":
                    "https://apex.oracle.com/pls/apex/husseinapps/wallpaper/thumb/${e["image_id"].toString()}",
                "image_full":
                    "https://apex.oracle.com/pls/apex/husseinapps/wallpaper/files/${e["image_id"].toString()}",
                "uploadedAt": e["created_at"],
                "likes": e["likes"] == null ? "0" : e["likes"].toString(),
                "liked": e["liked"].toString() == "1" ? "1" : "0",
                "isFav": fav.contains(e["id"].toString())
              }))
          .toList();
      if (mounted)
        setState(() {
          imagesList.addAll(images);
          if (images.length > 0)
            _refreshController.loadComplete();
          else
            _refreshController.loadNoData();
        });
    });
  }

  void _onLoading() async {
    print("load more");
    getData(false);
  }

  Future<bool> _onWillPop() async {
    if (reviewImage != null) {
      setState(() {
        reviewImage = null;
      });
      return false;
    }
    if (selectedImageIndex > -1) {
      setState(() {
        selectedImageIndex = -1;
      });
      return false;
    }
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[600],
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  showDialog(
                          context: context,
                          builder: (ctx) => const CatsDialog())
                      .then((value) => setState(() {
                            print(value);
                            if (value == true) getData(true);
                          }));
                },
                icon: Icon(Icons.category)),
            IconButton(
                onPressed: () {
                  setState(() {
                    isGrid = !isGrid;
                  });
                },
                icon: Icon(isGrid ? Icons.apps : Icons.app_registration)),
            IconButton(
                onPressed: () async {
                  String USER_ID = await helper.getUserId();
                  if (USER_ID == "-1") {
                    dialogs.showLoginAlert(context);
                    return;
                  }
                  Navigator.pushNamed(context, "/upload").then((value) {
                    if (value == true) {
                      getData(true);
                    }
                  });
                },
                icon: Icon(Icons.cloud_upload_rounded)),
            IconButton(
                onPressed: () async {
                  String USER_ID = await helper.getUserId();
                  if (USER_ID == "-1") {
                    dialogs.showLoginAlert(context);
                    return;
                  }
                  Navigator.pushNamed(context, "/profile");
                },
                icon: Icon(Icons.person))
          ],
        ),
        body: reviewImage != null
            ? _displayFullImage()
            : selectedImageIndex > -1
                ? viewer()
                : homeBody(),
      ),
    );
  }

  final _transformationController = TransformationController();
  TapDownDetails? _doubleTapDetails;

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails!.localPosition;
      // For a 3x zoom
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(3.0);
      // Fox a 2x zoom
      // ..translate(-position.dx, -position.dy)
      // ..scale(2.0);
    }
  }

  _displayFullImage() {
    return GestureDetector(
      onDoubleTapDown: (details) => _doubleTapDetails = details,
      onDoubleTap: _handleDoubleTap,
      child: Container(
        color: Colors.black,
        child: InteractiveViewer(
          transformationController: _transformationController,
          panEnabled: false,
          // Set it to false to prevent panning.
          // boundaryMargin: const EdgeInsets.all(80),
          scaleEnabled: true,
          minScale: 1,
          maxScale: 50,
          child: SizedBox(
            width: SizeConfig.widthMultiplier * 100,
            height: SizeConfig.heightMultiplier * 100,
            child: FadeInImage.assetNetwork(
              placeholder: helper.imagePlaceHolder,
              image: reviewImage!,
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      ),
    );
  }

  _refresherFooter() {
    return CustomFooter(
      builder: (BuildContext context, LoadStatus? mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = Text("pull up load");
        } else if (mode == LoadStatus.loading) {
          body = CupertinoActivityIndicator();
        } else if (mode == LoadStatus.failed) {
          body = Text("Load Failed!Click retry!");
        } else if (mode == LoadStatus.canLoading) {
          body = Text("release to load more");
        } else {
          body = Text("No more Data");
        }
        return Container(
          height: 55.0,
          child: Center(child: body),
        );
      },
    );
  }

  homeBody() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SmartRefresher(
        enablePullDown: false,
        enablePullUp: true,
        header: const WaterDropHeader(),
        footer: _refresherFooter(),
        controller: _refreshController,
        onRefresh: null,
        onLoading: _onLoading,
        child: GridView.builder(
            key: const PageStorageKey("HOME_IMAGES"),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isGrid ? 2 : 1,
            ),
            itemCount: imagesList.length,
            itemBuilder: (BuildContext context, int index) {
              return CardGrid(
                id: imagesList[index]["id"].toString(),
                onPress: () {
                  setState(() {
                    selectedImageIndex = index;
                  });
                },
                likes: imagesList[index]["likes"],
                liked: imagesList[index]["liked"].toString() == "1",
                isFav: imagesList[index]["isFav"] ?? false,
                logo: imagesList[index]["image"],
                onLikePress: () {
                  like(imagesList[index]["id"].toString());
                },
                onFavPress: () {
                  favorite(imagesList[index]["id"].toString());
                },
                placeholder: helper.imagePlaceHolder,
              );
            }),
      ),
    );
  }

  viewer() {
    return Container(
      color: Colors.black,
      child: CarouselSlider(
        options: CarouselOptions(
          // width: SizeConfig.widthMultiplier * 99,
          height: SizeConfig.heightMultiplier * 100,
          initialPage: selectedImageIndex,
          enableInfiniteScroll: false,
          enlargeCenterPage: true,
          // viewportFraction: 1,
        ),
        items: imagesList.map((i) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(i["image"].toString()),
                    fit: BoxFit.cover,
                    opacity: 0.1,
                  ),
                ),
                child: GestureDetector(
                  onTap: () => setState(() {
                    reviewImage = i["image_full"].toString();
                  }),
                  child: FadeInImage.assetNetwork(
                    placeholder: helper.imagePlaceHolder,
                    image: i["image_full"].toString(),
                    fit: BoxFit.fitWidth,
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
