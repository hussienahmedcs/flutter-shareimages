import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sharewallpaper/util/SizeConfig.dart';
import 'package:sharewallpaper/util/data-repository.dart';
import 'package:sharewallpaper/util/helper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sharewallpaper/util/pref-mngr.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  final Helper helper = Helper();
  AnimationController? albumController, favsController;
  Widget _placeHolder = Container();
  Widget _favPlaceHolder = Container();
  final ImageProvider profileImage = const AssetImage("assets/profileimg.png");
  String? fbUsername = "facebook";
  String? firstName;
  String? lastName;
  String? instaUsername = "instagram";
  String likesNumber = "0";
  String followNumber = "0";
  final DataRepository repository = DataRepository();
  final PrefMngr _mngr = PrefMngr();

  List<String>? favs;
  List<Map<String, dynamic>>? myAlbums;
  List? cats;
  List<Map<String, dynamic>>? posts;
  bool isEditMode = false;

  getProfileData() async {
    String userId = await helper.getUserId();
    helper
        .getGeneric("user/$userId", {"--accept-language": "EN"}).then((value) {
      Map<String, dynamic> map = jsonDecode(value.body);
      print(map);
      if (mounted)
        setState(() {
          likesNumber = map["likes"].toString();
          fbUsername = map["fb_username"].toString();
          instaUsername = map["insta_username"].toString();
          followNumber = helper.numberFormat(map["follow"].toString());
          firstName = map["first_name"].toString();
          lastName = map["last_name"].toString();
        });
      helper.hideLoader();
    });
  }

  Future<List> getFavIds() async {
    String? _fav = await _mngr.getString("FAVORITES");
    return jsonDecode(_fav ?? "[]");
  }

  getPosts() async {
    String userId = await helper.getUserId();
    http.Response value = await helper
        .getGeneric("user-posts/" + userId, {"--accept-language": "EN"});
    Map json = jsonDecode(value.body);
    List ls = json["items"];
    List _ls = ls.toList();
    List<Map<String, dynamic>> _posts = [];
    for (var e in _ls) {
      int index = _posts
          .indexWhere((p) => p["id"].toString() == e["cat_id"].toString());
      if (index > -1) {
        _posts[index]["images"].add(
            "https://apex.oracle.com/pls/apex/husseinapps/wallpaper/thumb/" +
                e["image_id"].toString());
      } else {
        _posts.add({
          "id": e["cat_id"].toString(),
          "name": e["cat_name"].toString(),
          "images": [
            "https://apex.oracle.com/pls/apex/husseinapps/wallpaper/thumb/" +
                e["image_id"].toString()
          ]
        });
      }
    }
    return _posts;
  }

  void getAlbums() async {
    setState(() {
      myAlbums = null;
    });
    albumController = helper.initPlaceholder(
        this, 60 * SizeConfig.widthMultiplier, 37 * SizeConfig.heightMultiplier,
        (placeholder) {
      setState(() {
        _placeHolder = placeholder;
      });
    });

    posts = await getPosts();

    if (!mounted) return;
    setState(() {
      myAlbums = posts;
      albumController!.dispose();
    });
  }

  void getFavs() async {
    // String ids = (await getFavIds()).join(",");
    // String idsStr = "(" + ids + ")";
    //
    // helper.postGeneric("favorites", {"IDS": idsStr},
    //     headers: {'--accept-language': 'AR'}).then((value) {
    //   print(value.body);
    // });
    setState(() {
      favs = null;
    });
    favsController = helper.initPlaceholder(
        this, 70 * SizeConfig.widthMultiplier, 20 * SizeConfig.heightMultiplier,
        (placeholder) {
      if (!mounted) return;
      setState(() {
        _favPlaceHolder = placeholder;
      });
    });
    //
    // Future.delayed(const Duration(milliseconds: 1000 * 5), () {
    //   if (!mounted) return;
    //   setState(() {
    favs = ["assets/traveltwo.png"];
    //   });
    favsController!.dispose();
    // });
  }

  void getData() {
    getAlbums();
    getFavs();
    getProfileData();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  void dispose() {
    if (favsController!.isAnimating) favsController!.dispose();
    if (albumController!.isAnimating) albumController!.dispose();
    super.dispose();
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    print("_onRefresh");
    getData();
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    print("_onLoading");
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted) setState(() {});
    _refreshController.loadComplete();
    // _refreshController.loadNoData();
    // _refreshController.resetNoData();
  }

  editSaveProfile() async {
    String userId = await helper.getUserId();

    if (isEditMode) {
      helper.showLoader();
      Map<String, String> payload = {};
      if (firstName != null) payload["fname"] = firstName!;
      if (lastName != null) payload["lname"] = lastName!;
      if (fbUsername != null) payload["FB_USERNAME"] = fbUsername!;
      if (instaUsername != null) payload["INSTA_USERNAME"] = instaUsername!;
      helper.postGeneric("/user/$userId", payload).then((value) {
        helper.hideLoader();
        setState(() {
          isEditMode = false;
        });
        getProfileData();
      });
    } else {
      setState(() {
        isEditMode = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8FA),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: const WaterDropHeader(),
        footer: CustomFooter(
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
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            _infoCard(),
            Padding(
              padding: EdgeInsets.only(top: 35 * SizeConfig.heightMultiplier),
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
                    children: <Widget>[_myAlbumCards(), _myFavCards()],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      color: Colors.blue[600],
      height: 40 * SizeConfig.heightMultiplier,
      child: Padding(
        padding: EdgeInsets.only(
            left: 30.0, right: 30.0, top: 10 * SizeConfig.heightMultiplier),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  height: 11 * SizeConfig.heightMultiplier,
                  width: 22 * SizeConfig.widthMultiplier,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          fit: BoxFit.cover, image: profileImage)),
                ),
                SizedBox(
                  width: 5 * SizeConfig.widthMultiplier,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    isEditMode
                        ? Row(
                            children: [
                              Container(
                                padding: EdgeInsets.zero,
                                width: 70,
                                child: TextFormField(
                                  initialValue: firstName,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) => firstName = value,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "F Name",
                                    hintStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.zero,
                                width: 70,
                                child: TextFormField(
                                  initialValue: lastName,
                                  // keyboardType: TextInputType.number,
                                  onChanged: (value) => lastName = value,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "L Name",
                                    hintStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          )
                        : Text(
                            (firstName ?? "") + " " + (lastName ?? ""),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 3 * SizeConfig.textMultiplier,
                                fontWeight: FontWeight.bold),
                          ),
                    SizedBox(
                      height: 1 * SizeConfig.heightMultiplier,
                    ),
                    Row(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Image.asset(
                              "assets/fb.png",
                              height: 3 * SizeConfig.heightMultiplier,
                              width: 3 * SizeConfig.widthMultiplier,
                            ),
                            SizedBox(
                              width: 2 * SizeConfig.widthMultiplier,
                            ),
                            isEditMode
                                ? Container(
                                    width: 50,
                                    child: TextFormField(
                                      initialValue: fbUsername,
                                      // keyboardType: TextInputType.number,
                                      onChanged: (value) => fbUsername = value,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "facebook",
                                        hintStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                        ),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    fbUsername ?? "Facebook",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 1.5 * SizeConfig.textMultiplier,
                                    ),
                                  ),
                          ],
                        ),
                        SizedBox(
                          width: 7 * SizeConfig.widthMultiplier,
                        ),
                        Row(
                          children: <Widget>[
                            Image.asset(
                              "assets/insta.png",
                              height: 3 * SizeConfig.heightMultiplier,
                              width: 3 * SizeConfig.widthMultiplier,
                            ),
                            SizedBox(
                              width: 2 * SizeConfig.widthMultiplier,
                            ),
                            isEditMode
                                ? Container(
                                    width: 50,
                                    child: TextFormField(
                                      initialValue: instaUsername,
                                      // keyboardType: TextInputType.number,
                                      onChanged: (value) =>
                                          instaUsername = value,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "instagram",
                                        hintStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                        ),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    instaUsername ?? "Instagram",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 1.5 * SizeConfig.textMultiplier,
                                    ),
                                  ),
                          ],
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
            SizedBox(
              height: 3 * SizeConfig.heightMultiplier,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text(
                      likesNumber,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 3 * SizeConfig.textMultiplier,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Likes",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 1.9 * SizeConfig.textMultiplier,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text(
                      followNumber,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 3 * SizeConfig.textMultiplier,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Following",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 1.9 * SizeConfig.textMultiplier,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white60),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: FlatButton(
                    padding: const EdgeInsets.all(8.0),
                    onPressed: editSaveProfile,
                    child: Text(
                      isEditMode ? "Save Info" : "Edit Profile",
                      style: TextStyle(
                          color: Colors.white60,
                          fontSize: 1.8 * SizeConfig.textMultiplier),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _myAlbumCards() {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: 30.0, top: 3 * SizeConfig.heightMultiplier),
            child: Text(
              "My Albums",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 2.2 * SizeConfig.textMultiplier),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: 30.0, top: 3 * SizeConfig.heightMultiplier),
            child: IconButton(
                onPressed: () =>
                    Navigator.pushNamed(context, "/upload").then((value) {
                      if (value == true) getAlbums();
                    }),
                icon: Icon(Icons.camera_alt)),
          )
        ],
      ),
      SizedBox(
        height: 3 * SizeConfig.heightMultiplier,
      ),
      Container(
        height: 37 * SizeConfig.heightMultiplier,
        child: myAlbums != null && myAlbums!.length > 0
            ? ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  ...myAlbums!.map((e) => _myAlbumCard(e)).toList(),
                  SizedBox(
                    width: 10 * SizeConfig.widthMultiplier,
                  ),
                ],
              )
            : myAlbums != null && myAlbums!.length == 0
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('No Albums'),
                        IconButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "/upload");
                            },
                            icon: Icon(Icons.add_a_photo))
                      ],
                    ),
                  )
                : _placeHolder,
      ),
      SizedBox(
        height: 3 * SizeConfig.heightMultiplier,
      ),
    ]);
  }

  Widget _myFavCards() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 30.0, right: 30.0),
          child: Row(
            children: <Widget>[
              Text(
                "Favourites",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 2.2 * SizeConfig.textMultiplier),
              ),
              Spacer(),
              Text(
                favs == null
                    ? "Loading"
                    : favs!.length == 0
                        ? "No Favorites Right Now"
                        : "View All",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 1.7 * SizeConfig.textMultiplier),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 3 * SizeConfig.heightMultiplier,
        ),
        favs == null
            ? _favPlaceHolder
            : favs != null && favs!.length > 0
                ? Container(
                    height: 20 * SizeConfig.heightMultiplier,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        ...favs!.map((e) => _favoriteCard(e)),
                        SizedBox(
                          width: 10 * SizeConfig.widthMultiplier,
                        )
                      ],
                    ),
                  )
                : Container(),
        SizedBox(
          height: 3 * SizeConfig.heightMultiplier,
        )
      ],
    );
  }

  _myAlbumCard(e) {
    var id = e['id'].toString();
    var name = e['name'];
    List<String> images = (e['images'] as List<String>);
    var _more = images.length - 4;
    var more = _more > 0 ? "+" + (_more).toString() : null;

    return FlatButton(
      onPressed: () {
        _mngr.setString("Category", id).then((_) {
          Navigator.pushNamed(context, "/", arguments: true);
        });
      },
      padding: const EdgeInsets.all(0),
      child: Padding(
        padding: const EdgeInsets.only(left: 40.0),
        child: Container(
          height: 37 * SizeConfig.heightMultiplier,
          width: 60 * SizeConfig.widthMultiplier,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: Colors.grey, width: 0.2)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: FadeInImage.assetNetwork(
                          placeholder: helper.imagePlaceHolder,
                          image: images[0],
                          height: 27 * SizeConfig.imageSizeMultiplier,
                          width: 27 * SizeConfig.imageSizeMultiplier,
                          fit: BoxFit.cover,
                        )
                        // Image.network(
                        //   images[0],
                        //   height: 27 * SizeConfig.imageSizeMultiplier,
                        //   width: 27 * SizeConfig.imageSizeMultiplier,
                        //   fit: BoxFit.cover,
                        // ),
                        ),
                    Spacer(),
                    images.length > 1
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              images[1],
                              height: 27 * SizeConfig.imageSizeMultiplier,
                              width: 27 * SizeConfig.imageSizeMultiplier,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(),
                  ],
                ),
                SizedBox(
                  height: 1 * SizeConfig.heightMultiplier,
                ),
                images.length > 2
                    ? Row(
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              images[2],
                              height: 27 * SizeConfig.imageSizeMultiplier,
                              width: 27 * SizeConfig.imageSizeMultiplier,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Spacer(),
                          images.length > 3
                              ? Stack(
                                  overflow: Overflow.visible,
                                  children: <Widget>[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.network(
                                        images[3],
                                        height:
                                            27 * SizeConfig.imageSizeMultiplier,
                                        width:
                                            27 * SizeConfig.imageSizeMultiplier,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    more != null
                                        ? Positioned(
                                            child: Container(
                                              height: 27 *
                                                  SizeConfig
                                                      .imageSizeMultiplier,
                                              width: 27 *
                                                  SizeConfig
                                                      .imageSizeMultiplier,
                                              decoration: BoxDecoration(
                                                  color: Colors.black38,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              child: Center(
                                                child: Text(
                                                  more,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 2.5 *
                                                        SizeConfig
                                                            .textMultiplier,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container()
                                  ],
                                )
                              : Container(),
                        ],
                      )
                    : Container(
                        height: 27 * SizeConfig.imageSizeMultiplier,
                      ),
                Padding(
                  padding: EdgeInsets.only(
                      left: 10.0, top: 2 * SizeConfig.heightMultiplier),
                  child: Text(
                    name,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 2 * SizeConfig.textMultiplier,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _favoriteCard(String s) {
    return Padding(
      padding: const EdgeInsets.only(left: 40.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Image.asset(
          s,
          height: 20 * SizeConfig.heightMultiplier,
          width: 70 * SizeConfig.widthMultiplier,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
