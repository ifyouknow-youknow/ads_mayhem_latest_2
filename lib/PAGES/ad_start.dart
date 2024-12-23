import 'package:ads_mayhem_2/PAGES/explore_start.dart';
import 'package:ads_mayhem_2/PAGES/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_library_latest/COMPONENTS/asyncimage_view.dart';
import 'package:flutter_library_latest/COMPONENTS/border_view.dart';
import 'package:flutter_library_latest/COMPONENTS/button_view.dart';
import 'package:flutter_library_latest/COMPONENTS/iconbutton_view.dart';
import 'package:flutter_library_latest/COMPONENTS/image_view.dart';
import 'package:flutter_library_latest/COMPONENTS/main_view.dart';
import 'package:flutter_library_latest/COMPONENTS/map_view.dart';
import 'package:flutter_library_latest/COMPONENTS/padding_view.dart';
import 'package:flutter_library_latest/COMPONENTS/pill_view.dart';
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

class AdStart extends StatefulWidget {
  final DataMaster dm;
  final Map<String, dynamic> ad;
  const AdStart({super.key, required this.dm, required this.ad});

  @override
  State<AdStart> createState() => _AdStartState();
}

class _AdStartState extends State<AdStart> {
  Map<String, dynamic>? _business = null;
  List<dynamic> _ads = [];

  Future<void> _fetchBusinessInfo() async {
    final doc = await firebase_GetDocument('Businesses', widget.ad['userId']);
    setState(() {
      _business = doc;
    });
  }

  Future<void> _fetchBusinessAds() async {
    final docs = await firebase_GetAllDocumentsQueried('Campaigns', [
      {'field': 'active', 'operator': '==', 'value': true},
      {'field': 'userId', 'operator': '==', 'value': widget.ad['userId']}
    ]);
    setState(() {
      _ads = removeObjById(docs, widget.ad['id']);
    });
  }

  void init() async {
    setState(() {
      widget.dm.setToggleLoading(true);
    });
    await _fetchBusinessInfo();
    await _fetchBusinessAds();
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
        backgroundColor: hexToColor("#EDEEF6"),
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
                        nav_PushAndRemove(context, ExploreStart(dm: widget.dm));
                      },
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    IconButtonView(
                      iconColor: Colors.white,
                      backgroundColor: hexToColor("#2865F5"),
                      icon: Icons.person_2_outlined,
                      iconSize: 26,
                      width: 26,
                      onPress: () {
                        //
                        nav_Push(context, Login(dm: widget.dm));
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
                    BorderView(
                      radius: 12,
                      allColor: hexToColor("#E3E5F6"),
                      child: AsyncImageView(
                        imagePath: widget.ad['imagePath'],
                        width: getWidth(context),
                        height: getWidth(context) * 0.95,
                        objectFit: BoxFit.fill,
                        radius: 12,
                      ),
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
                                  const SizedBox(height: 10),
                                  TextView(
                                      text: _business!['description']
                                          .replaceAll('jjj', '\n'),
                                      size: 16,
                                      font: 'poppins',
                                      wrap: true),
                                  Row(
                                    children: [
                                      // PHONE
                                      if (widget.ad['isHidePhone'] != true)
                                        IconButtonView(
                                          backgroundColor:
                                              hexToColor("#44F64A"),
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
                                      if (widget.ad['isHideLocation'] != true)
                                        IconButtonView(
                                          backgroundColor:
                                              hexToColor("#F64451"),
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
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            if (widget.ad['isHideLocation'] != true)
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
                                      context, AdStart(dm: widget.dm, ad: ad));
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
