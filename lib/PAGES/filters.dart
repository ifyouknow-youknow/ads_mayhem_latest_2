import 'package:ads_mayhem_2/PAGES/explore_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_library_latest/COMPONENTS/button_view.dart';
import 'package:flutter_library_latest/COMPONENTS/iconbutton_view.dart';
import 'package:flutter_library_latest/COMPONENTS/main_view.dart';
import 'package:flutter_library_latest/COMPONENTS/map_view.dart';
import 'package:flutter_library_latest/COMPONENTS/padding_view.dart';
import 'package:flutter_library_latest/COMPONENTS/pill_view.dart';
import 'package:flutter_library_latest/COMPONENTS/roundedcorners_view.dart';
import 'package:flutter_library_latest/COMPONENTS/slider_view.dart';
import 'package:flutter_library_latest/COMPONENTS/text_view.dart';
import 'package:flutter_library_latest/FUNCTIONS/array.dart';
import 'package:flutter_library_latest/FUNCTIONS/colors.dart';
import 'package:flutter_library_latest/FUNCTIONS/firebase.dart';
import 'package:flutter_library_latest/FUNCTIONS/nav.dart';
import 'package:flutter_library_latest/MODELS/constants.dart';
import 'package:flutter_library_latest/MODELS/datamaster.dart';
import 'package:flutter_library_latest/MODELS/geohash.dart';
import 'package:flutter_library_latest/MODELS/screen.dart';

class Filters extends StatefulWidget {
  final DataMaster dm;
  const Filters({super.key, required this.dm});

  @override
  State<Filters> createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  double _distance = 30;
  bool _distanceChanged = false;
  Map<String, dynamic>? _location = null;
  List<dynamic> _categories = [];
  String _selectedCategory = "";
  //

