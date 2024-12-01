import 'package:ads_mayhem_2/PAGES/ad_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_library_latest/COMPONENTS/asyncimage_view.dart';
import 'package:flutter_library_latest/COMPONENTS/border_view.dart';
import 'package:flutter_library_latest/COMPONENTS/button_view.dart';
import 'package:flutter_library_latest/COMPONENTS/iconbutton_view.dart';
import 'package:flutter_library_latest/COMPONENTS/main_view.dart';
import 'package:flutter_library_latest/COMPONENTS/padding_view.dart';
import 'package:flutter_library_latest/COMPONENTS/pill_view.dart';
import 'package:flutter_library_latest/COMPONENTS/text_view.dart';
import 'package:flutter_library_latest/FUNCTIONS/colors.dart';
import 'package:flutter_library_latest/FUNCTIONS/firebase.dart';
import 'package:flutter_library_latest/FUNCTIONS/misc.dart';
import 'package:flutter_library_latest/FUNCTIONS/nav.dart';
import 'package:flutter_library_latest/MODELS/datamaster.dart';
import 'package:flutter_library_latest/MODELS/screen.dart';

class BusinessProfile extends StatefulWidget {
  final DataMaster dm;
  final String businessId;
  const BusinessProfile(
      {super.key, required this.dm, required this.businessId});

  @override
  State<BusinessProfile> createState() => _BusinessProfileState();
}

class _BusinessProfileState extends State<BusinessProfile> {
  Map<String, dynamic>? _business = null;
  bool _isFollowing = false;
  String _followedId = "";
  List<dynamic> _ads = [];

  Future<void> _fetchBusinessInfo() async {
    //
    final doc = await firebase_GetDocument(
        '${widget.dm.appName}_Businesses', widget.businessId);
    _business = doc;
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

  Future<void> _fetchBusinessAds() async {
    final ads = await firebase_GetAllDocumentsQueried(
        '${widget.dm.appName}_Campaigns', [
      {'field': 'userId', 'operator': '==', 'value': widget.businessId},
      {'field': 'active', 'operator': '==', 'value': true}
    ]);
    setState(() {
      _ads = ads;
    });
  }

  void init() async {
    setState(() {
      widget.dm.setToggleLoading(true);
    });
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

  //
  @override
  Widget build(BuildContext context) {
    return MainView(dm: widget.dm, mobile: [
      //
      PaddingView(
        paddingBottom: 0,
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
      if (_business != null)
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                //
                TextView(
                  text: _business!['name'],
                  font: 'poppins',
                  size: 40,
                  weight: FontWeight.w500,
                  spacing: -1,
                  wrap: true,
                ),
                const SizedBox(
                  height: 15,
                ),
                PaddingView(
                  child: Row(
                    children: [
                      IconButtonView(
                        width: 32,
                        icon: Icons.call,
                        onPress: () {
                          //
                        },
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: ButtonView(
                          child: PillView(
                              paddingV: 16,
                              backgroundColor: _isFollowing
                                  ? hexToColor("#EDEEF6")
                                  : Colors.black,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextView(
                                    text: _isFollowing ? 'following' : 'follow',
                                    size: 20,
                                    weight: FontWeight.w500,
                                    color: _isFollowing
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ],
                              )),
                          onPress: () {
                            //
                            _onFollowUnfollow();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                PaddingView(
                  child: Column(
                    children: [
                      //
                      for (var ad in _ads)
                        Column(
                          children: [
                            ButtonView(
                              child: BorderView(
                                  radius: 12,
                                  allColor: hexToColor("#E1E4F6"),
                                  child: AsyncImageView(
                                    imagePath: ad['imagePath'],
                                    radius: 12,
                                    width: getWidth(context),
                                    height: getWidth(context),
                                    objectFit: BoxFit.fill,
                                  )),
                              onPress: () {
                                //
                                nav_Push(
                                    context, AdMain(dm: widget.dm, ad: ad));
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                      //
                      const SizedBox(
                        height: 30,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    ]);
  }
}
