import 'package:flutter/material.dart';
import 'package:sharewallpaper/util/SizeConfig.dart';
import 'package:sharewallpaper/util/data-repository.dart';
import 'package:sharewallpaper/util/helper.dart';

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
  final String name = "Ahmed Hussein";
  final String fbUsername = "prog.hussein";
  final String instaUsername = "husseininsta";
  final String likesNumber = "3.2K";
  final String followNumber = "500";
  final DataRepository repository = DataRepository();

  List<String>? favs;
  List<Map<String, dynamic>>? myAlbums;

  void getAlbums() {
    albumController = helper.initPlaceholder(
        this, 60 * SizeConfig.widthMultiplier, 37 * SizeConfig.heightMultiplier,
        (placeholder) {
      setState(() {
        _placeHolder = placeholder;
      });
    });

    repository.getDeviceId().then((did) {
      repository.fs
          .collection("images")
          .where("deviceId", isEqualTo: did)
          .get()
          .then((value) {
        var data = value.docs.map((e) => e.data()).toList();
        List cats = data.map((e) => e["cat_id"]).toSet().toList();
        repository.fs
            .collection("cats")
            .where("id", whereIn: cats)
            .get()
            .then((catsInfo) {
          List<Map<String, dynamic>> categories = catsInfo.docs
              .map((e) => ({
                    "name": e.data()["name_en"],
                    "id": e.data()["id"],
                    "images": data
                        .where((el) => el["cat_id"] == e.id)
                        .map((el) =>
                            "https://firebasestorage.googleapis.com/v0/b/shareimages-b9e75.appspot.com/o/files%2F${el["image"]}.thumbnail.png?alt=media")
                        .toList()
                  }))
              .toList();
          setState(() {
            myAlbums = categories;
            albumController!.dispose();
          });
        });
      });
    });
  }

  void getFavs() {
    favsController = helper.initPlaceholder(
        this, 70 * SizeConfig.widthMultiplier, 20 * SizeConfig.heightMultiplier,
        (placeholder) {
      setState(() {
        _favPlaceHolder = placeholder;
      });
    });

    Future.delayed(const Duration(milliseconds: 1000 * 5), () {
      setState(() {
        favs = ["assets/traveltwo.png"];
        favsController!.dispose();
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAlbums();
    getFavs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF8F8FA),
      body: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            color: Colors.blue[600],
            height: 40 * SizeConfig.heightMultiplier,
            child: Padding(
              padding: EdgeInsets.only(
                  left: 30.0,
                  right: 30.0,
                  top: 10 * SizeConfig.heightMultiplier),
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
                          Text(
                            name,
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
                                  Text(
                                    fbUsername,
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
                                  Text(
                                    instaUsername,
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
                          onPressed: null,
                          child: Text(
                            "EDIT PROFILE",
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
          ),
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
                  children: <Widget>[
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
                    SizedBox(
                      height: 3 * SizeConfig.heightMultiplier,
                    ),
                    Container(
                      height: 37 * SizeConfig.heightMultiplier,
                      child: myAlbums != null && myAlbums!.length > 0
                          ? ListView(
                              scrollDirection: Axis.horizontal,
                              children: <Widget>[
                                ...myAlbums!
                                    .map((e) => _myAlbumCard(e))
                                    .toList(),
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
                                            Navigator.pushNamed(
                                                context, "/upload");
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
                ),
              ),
            ),
          )
        ],
      ),
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
        print(id);
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
                      child: Image.network(
                        images[0],
                        height: 27 * SizeConfig.imageSizeMultiplier,
                        width: 27 * SizeConfig.imageSizeMultiplier,
                        fit: BoxFit.cover,
                      ),
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