  void onChangeDistance() async {
    print(widget.dm.user);
    final success = await firebase_UpdateDocument('${widget.dm.appName}_Users',
        widget.dm.user['id'], {'distance': _distance});
    if (success) {
      setState(() {
        widget.dm.setBubbleText('distance saved.');
        widget.dm.setToggleBubble(true);
        _distanceChanged = false;
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            widget.dm.setUser({...widget.dm.user, 'distance': _distance});
            widget.dm.setToggleBubble(false);
          });
        });
      });
    } else {
      setState(() {
        widget.dm.alertSomethingWrong();
      });
    }
  }

  void onChangeCategory(Map<String, dynamic> category) async {
    if (_selectedCategory == category['category']) {
      await firebase_UpdateDocument(
          '${widget.dm.appName}_Users', widget.dm.user['id'], {'category': ""});
      setState(() {
        widget.dm.setUser({...widget.dm.user, 'category': ""});
        _selectedCategory = "";
      });
    } else {
      await firebase_UpdateDocument('${widget.dm.appName}_Users',
          widget.dm.user['id'], {'category': category['category']});
      setState(() {
        widget.dm
            .setUser({...widget.dm.user, 'category': category['category']});
        _selectedCategory = category['category'];
      });
    }
    setState(() {
      widget.dm.setBubbleText('category set');
      widget.dm.setToggleBubble(true);
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          widget.dm.setToggleBubble(false);
        });
      });
    });
  }

  void onClearCategory() async {
    await firebase_UpdateDocument(
        '${widget.dm.appName}_Users', widget.dm.user['id'], {'category': ""});
    setState(() {
      widget.dm.setToggleBubble(true);
      widget.dm.setBubbleText('category cleared');
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          widget.dm.setToggleBubble(false);
        });
      });
      widget.dm.setUser({...widget.dm.user, 'category': ""});
      _selectedCategory = "";
    });
  }

  void onChangeLocation(Map<String, dynamic> loc) async {
    final geohash = Geohash.encode(loc['latitude'], loc['longitude']);

    final success = await firebase_UpdateDocument('${widget.dm.appName}_Users',
        widget.dm.user['id'], {'geohash': geohash});
    if (success) {
      setState(() {
        widget.dm.setUser({...widget.dm.user, 'geohash': geohash});
        widget.dm.setBubbleText('location set');
        widget.dm.setToggleBubble(true);
        Future.delayed(const Duration(seconds: 2));
      });
    }
  }

  Future<void> init() async {
    if (widget.dm.user['distance'] != null) {
      setState(() {
        _distance = widget.dm.user['distance'];
      });
    }
    if (widget.dm.user['geohash'] != null) {
      setState(() {
        _location = Geohash.decode(widget.dm.user['geohash']);
      });
    }

    final docs =
        await firebase_GetAllDocuments('${widget.dm.appName}_Categories');
    setState(() {
      _categories = sortArrayByProperty(docs, 'category');
    });
    if (widget.dm.user['category'] != "" ||
        widget.dm.user['category'] != null) {
      setState(() {
        _selectedCategory = widget.dm.user['category'];
      });
    }

    setState(() {});
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  //
  @override
  Widget build(BuildContext context) {
    return MainView(
        dm: widget.dm,
        backgroundColor: hexToColor("#EDEEF6"),
        mobile: [
          //
          PaddingView(
            child: Row(
              children: [
                IconButtonView(
                  icon: Icons.arrow_back,
                  onPress: () {
                    nav_Pop(context);
                  },
                ),
              ],
            ),
          ),
          //
          const PaddingView(
            paddingBottom: 0,
            child: Row(
              children: [
                TextView(
                  text: 'Filters',
                  size: 30,
                  font: 'poppins',
                  weight: FontWeight.w500,
                  spacing: -1,
                )
              ],
            ),
          ),
          //
          Expanded(
            child: SingleChildScrollView(
              child: SizedBox(
                width: getWidth(context),
                child: PaddingView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //
                      RoundedCornersView(
                        all: 20,
                        backgroundColor: Colors.white,
                        child: PaddingView(
                          paddingAll: 15,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TextView(
                                text: 'distance',
                                size: 18,
                                font: 'poppins',
                                weight: FontWeight.w500,
                              ),
                              const TextView(
                                text:
                                    'Distance is measured in km from your set location.',
                                font: 'poppins',
                              ),
                              TextView(
                                text: '${_distance.toStringAsFixed(0)}km',
                                font: 'poppins',
                                size: 40,
                                weight: FontWeight.w600,
                                spacing: -1,
                              ),
                              Row(
                                children: [
                                  const TextView(
                                    text: '1 km',
                                    font: 'poppins',
                                  ),
                                  Expanded(
                                    child: SliderView(
                                      color: hexToColor("#1689FF"),
                                      min: 1,
                                      max: 60,
                                      increment: 1,
                                      start: widget.dm.user['distance'] ?? 30,
                                      onChange: (value) {
                                        setState(() {
                                          _distanceChanged = true;
                                          _distance = value;
                                        });
                                      },
                                    ),
                                  ),
                                  const TextView(
                                    text: '60km',
                                    font: 'poppins',
                                  ),
                                  if (_distanceChanged)
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        IconButtonView(
                                          backgroundColor:
                                              hexToColor("#2865F5"),
                                          width: 30,
                                          icon: Icons.save,
                                          iconSize: 24,
                                          iconColor: Colors.white,
                                          onPress: () {
                                            //
                                            onChangeDistance();
                                          },
                                        ),
                                      ],
                                    )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      //
                      RoundedCornersView(
                        all: 20,
                        backgroundColor: Colors.white,
                        child: PaddingView(
                          paddingAll: 15,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TextView(
                                text: 'location',
                                size: 18,
                                font: 'poppins',
                                weight: FontWeight.w500,
                              ),
                              const TextView(
                                text:
                                    'Specify the location where you want to view ads.',
                                font: 'poppins',
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              MapView(
                                delta: .0006,
                                height: 250,
                                isScrolling: true,
                                isSearchable: true,
                                isZoomable: true,
                                locations: [
                                  _location != null
                                      ? _location!
                                      : {
                                          'latitude': testCoordinates2.latitude,
                                          'longitude':
                                              testCoordinates2.longitude
                                        }
                                ],
                                onMarkerTap: (loc) {
                                  //
                                  onChangeLocation(loc);
                                },
                              ),
                              PaddingView(
                                  paddingLeft: 0,
                                  paddingRight: 0,
                                  child: TextView(
                                    text:
                                        'Tap on the marker to confirm the location.',
                                    color: hexToColor("#2865F52865F5"),
                                  ))
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      //
                      RoundedCornersView(
                        all: 20,
                        backgroundColor: Colors.white,
                        child: PaddingView(
                          paddingAll: 15,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TextView(
                                text: 'category',
                                size: 18,
                                font: 'poppins',
                                weight: FontWeight.w500,
                              ),
                              const TextView(
                                text:
                                    'Pick the category you are looking for. Not selecting any will allow all categories to be shown.',
                                font: 'poppins',
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ButtonView(
                                    child: const TextView(
                                      text: 'clear',
                                      isUnderlined: true,
                                      size: 18,
                                    ),
                                    onPress: () async {
                                      //
                                      onClearCategory();
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              for (var category in _categories)
                                SizedBox(
                                  width: double.infinity,
                                  child: ButtonView(
                                    child: PillView(
                                        backgroundColor: _selectedCategory ==
                                                category['category']
                                            ? hexToColor("#2865F5")
                                            : Colors.white,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextView(
                                              text: category['category'],
                                              size: 16,
                                              font: 'poppins',
                                              color: _selectedCategory ==
                                                      category['category']
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                            if (_selectedCategory ==
                                                category['category'])
                                              Icon(
                                                Icons.check,
                                                size: 22,
                                                color: _selectedCategory ==
                                                        category['category']
                                                    ? Colors.white
                                                    : Colors.black,
                                              )
                                          ],
                                        )),
                                    onPress: () async {
                                      //
                                      onChangeCategory(category);
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]);
  }
}
