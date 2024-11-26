import 'package:ads_mayhem_2/PAGES/explore_main.dart';
import 'package:ads_mayhem_2/PAGES/explore_start.dart';
import 'package:ads_mayhem_2/PAGES/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_library_latest/COMPONENTS/asyncimage_view.dart';
import 'package:flutter_library_latest/COMPONENTS/border_view.dart';
import 'package:flutter_library_latest/COMPONENTS/button_view.dart';
import 'package:flutter_library_latest/COMPONENTS/iconbutton_view.dart';
import 'package:flutter_library_latest/COMPONENTS/main_view.dart';
import 'package:flutter_library_latest/COMPONENTS/map_view.dart';
import 'package:flutter_library_latest/COMPONENTS/padding_view.dart';
import 'package:flutter_library_latest/COMPONENTS/pill_view.dart';
import 'package:flutter_library_latest/COMPONENTS/qrcode_view.dart';
import 'package:flutter_library_latest/COMPONENTS/roundedcorners_view.dart';
import 'package:flutter_library_latest/COMPONENTS/text_view.dart';
import 'package:flutter_library_latest/FUNCTIONS/array.dart';
import 'package:flutter_library_latest/FUNCTIONS/colors.dart';
import 'package:flutter_library_latest/FUNCTIONS/firebase.dart';
import 'package:flutter_library_latest/FUNCTIONS/location.dart';
import 'package:flutter_library_latest/FUNCTIONS/misc.dart';
import 'package:flutter_library_latest/FUNCTIONS/nav.dart';
import 'package:flutter_library_latest/MODELS/datamaster.dart';
import 'package:flutter_library_latest/MODELS/geohash.dart';
import 'package:flutter_library_latest/MODELS/screen.dart';

class AdMain extends StatefulWidget {
  final DataMaster dm;
  final Map<String, dynamic> ad;
  const AdMain({super.key, required this.dm, required this.ad});

  @override
  State<AdMain> createState() => _AdMainState();
}

class _AdMainState extends State<AdMain> {
  Map<String, dynamic>? _business = null;
  List<dynamic> _ads = [];
  bool _isSaved = false;
  String _savedId = "";
  bool _isFollowing = false;
  String _followedId = "";
  //
  bool _showQR = false;

  Future<void> _fetchBusinessInfo() async {
    final doc = await firebase_GetDocument(
        '${widget.dm.appName}_Businesses', widget.ad['userId']);
    setState(() {
      _business = doc;
    });
  }

  Future<void> _fetchBusinessAds() async {
    final docs = await firebase_GetAllDocumentsQueried(
        '${widget.dm.appName}_Campaigns', [
      {'field': 'active', 'operator': '==', 'value': true},
      {'field': 'userId', 'operator': '==', 'value': widget.ad['userId']}
    ]);
    setState(() {
      _ads = removeObjById(docs, widget.ad['id']);
    });
  }

  Future<void> _onSaveUnsave() async {
    if (_isSaved) {
      await firebase_DeleteDocument('${widget.dm.appName}_Favorites', _savedId);
      setState(() {
        _savedId = "";
        _isSaved = false;
      });
    } else {
      final savedId = randomString(25);
      await firebase_CreateDocument('${widget.dm.appName}_Favorites', savedId,
          {'adId': widget.ad['id'], 'userId': widget.dm.user['id']});

      setState(() {
        _savedId = savedId;
        _isSaved = true;
      });
    }
  }

  Future<void> _checkIfSaved() async {
    final docs = await firebase_GetAllDocumentsQueried(
        '${widget.dm.appName}_Favorites', [
      {'field': 'adId', "operator": '==', 'value': widget.ad['id']},
      {'field': 'userId', "operator": '==', 'value': widget.dm.user['id']},
    ]);
    if (docs.isNotEmpty) {
      final savedObj = docs[0];
      setState(() {
        _isSaved = true;
        _savedId = savedObj['id'];
      });
    }
  }

