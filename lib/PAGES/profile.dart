import 'package:ads_mayhem_2/PAGES/ad_main.dart';
import 'package:ads_mayhem_2/PAGES/business_profile.dart';
import 'package:ads_mayhem_2/PAGES/get_started.dart';
import 'package:flutter/material.dart';
import 'package:flutter_library_latest/COMPONENTS/asyncimage_view.dart';
import 'package:flutter_library_latest/COMPONENTS/border_view.dart';
import 'package:flutter_library_latest/COMPONENTS/button_view.dart';
import 'package:flutter_library_latest/COMPONENTS/iconbutton_view.dart';
import 'package:flutter_library_latest/COMPONENTS/main_view.dart';
import 'package:flutter_library_latest/COMPONENTS/padding_view.dart';
import 'package:flutter_library_latest/COMPONENTS/pill_view.dart';
import 'package:flutter_library_latest/COMPONENTS/roundedcorners_view.dart';
import 'package:flutter_library_latest/COMPONENTS/text_view.dart';
import 'package:flutter_library_latest/FUNCTIONS/colors.dart';
import 'package:flutter_library_latest/FUNCTIONS/date.dart';
import 'package:flutter_library_latest/FUNCTIONS/firebase.dart';
import 'package:flutter_library_latest/FUNCTIONS/nav.dart';
import 'package:flutter_library_latest/MODELS/datamaster.dart';
import 'package:flutter_library_latest/MODELS/screen.dart';

class Profile extends StatefulWidget {
  final DataMaster dm;
  const Profile({super.key, required this.dm});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _selectedSection = "Favorites";
  List<dynamic> _favorites = [];
  List<dynamic> _following = [];
  List<dynamic> _scans = [];
  double adSize = .25;

  final List<String> _sections = ["Favorites", "Following", "Scans"];

  Future<void> _fetchFavorites() async {
    final things = [];
    final docs = await firebase_GetAllDocumentsQueried(
        '${widget.dm.appName}_Favorites', [
      {'field': 'userId', 'operator': '==', 'value': widget.dm.user['id']}
    ]);
    for (var fave in docs) {
      final doc = await firebase_GetDocument(
          '${widget.dm.appName}_Campaigns', fave['adId']);
      things.add(doc);
    }

    setState(() {
      _favorites = things;
    });
  }

  Future<void> _fetchBusinessAds() async {
    final objs = [];
    final followed = await firebase_GetAllDocumentsQueried(
        '${widget.dm.appName}_Following', [
      {'field': 'userId', 'operator': '==', 'value': widget.dm.user['id']}
    ]);
    for (var fol in followed) {
      final ads = await firebase_GetAllDocumentsQueriedLimited(
          '${widget.dm.appName}_Campaigns',
          [
            {'field': 'userId', 'operator': '==', 'value': fol['businessId']}
          ],
          4);
      final obj = {...fol, 'ads': ads};
      objs.add(obj);
    }
    setState(() {
      _following = objs;
    });
  }

  Future<void> _fetchScans() async {
    final docs = await firebase_GetAllDocumentsOrderedQueriedLimited(
        '${widget.dm.appName}_Scans',
        [
          {'field': 'userId', 'operator': '==', 'value': widget.dm.user['id']}
        ],
        'date',
        'desc',
        200);
    final all = [];
    for (var scan in docs) {
      final adId = scan['adId'];
      final ad =
          await firebase_GetDocument('${widget.dm.appName}_Campaigns', adId);
      all.add({...scan, 'ad': ad});
    }

    setState(() {
      _scans = all;
    });
  }

  void init() async {
    setState(() {
      widget.dm.setToggleLoading(true);
    });
    await _fetchFavorites();
    await _fetchBusinessAds();
    await _fetchScans();
    setState(() {
      widget.dm.setToggleLoading(false);
    });
  }

