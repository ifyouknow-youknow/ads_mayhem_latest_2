import 'package:ads_mayhem_2/PAGES/business_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_library_latest/COMPONENTS/border_view.dart';
import 'package:flutter_library_latest/COMPONENTS/iconbutton_view.dart';
import 'package:flutter_library_latest/COMPONENTS/image_view.dart';
import 'package:flutter_library_latest/COMPONENTS/main_view.dart';
import 'package:flutter_library_latest/COMPONENTS/padding_view.dart';
import 'package:flutter_library_latest/COMPONENTS/text_view.dart';
import 'package:flutter_library_latest/COMPONENTS/textfield_view.dart';
import 'package:flutter_library_latest/FUNCTIONS/colors.dart';
import 'package:flutter_library_latest/FUNCTIONS/firebase.dart';
import 'package:flutter_library_latest/FUNCTIONS/nav.dart';
import 'package:flutter_library_latest/MODELS/datamaster.dart';

class Search extends StatefulWidget {
  final DataMaster dm;
  const Search({super.key, required this.dm});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController _searchText = TextEditingController();
  List<dynamic> _results = [];

  //
  void _onSearch() async {
    setState(() {
      widget.dm.setToggleLoading(true);
    });

    final docs = await firebase_GetAllDocumentsQueried(
        '${widget.dm.appName}_Businesses', [
      {'field': 'name', 'operator': '==', 'value': _searchText.text}
    ]);
    if (docs.isNotEmpty) {
      setState(() {
        widget.dm.setToggleLoading(false);
        _results = docs;
      });
    } else {
      setState(() {
        _results = [];
        widget.dm.setToggleLoading(false);
        widget.dm.setToggleAlert(true);
        widget.dm.setAlertTitle('No results');
        widget.dm.setAlertText(
            'Try typing the name differently or try another profile name.');
      });
    }
  }

  @override
  void dispose() {
    _searchText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainView(
        dm: widget.dm,
        background: ImageView(imagePath: 'assets/splash.png'),
        mobile: [
          //
          PaddingView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //
                const TextView(
                  text: 'Search',
                  size: 26,
                  font: 'poppins',
                  weight: FontWeight.w500,
                  spacing: -1,
                ),
                IconButtonView(
                  icon: Icons.close,
                  onPress: () {
                    //
                    nav_Pop(context);
                  },
                ),
              ],
            ),
          ),
          //
          const PaddingView(
            paddingTop: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: TextView(
                    text:
                        'To find the right profile, type the exact name of the business. ',
                    font: 'poppins',
                    size: 16,
                    wrap: true,
                  ),
                )
              ],
            ),
          ),

          //
          const SizedBox(
            height: 15,
          ),
          PaddingView(
            child: Row(
              children: [
                Expanded(
                  child: BorderView(
                    radius: 8,
                    allColor: Colors.black38,
                    child: TextfieldView(
                      controller: _searchText,
                      placeholder: 'ex. Johnny Rockets',
                      backgroundColor: Colors.white,
                      size: 20,
                      radius: 8,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                IconButtonView(
                    backgroundColor: Colors.black,
                    iconColor: Colors.white,
                    icon: Icons.search,
                    onPress: () {
                      //
                      _onSearch();
                    })
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                for (var res in _results)
                  PaddingView(
                    paddingBottom: 0,
                    child: Column(
                      children: [
                        TextView(
                          text: res['name'],
                          size: 28,
                          font: 'poppins',
                          spacing: -1,
                          weight: FontWeight.w500,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        IconButtonView(
                            backgroundColor: hexToColor("#1689FF"),
                            width: 35,
                            icon: Icons.arrow_forward,
                            iconColor: Colors.white,
                            iconSize: 32,
                            onPress: () {
                              //
                              nav_Push(
                                  context,
                                  BusinessProfile(
                                      dm: widget.dm,
                                      businessId: res['id']), () {
                                setState(() {
                                  _searchText.text = "";
                                  _results = [];
                                });
                              });
                            })
                      ],
                    ),
                  )
              ],
            ),
          ))
        ]);
  }
}