  Future<void> _onFollowUnfollow() async {
//
    if (_isFollowing) {
      await firebase_DeleteDocument(
          '${widget.dm.appName}_Following', _followedId);
      setState(() {
        _isFollowing = false;
        _followedId = "";
      });
    } else {
      final followedId = randomString(25);
      await firebase_CreateDocument(
          '${widget.dm.appName}_Following', followedId, {
        'businessId': _business!['id'],
        'businessName': _business!['name'],
        'userId': widget.dm.user['id']
      });
      setState(() {
        _isFollowing = true;
        _followedId = followedId;
      });
    }
  }

  Future<void> _checkIfFollowed() async {
//
    final docs = await firebase_GetAllDocumentsQueried(
        '${widget.dm.appName}_Following', [
      {'field': 'businessId', 'operator': '==', 'value': _business!['id']},
      {'field': 'userId', 'operator': '==', 'value': widget.dm.user['id']},
    ]);
    if (docs.isNotEmpty) {
      final followedObj = docs[0];
      setState(() {
        _followedId = followedObj['id'];
        _isFollowing = true;
      });
    }
  }

  void init() async {
    setState(() {
      widget.dm.setToggleLoading(true);
    });
    await _checkIfSaved();
    await _fetchBusinessInfo();
    await _fetchBusinessAds();
    await _checkIfFollowed();
    setState(() {
      widget.dm.setToggleLoading(false);
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MainView(
        dm: widget.dm,
        backgroundColor: hexToColor('#EDEEF6'),
        mobile: [
          //
          PaddingView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButtonView(
                  icon: Icons.arrow_back,
                  onPress: () {
                    nav_Pop(context);
                  },
                ),
                Row(
                  children: [
                    IconButtonView(
                      iconColor: Colors.white,
                      backgroundColor: Colors.black,
                      icon: Icons.home_outlined,
                      iconSize: 26,
                      width: 26,
                      onPress: () {
                        //
                        nav_PushAndRemove(context, ExploreMain(dm: widget.dm));
                      },
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    IconButtonView(
                      iconColor: Colors.white,
                      backgroundColor: _isSaved ? Colors.red : Colors.black,
                      icon: _isSaved ? Icons.favorite : Icons.favorite_outline,
                      iconSize: 26,
                      width: 26,
                      onPress: () {
                        //
                        _onSaveUnsave();
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: PaddingView(
                paddingTop: 0,
                paddingLeft: 8,
                paddingRight: 8,
                child: Column(
                  children: [
                    SizedBox(
                      width: getWidth(context),
                      height: getWidth(context) * 0.95,
                      child: Stack(children: [
                        if (!_showQR)
                          BorderView(
                            radius: 12,
                            allColor: hexToColor("#E3E5F6"),
                            child: RoundedCornersView(
                              all: 12,
                              backgroundColor: Colors.white,
                              child: AsyncImageView(
                                imagePath: widget.ad['imagePath'],
                                width: getWidth(context),
                                height: getWidth(context) * 0.95,
                                objectFit: BoxFit.fill,
                                radius: 12,
                              ),
                            ),
                          ),

                        if (_showQR)
                          RoundedCornersView(
                            backgroundColor: Colors.white,
                            child: Center(
                              child: QrcodeView(
                                  size: getWidth(context) * 0.5,
                                  data:
                                      '${widget.ad['id']}~${widget.dm.user['id']}'),
                            ),
                          ),
                        //
                        if (widget.ad['isCoupon'])
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: PaddingView(
                              child: IconButtonView(
                                backgroundColor: Colors.black54,
                                iconColor: Colors.white,
                                width: 30,
                                icon: Icons.qr_code,
                                onPress: () {
                                  //
                                  setState(() {
                                    if (_showQR) {
                                      setState(() {
                                        _showQR = false;
                                      });
                                    } else {
                                      setState(() {
                                        _showQR = true;
                                      });
                                    }
                                  });
                                },
                              ),
                            ),
                          )
                      ]),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextView(
                            text: widget.ad['details'].replaceAll('jjj', '\n'),
                            size: 17,
                            font: 'poppins',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    if (_business != null)
                      RoundedCornersView(
                        backgroundColor: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PaddingView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextView(
                                    text: _business!['name'],
                                    font: 'poppins',
                                    size: 34,
                                    spacing: -1,
                                    weight: FontWeight.w500,
                                  ),
                                  Row(
                                    children: [
                                      // PHONE
                                      IconButtonView(
                                        backgroundColor: hexToColor("#44F64A"),
                                        width: 30,
                                        icon: Icons.call,
                                        onPress: () async {
                                          await callPhoneNumber(
                                              _business!['phone']);
                                        },
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      IconButtonView(
                                        backgroundColor: hexToColor("#F64451"),
                                        iconColor: Colors.white,
                                        width: 30,
                                        icon: Icons.directions_car,
                                        onPress: () async {
                                          setState(() {
                                            widget.dm.setToggleLoading(true);
                                          });
                                          await getDirections({
                                            'latitude': Geohash.decode(widget
                                                .ad['geohash'])['latitude'],
                                            'longitude': Geohash.decode(widget
                                                .ad['geohash'])['longitude'],
                                          });
                                          setState(() {
                                            widget.dm.setToggleLoading(false);
                                          });
                                        },
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      if (widget.ad['link'] != "")
                                        IconButtonView(
                                          backgroundColor:
                                              hexToColor("#2865F5"),
                                          iconColor: Colors.white,
                                          width: 30,
                                          icon: Icons.language,
                                          onPress: () async {
                                            nav_GoToUrl(widget.ad['link']);
                                          },
                                        ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                        child: ButtonView(
                                            child: PillView(
                                              backgroundColor: !_isFollowing
                                                  ? Colors.black
                                                  : hexToColor("#EDEEF6"),
                                              paddingV: 14,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  TextView(
                                                    text: _isFollowing
                                                        ? 'following'
                                                        : 'follow',
                                                    size: 18,
                                                    font: 'poppins',
                                                    color: !_isFollowing
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            onPress: () {
                                              //
                                              _onFollowUnfollow();
                                            }),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            MapView(
                                isScrolling: false,
                                isZoomable: false,
                                height: 160,
                                locations: [
                                  {
                                    'latitude': Geohash.decode(
                                        widget.ad['geohash'])['latitude'],
                                    'longitude': Geohash.decode(
                                        widget.ad['geohash'])['longitude']
                                  }
                                ],
                                onMarkerTap: (loc) {
                                  print(loc);
                                })
                          ],
                        ),
                      ),
                    const SizedBox(
                      height: 30,
                    ),
                    //
                    if (_ads.isNotEmpty)
                      Column(
                        children: [
                          const PaddingView(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextView(
                                text: 'other ads',
                                font: 'poppins',
                                size: 18,
                                weight: FontWeight.w500,
                              ),
                            ],
                          )),
                          GridView.builder(
                            padding: const EdgeInsets.all(0),
                            shrinkWrap:
                                true, // Ensures the GridView doesn't take infinite height
                            physics:
                                const NeverScrollableScrollPhysics(), // Prevents scrolling within the GridView
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // Two items per row
                              crossAxisSpacing: 10, // Space between columns
                              mainAxisSpacing: 10, // Space between rows
                              childAspectRatio: 1, // Maintains 1:1 aspect ratio
                            ),
                            itemCount: _ads.length,
                            itemBuilder: (context, index) {
                              var ad = _ads[index];
                              return ButtonView(
                                onPress: () {
                                  //
                                  nav_Push(
                                      context, AdMain(dm: widget.dm, ad: ad));
                                },
                                child: BorderView(
                                  allColor: hexToColor("#E2E4F4"),
                                  radius: 12,
                                  child: AsyncImageView(
                                    imagePath: ad['imagePath'],
                                    width: getWidth(context),
                                    height: getWidth(
                                        context), // Since the aspect ratio is 1, height equals width
                                    radius: 12,
                                    objectFit: BoxFit.fill,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    const PaddingView(
                        child: TextView(
                      text: 'a nothing bagel. ver 2.0',
                      color: Colors.black45,
                      font: 'poppins',
                    )),
                    const SizedBox(
                      height: 25,
                    )
                  ],
                ),
              ),
            ),
          )
        ]);
  }
}