  void onSignOut() async {
    setState(() {
      widget.dm.setToggleLoading(true);
    });
    final success = await auth_SignOut();
    if (success) {
      setState(() {
        widget.dm.setToggleLoading(false);
      });
      nav_PushAndRemove(context, GetStarted(dm: widget.dm));
    } else {
      setState(() {
        widget.dm.setToggleLoading(false);
        widget.dm.alertSomethingWrong();
      });
    }
  }

  void onDeleteAccount() async {
    setState(() {
      widget.dm.setToggleAlert(true);
      widget.dm.setAlertTitle('Delete Account');
      widget.dm.setAlertText(
          'Are you sure you want to delete your account? This action cannot be reversed.');
      widget.dm.setAlertButtons([
        PaddingView(
          paddingTop: 0,
          paddingBottom: 0,
          child: ButtonView(
              child: const PillView(
                  backgroundColor: Colors.red,
                  child: TextView(
                    text: 'delete account',
                    color: Colors.white,
                    size: 18,
                  )),
              onPress: () async {
                setState(() {
                  widget.dm.setToggleAlert(false);
                  widget.dm.setToggleLoading(true);
                });

                final user = await auth_CheckUser();
                final userId = widget.dm.user['id'];
                if (user != null) {
                  final success = await auth_DeleteUser(user);
                  if (success) {
                    // SCANS
                    final scans = await firebase_GetAllDocumentsQueried(
                        '${widget.dm.appName}_Scans', [
                      {'field': 'userId', 'operator': '==', 'value': userId}
                    ]);
                    for (var scan in scans) {
                      await firebase_DeleteDocument(
                          '${widget.dm.appName}_Scans', scan['id']);
                    }
                    // FOLLOWING
                    final follows = await firebase_GetAllDocumentsQueried(
                        '${widget.dm.appName}_Following', [
                      {'field': 'userId', 'operator': '==', 'value': userId}
                    ]);
                    for (var follow in follows) {
                      await firebase_DeleteDocument(
                          '${widget.dm.appName}_Following', follow['id']);
                    }
                    // FAVORITES
                    final faves = await firebase_GetAllDocumentsQueried(
                        '${widget.dm.appName}_Favorites', [
                      {'field': 'userId', 'operator': '==', 'value': userId}
                    ]);
                    for (var fav in faves) {
                      await firebase_DeleteDocument(
                          '${widget.dm.appName}_Favorites', fav['id']);
                    }
                    // VIEWS
                    final views = await firebase_GetAllDocumentsQueried(
                        '${widget.dm.appName}_Views', [
                      {'field': 'userId', 'operator': '==', 'value': userId}
                    ]);
                    for (var view in views) {
                      await firebase_DeleteDocument(
                          '${widget.dm.appName}_Views', view['id']);
                    }
                    // CLICKS
                    final clicks = await firebase_GetAllDocumentsQueried(
                        '${widget.dm.appName}_Clicks', [
                      {'field': 'userId', 'operator': '==', 'value': userId}
                    ]);
                    for (var click in clicks) {
                      await firebase_DeleteDocument(
                          '${widget.dm.appName}_Clicks', click['id']);
                    }
                    // DOC
                    final success = await firebase_DeleteDocument(
                        '${widget.dm.appName}_Users', userId);
                    if (success) {
                      nav_PushAndRemove(context, GetStarted(dm: widget.dm));
                      setState(() {
                        widget.dm.setToggleLoading(false);
                        widget.dm.setToggleAlert(true);
                        widget.dm.setAlertTitle('Account Removed');
                        widget.dm.setAlertText(
                            'Your account was successfully removed.');
                      });
                    }
                  }
                }
              }),
        )
      ]);
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MainView(dm: widget.dm, mobile: [
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
      PaddingView(
        paddingTop: 0,
        child: Column(
          children: [
            const Row(
              children: [
                TextView(
                  text: 'Profile',
                  spacing: -1,
                  weight: FontWeight.w600,
                  size: 30,
                  font: 'poppins',
                )
              ],
            ),
            SizedBox(
              width: getWidth(context),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: _sections.map((section) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ButtonView(
                        child: PillView(
                          backgroundColor: _selectedSection == section
                              ? hexToColor("#2865F5")
                              : hexToColor("#EDEEF6"),
                          child: TextView(
                            text: section,
                            color: _selectedSection == section
                                ? Colors.white
                                : Colors.black,
                            size: 16,
                            font: 'poppins',
                          ),
                        ),
                        onPress: () {
                          setState(() {
                            _selectedSection = section;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      //

      if (_selectedSection == 'Favorites')
        Expanded(
          child: SingleChildScrollView(
            child: PaddingView(
              child: Column(
                children: [
                  if (_favorites.isNotEmpty)
                    GridView.builder(
                      padding: const EdgeInsets.all(0),
                      physics:
                          const NeverScrollableScrollPhysics(), // Prevents nested scrolling
                      shrinkWrap:
                          true, // Allows the GridView to fit within its parent
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Two items per row
                        crossAxisSpacing: 8.0, // Spacing between columns
                        mainAxisSpacing: 8.0, // Spacing between rows
                        childAspectRatio: 1.0, // 1:1 aspect ratio for each item
                      ),
                      itemCount:
                          _favorites.length, // Number of items in the grid
                      itemBuilder: (context, index) {
                        var favorite = _favorites[index];
                        return BorderView(
                          radius: 12,
                          allColor: hexToColor("#E1E4F6"),
                          child: ButtonView(
                            child: AsyncImageView(
                              radius: 12,
                              imagePath: favorite['imagePath'],
                            ),
                            onPress: () {
                              // Handle the button press
                              nav_Push(
                                  context, AdMain(dm: widget.dm, ad: favorite));
                            },
                          ),
                        );
                      },
                    ),
                  if (_favorites.isEmpty)
                    const Center(
                      child: PaddingView(
                          child: TextView(
                        text: 'no favorite ads yet.',
                        font: 'poppins',
                        size: 16,
                      )),
                    )
                ],
              ),
            ),
          ),
        ),
      //
      if (_selectedSection == "Following")
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //
                for (var fol in _following)
                  SizedBox(
                    width: getWidth(context),
                    child: PaddingView(
                      paddingBottom: 0,
                      child: RoundedCornersView(
                        all: 15,
                        backgroundColor: hexToColor("#F8F9FA"),
                        child: PaddingView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextView(
                                text: fol['businessName'],
                                font: 'poppins',
                                size: 20,
                                spacing: -1,
                                weight: FontWeight.w500,
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              if (fol['ads'].isNotEmpty)
                                SizedBox(
                                  width: getWidth(context),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        BorderView(
                                          allColor: hexToColor("#E1E4F6"),
                                          radius: 8,
                                          child: ButtonView(
                                            onPress: () {
                                              nav_Push(
                                                  context,
                                                  AdMain(
                                                      dm: widget.dm,
                                                      ad: fol['ads'][0]));
                                            },
                                            child: AsyncImageView(
                                              imagePath: fol['ads'][0]
                                                  ['imagePath'],
                                              width: getWidth(context) * adSize,
                                              height:
                                                  getWidth(context) * adSize,
                                              radius: 8,
                                            ),
                                          ),
                                        ),
                                        if (fol['ads'].length > 1)
                                          Row(
                                            children: [
                                              const SizedBox(
                                                width: 6,
                                              ),
                                              BorderView(
                                                allColor: hexToColor("#E1E4F6"),
                                                radius: 8,
                                                child: ButtonView(
                                                  onPress: () {
                                                    nav_Push(
                                                        context,
                                                        AdMain(
                                                            dm: widget.dm,
                                                            ad: fol['ads'][1]));
                                                  },
                                                  child: AsyncImageView(
                                                    imagePath: fol['ads'][1]
                                                        ['imagePath'],
                                                    width: getWidth(context) *
                                                        adSize,
                                                    height: getWidth(context) *
                                                        adSize,
                                                    radius: 8,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        if (fol['ads'].length > 2)
                                          Row(
                                            children: [
                                              const SizedBox(
                                                width: 6,
                                              ),
                                              BorderView(
                                                allColor: hexToColor("#E1E4F6"),
                                                radius: 8,
                                                child: ButtonView(
                                                  onPress: () {
                                                    nav_Push(
                                                        context,
                                                        AdMain(
                                                            dm: widget.dm,
                                                            ad: fol['ads'][2]));
                                                  },
                                                  child: AsyncImageView(
                                                    imagePath: fol['ads'][2]
                                                        ['imagePath'],
                                                    width: getWidth(context) *
                                                        adSize,
                                                    height: getWidth(context) *
                                                        adSize,
                                                    radius: 8,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        if (fol['ads'].length > 3)
                                          Row(
                                            children: [
                                              const SizedBox(
                                                width: 6,
                                              ),
                                              BorderView(
                                                allColor: hexToColor("#E1E4F6"),
                                                radius: 8,
                                                child: ButtonView(
                                                  onPress: () {
                                                    nav_Push(
                                                        context,
                                                        AdMain(
                                                            dm: widget.dm,
                                                            ad: fol['ads'][3]));
                                                  },
                                                  child: AsyncImageView(
                                                    imagePath: fol['ads'][3]
                                                        ['imagePath'],
                                                    width: getWidth(context) *
                                                        adSize,
                                                    height: getWidth(context) *
                                                        adSize,
                                                    radius: 8,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        //
                                        PaddingView(
                                          paddingTop: 0,
                                          paddingBottom: 0,
                                          child: IconButtonView(
                                            backgroundColor: Colors.black,
                                            width: 30,
                                            icon: Icons.store,
                                            iconColor: Colors.white,
                                            onPress: () {
                                              //
                                              nav_Push(
                                                  context,
                                                  BusinessProfile(
                                                    dm: widget.dm,
                                                    businessId:
                                                        fol['businessId'],
                                                  ), () async {
                                                await _fetchBusinessAds();
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
//
                if (_following.isEmpty)
                  const Center(
                    child: PaddingView(
                      child: TextView(
                        text: 'no following businesses yet.',
                        size: 16,
                        font: 'poppins',
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      //
      if (_selectedSection == "Scans")
        Expanded(
          child: SingleChildScrollView(
            child: PaddingView(
              child: Column(
                children: [
                  //
                  for (var scan in _scans)
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              AsyncImageView(
                                imagePath: scan['ad']['imagePath'],
                                radius: 6,
                                width: 60,
                                height: 60,
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    TextView(
                                      text: 'Scanned on ${formatDate(
                                        DateTime.fromMillisecondsSinceEpoch(
                                          scan['date'],
                                        ),
                                      )}',
                                      size: 16,
                                      weight: FontWeight.w500,
                                    ),
                                    if (scan['ad']['isCoupon'])
                                      TextView(
                                        text:
                                            'expires on ${formatShortDate(DateTime.fromMillisecondsSinceEpoch(scan['ad']['expDate']))}',
                                        wrap: true,
                                        color: hexToColor("#1689FF"),
                                      )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                    ),
                  //

                  if (_scans.isEmpty)
                    const Center(
                      child: PaddingView(
                        child: TextView(
                          text: 'no scans yet.',
                          size: 16,
                          font: 'poppins',
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
        ),

      //
      PaddingView(
        paddingLeft: 15,
        paddingRight: 15,
        paddingBottom: 20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButtonView(
              icon: Icons.person_off_outlined,
              onPress: () {
                //
                onDeleteAccount();
              },
            ),
            const TextView(
              text: 'a nothing bagel. ver 2.0',
              color: Colors.black45,
              size: 12,
            ),
            IconButtonView(
                backgroundColor: Colors.red,
                iconColor: Colors.white,
                icon: Icons.logout_outlined,
                onPress: () {
                  //
                  onSignOut();
                })
          ],
        ),
      )
    ]);
  }
}
