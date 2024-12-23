import 'package:ads_mayhem_2/PAGES/ad_main.dart';
import 'package:ads_mayhem_2/PAGES/ad_start.dart';
import 'package:ads_mayhem_2/PAGES/filters.dart';
import 'package:ads_mayhem_2/PAGES/login.dart';
import 'package:ads_mayhem_2/PAGES/profile.dart';
import 'package:ads_mayhem_2/PAGES/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_library_latest/COMPONENTS/asyncimage_view.dart';
import 'package:flutter_library_latest/COMPONENTS/border_view.dart';
import 'package:flutter_library_latest/COMPONENTS/button_view.dart';
import 'package:flutter_library_latest/COMPONENTS/detected_view.dart';
import 'package:flutter_library_latest/COMPONENTS/iconbutton_view.dart';
import 'package:flutter_library_latest/COMPONENTS/main_view.dart';
import 'package:flutter_library_latest/COMPONENTS/padding_view.dart';
import 'package:flutter_library_latest/COMPONENTS/pill_view.dart';
import 'package:flutter_library_latest/COMPONENTS/roundedcorners_view.dart';
import 'package:flutter_library_latest/COMPONENTS/text_view.dart';
import 'package:flutter_library_latest/FUNCTIONS/colors.dart';
import 'package:flutter_library_latest/FUNCTIONS/firebase.dart';
import 'package:flutter_library_latest/FUNCTIONS/misc.dart';
import 'package:flutter_library_latest/FUNCTIONS/nav.dart';
import 'package:flutter_library_latest/MODELS/constants.dart';
import 'package:flutter_library_latest/MODELS/datamaster.dart';
import 'package:flutter_library_latest/MODELS/geohash.dart';
import 'package:flutter_library_latest/MODELS/screen.dart';

class ExploreMain extends StatefulWidget {
  final DataMaster dm;
  const ExploreMain({super.key, required this.dm});

  @override
  State<ExploreMain> createState() => _ExploreMainState();
}

class _ExploreMainState extends State<ExploreMain> {
  List<dynamic> _ads = [];
  dynamic lastDoc;
  bool _noMore = false;
  List<String> _adIds = [];
  //
  //
  Future<void> _fetchAllAds() async {
    List<Map<String, dynamic>> queries = [];
    if (widget.dm.user['category'] == "" ||
        widget.dm.user['category'] == null) {
      queries = [
        {'field': 'active', 'operator': '==', 'value': true}
      ];
    } else {
      queries = [
        {'field': 'active', 'operator': '==', 'value': true},
        {
          'field': 'category',
          'operator': '==',
          'value': widget.dm.user['category']
        }
      ];
    }
    final docs = await firebase_GetAllDocumentsQueriedLimitedDistanced(
        'Campaigns', queries, 80,
        geohash: widget.dm.user['geohash'],
        distance: widget.dm.user['distance'] ?? 30,
        lastDoc: lastDoc);

    if (lastDoc != null) {
      setState(() {
        _ads.addAll(docs);
      });
    } else if (lastDoc == null) {
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

  void init() async {
    setState(() {
      widget.dm.setToggleLoading(true);
    });
    await _fetchAllAds();
    setState(() {
      widget.dm.setToggleLoading(false);
    });
  }

  void onAdSeen(ad) async {
    final adId = ad['id'];
    if (!_adIds.contains(adId)) {
      // PROCEED
      final success = await firebase_CreateDocument('Views', randomString(25),
          {'adId': adId, 'userId': widget.dm.user['id']});
      if (success) {
        print('Ad was seen: $adId');
      }
    }
  }

  void onClickAd(ad) async {
    await firebase_CreateDocument('Clicks', randomString(25), {
      'adId': ad['id'],
      'geohash': widget.dm.user['geohash'],
      'userId': widget.dm.user['id']
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
                      font: 'poppins',
                    )
                  ],
                ),
                PaddingView(
                  paddingTop: 0,
                  paddingBottom: 10,
                  paddingLeft: 0,
                  paddingRight: 0,
                  child: Row(
                    children: [
                      IconButtonView(
                        backgroundColor: Colors.black,
                        iconColor: Colors.white,
                        icon: Icons.search_outlined,
                        iconSize: 26,
                        width: 22,
                        onPress: () {
                          //
                          nav_Push(context, Search(dm: widget.dm));
                        },
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      IconButtonView(
                        backgroundColor: Colors.black,
                        iconColor: Colors.white,
                        icon: Icons.tune_outlined,
                        iconSize: 26,
                        width: 22,
                        onPress: () {
                          //
                          nav_Push(context, Filters(dm: widget.dm), () async {
                            lastDoc = null;
                            setState(() {
                              init();
                            });
                          });
                        },
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      IconButtonView(
                        backgroundColor: hexToColor("#2865F5"),
                        iconColor: Colors.white,
                        icon: Icons.person_2_outlined,
                        iconSize: 26,
                        width: 22,
                        onPress: () {
                          //
                          nav_Push(context, Profile(dm: widget.dm), () {
                            init();
                          });
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
//
          if (_ads.isEmpty)
            PaddingView(
              child: RoundedCornersView(
                backgroundColor: Colors.black,
                child: PaddingView(
                  paddingAll: 18,
                  child: Column(
                    children: [
                      const TextView(
                        text:
                            'Not seeing any ads? Try to expand your location or change the category.',
                        size: 16,
                        color: Colors.white,
                        font: 'poppins',
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ButtonView(
                            child: PillView(
                              backgroundColor: Colors.white,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.tune,
                                    color: hexToColor("#2865F5"),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const TextView(
                                    text: 'change filters',
                                    size: 16,
                                    font: 'poppins',
                                  ),
                                ],
                              ),
                            ),
                            onPress: () {
                              // GO TO FILTERS
                              nav_Push(context, Filters(dm: widget.dm), () {
                                init();
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          //
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
                                  onClickAd(ad);
                                  nav_Push(
                                      context, AdMain(dm: widget.dm, ad: ad),
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
                    if (!_noMore && _ads.isNotEmpty)
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
