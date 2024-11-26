import 'package:ads_mayhem_2/PAGES/ad_start.dart';
import 'package:ads_mayhem_2/PAGES/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_library_latest/COMPONENTS/asyncimage_view.dart';
import 'package:flutter_library_latest/COMPONENTS/border_view.dart';
import 'package:flutter_library_latest/COMPONENTS/button_view.dart';
import 'package:flutter_library_latest/COMPONENTS/detected_view.dart';
import 'package:flutter_library_latest/COMPONENTS/iconbutton_view.dart';
import 'package:flutter_library_latest/COMPONENTS/image_view.dart';
import 'package:flutter_library_latest/COMPONENTS/main_view.dart';
import 'package:flutter_library_latest/COMPONENTS/padding_view.dart';
import 'package:flutter_library_latest/COMPONENTS/pill_view.dart';
import 'package:flutter_library_latest/COMPONENTS/text_view.dart';
import 'package:flutter_library_latest/FUNCTIONS/colors.dart';
import 'package:flutter_library_latest/FUNCTIONS/firebase.dart';
import 'package:flutter_library_latest/FUNCTIONS/misc.dart';
import 'package:flutter_library_latest/FUNCTIONS/nav.dart';
import 'package:flutter_library_latest/MODELS/constants.dart';
import 'package:flutter_library_latest/MODELS/datamaster.dart';
import 'package:flutter_library_latest/MODELS/geohash.dart';
import 'package:flutter_library_latest/MODELS/screen.dart';

class ExploreStart extends StatefulWidget {
  final DataMaster dm;
  const ExploreStart({super.key, required this.dm});

  @override
  State<ExploreStart> createState() => _ExploreStartState();
}

class _ExploreStartState extends State<ExploreStart> {
  List<dynamic> _ads = [];
  dynamic lastDoc;
  bool _noMore = false;
  List<String> _adIds = [];
  //
  //
  Future<void> _fetchAllAds() async {
    final docs = await firebase_GetAllDocumentsQueriedLimitedDistanced(
        '${widget.dm.appName}_Campaigns',
        [
          {'field': 'active', 'operator': '==', 'value': true}
        ],
        80,
        geohash:
            Geohash.encode(testCoordinates.latitude, testCoordinates.longitude),
        distance: 30,
        lastDoc: lastDoc);

    if (lastDoc != null) {
      setState(() {
        _ads.addAll(docs);
      });
    } else {
      setState(() {
        _ads = docs;
      });
    }
    if (docs.isNotEmpty) {
      setState(() {
        lastDoc = docs.last?['doc'];
      });
    } else {
      setState(() {
        _noMore = true;
      });
    }
  }

  void onAdSeen(ad) async {
    final adId = ad['id'];
    if (!_adIds.contains(adId)) {
      // PROCEED
      final success = await firebase_CreateDocument(
          '${widget.dm.appName}_Views',
          randomString(25),
          {'adId': adId, 'userId': widget.dm.user['id']});
      if (success) {
        print('Ad was seen: $adId');
      }
    }
  }

  void init() async {
    setState(() {
      widget.dm.setToggleLoading(true);
    });
    await _fetchAllAds();
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
        // background: const ImageView(
        //   imagePath: 'assets/splash.png',
        //   objectFit: BoxFit.fill,
        // ),
        mobile: [
          //
          PaddingView(
            paddingBottom: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextView(
                      text: 'explore',
                      size: 16,
                    )
                  ],
                ),
                IconButtonView(
                    backgroundColor: hexToColor("#2865F5"),
                    iconColor: Colors.white,
                    icon: Icons.person_2_outlined,
                    iconSize: 26,
                    width: 22,
                    onPress: () {
                      //
                      nav_Push(context, Login(dm: widget.dm), () {
                        lastDoc = null;
                        _fetchAllAds();
                      });
                    })
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: PaddingView(
                paddingTop: 5,
                paddingBottom: 5,
                paddingLeft: 6,
                paddingRight: 6,
                child: Column(
                  children: [
                    for (var ad in _ads)
                      DetectedView(
                        onViewed: () {
                          onAdSeen(ad);
                        },
                        child: Column(
                          children: [
                            BorderView(
                              allColor: hexToColor("#E4E6F6"),
                              radius: 12,
                              child: ButtonView(
                                onPress: () {
                                  nav_Push(
                                      context, AdStart(dm: widget.dm, ad: ad),
                                      () {
                                    _fetchAllAds();
                                  });
                                },
                                child: AsyncImageView(
                                  imagePath: ad['imagePath'],
                                  width: getWidth(context),
                                  height: getWidth(context) * 0.95,
                                  radius: 12,
                                  objectFit: BoxFit.fill,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                      ),
                    if (!_noMore)
                      ButtonView(
                        child: const PillView(
                          backgroundColor: Colors.black,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.waving_hand_outlined,
                                size: 22,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              TextView(
                                text: 'see more',
                                size: 16,
                                font: 'poppins',
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
                        onPress: () async {
                          // GET MORE
                          setState(() {
                            widget.dm.setToggleLoading(true);
                          });
                          await _fetchAllAds();
                          setState(() {
                            widget.dm.setToggleLoading(false);
                          });
                        },
                      )
                    else
                      const PaddingView(
                        child: TextView(
                          text: 'no more ads.',
                          font: 'poppins',
                          size: 20,
                          weight: FontWeight.w500,
                          spacing: -1,
                        ),
                      ),
                    const SizedBox(
                      height: 25,
                    )
                  ],
                ),
              ),
            ),
          ),
        ]);
  }
}
