import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sharewallpaper/common/card-grid.dart';
import 'package:sharewallpaper/common/cats-dialog.dart';
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
  int selectedImageIndex = -1;
  String? cat = "";
  int numOfCols = 2;
  String title = "Home";
  final PrefMngr _mngr = PrefMngr();
  List imagesList = [];
  final Helper helper = Helper();
  final DataRepository repository = DataRepository();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  String? deviceId;
  String? reviewImage;

  void like(index) async {
    var obj = imagesList[index];
    repository.fs.collection("images").doc(obj["id"]).get().then((value) {
      Map? data = value.data();
      if (data == null) return;
      List likes = data["likes"] ?? [];
      if (likes.contains(deviceId)) {
        likes = likes.where((element) => element != deviceId).toList();
      } else {
        likes.add(deviceId);
      }
      setState(() {
        imagesList[index]["likes"] = likes;

        repository.fs
            .collection("images")
            .doc(obj["id"])
            .update({"likes": likes, "likesCount": likes.length});
      });
    });
  }
  void getImages(Timestamp _time, bool isLoadMore) async {
    String? catId = await _mngr.getString("Category");
    if (catId == null) {
      catId = "RECENT";
      await _mngr.setString("Category", catId);
    }
    String? catName;
    if (catId == "RECENT") {
      catName = "Recent";
    } else if (catId == "TOP_RATE") {
      catName = "Top Rate";
    } else {
      var catData = await repository.fs
          .collection("cats")
          .where("id", isEqualTo: catId)
          .get();
      catName = catData.docs.first.data()["name_en"];
    }
    if (!mounted) return;
    final bool? _isMine = ModalRoute.of(context)!.settings.arguments as bool?;
    bool isMine = _isMine ?? false;

    setState(() {
      title = catName! + (isMine ? " - my photos" : "");
    });
    String did = await repository.getDeviceId();
    deviceId = did;

    var collection = repository.fs.collection("images").limit(10);

    if (catId == "RECENT") {
      if (imagesList.isEmpty) _time = Timestamp.fromDate(DateTime.now());
      collection = collection
          .orderBy("uploadedAt", descending: true)
          .where("uploadedAt", isLessThan: _time);
    } else if (catId == "TOP_RATE") {
      if (imagesList.isEmpty) _time = Timestamp.fromDate(DateTime.now());
      collection = collection
              // .startAt(values)
              .orderBy("likesCount", descending: false)
              .orderBy("uploadedAt", descending: false)
              // .where("likesCount", isGreaterThan: -1)
              // .where("uploadedAt", isLessThan: _time)



              // .endAt([0])
          .startAfter([-1,_time])

          // .endAt([0,_time])
          ;
      // print(_time.toDate());
    } else {
      collection = collection
          .where("cat_id", isEqualTo: catId)
          .where("uploadedAt", isGreaterThan: _time);
    }
    if (isMine) {
      collection = collection.where("deviceId", isEqualTo: did);
    }
    collection.get().then((value) {
      var list = value.docs
          .map((e) => e.data())
          .map((e) => ({
                "id": e["image"],
                "image":
                    "https://firebasestorage.googleapis.com/v0/b/shareimages-b9e75.appspot.com/o/files%2F${e["image"]}.thumbnail.png?alt=media",
                "image_full":
                    "https://firebasestorage.googleapis.com/v0/b/shareimages-b9e75.appspot.com/o/files%2F${e["image"]}.png?alt=media",
                "uploadedAt": e["uploadedAt"],
                "likes": e["likes"] ?? []
              }))
          .toList();
      setState(() {
        if (!isLoadMore) imagesList = [];
        print(list.map((x)=>x["uploadedAt"].toDate()));
        imagesList.addAll(list);
        print(imagesList.length);
        if (list.length > 0)
          _refreshController.loadComplete();
        else
          _refreshController.loadNoData();
        // // _refreshController.resetNoData();
      });
    });
  }

  @override
  void initState() {
    print("done");
    init(false);
  }

  void init(isLoadMore) {
    getImages(Timestamp.fromDate(DateTime(1971)), isLoadMore);
  }

  void _onLoading() async {
    getImages(imagesList.last["uploadedAt"], true);
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
          title: Text(title),
          actions: [
            PopupMenuButton(
              onSelected: (itemValue) {
                switch (itemValue) {
                  case 0:
                    //select category
                    showDialog(
                            context: context,
                            builder: (ctx) => const CatsDialog())
                        .then((value) => setState(() {
                              init(false);
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
              crossAxisCount: numOfCols,
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
                likes: imagesList[index]["likes"] ?? [],
                logo: imagesList[index]["image"],
                onLikePress: () {
                  like(index);
                },
                placeholder: helper.imagePlaceHolder,
                deviceId: deviceId!,
              );
            }),
      ),
    );
  }

// viewer() {
//   return PhotoViewGallery.builder(
//     itemCount: imagesList.length,
//     builder: (context, index) {
//       return PhotoViewGalleryPageOptions(
//         imageProvider: NetworkImage(imagesList[index]["image_full"]),
//         minScale: PhotoViewComputedScale.contained * 0.8,
//         maxScale: PhotoViewComputedScale.covered * 2,
//       );
//     },
//     scrollPhysics: BouncingScrollPhysics(),
//     backgroundDecoration: BoxDecoration(
//       color: Theme.of(context).canvasColor,
//     ),
//     loadingChild: Center(
//       child: CircularProgressIndicator(),
//     ),
//   );
// }

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

// viewer2() {
//   return ListView.builder(
//     physics: const BouncingScrollPhysics(),
//     shrinkWrap: true,
//     scrollDirection: Axis.horizontal,
//     itemCount: imagesList.length,
//     itemBuilder: (BuildContext context, int index) => Card(
//       child: Center(
//         child: InteractiveViewer(
//           panEnabled: false,
//           // Set it to false to prevent panning.
//           boundaryMargin: const EdgeInsets.all(80),
//           minScale: 1,
//           maxScale: 10,
//           child: SizedBox(
//             width: SizeConfig.widthMultiplier * 99,
//             height: SizeConfig.heightMultiplier * 99,
//             child: FadeInImage.assetNetwork(
//               placeholder: helper.imagePlaceHolder,
//               image: imagesList[index]["image_full"].toString(),
//               fit: BoxFit.fitWidth,
//             ),
//           ),
//         ),
//       ),
//     ),
//   );
// }
}
