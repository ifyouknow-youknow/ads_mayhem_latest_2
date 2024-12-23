import 'package:ads_mayhem_2/PAGES/explore_main.dart';
import 'package:flutter/material.dart';
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
import 'package:flutter_library_latest/COMPONENTS/textfield_view.dart';
import 'package:flutter_library_latest/FUNCTIONS/colors.dart';
import 'package:flutter_library_latest/FUNCTIONS/firebase.dart';
import 'package:flutter_library_latest/FUNCTIONS/nav.dart';
import 'package:flutter_library_latest/MODELS/constants.dart';
import 'package:flutter_library_latest/MODELS/datamaster.dart';
import 'package:flutter_library_latest/MODELS/geohash.dart';
import 'package:flutter_library_latest/MODELS/screen.dart';

class SignUp extends StatefulWidget {
  final DataMaster dm;
  const SignUp({super.key, required this.dm});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _firstName = TextEditingController();
  TextEditingController _lastName = TextEditingController();
  TextEditingController _email = TextEditingController();
  String _geohash = "";
  TextEditingController _password = TextEditingController();
  TextEditingController _confirmPassword = TextEditingController();

  //
  void onSignUp() async {
    //
    if (_firstName.text.isEmpty ||
        _lastName.text.isEmpty ||
        _email.text.isEmpty ||
        _password.text.isEmpty ||
        _confirmPassword.text.isEmpty) {
      setState(() {
        widget.dm.alertMissingInfo();
      });
      return;
    }
    if (_geohash.isEmpty) {
      setState(() {
        widget.dm.setToggleAlert(true);
        widget.dm.setAlertTitle('Missing Location');
        widget.dm.setAlertText(
            'Please enter a location to view ads from that area. Tap on the marker to confirm your selection.');
      });
      return;
    }
    if (_password.text != _confirmPassword.text) {
      setState(() {
        widget.dm.setToggleAlert(true);
        widget.dm.setAlertTitle('Passwords dont match');
        widget.dm.setAlertText('Please make sure your passwords match.');
      });
      return;
    }

    setState(() {
      widget.dm.setToggleLoading(true);
    });

    final user = await auth_CreateUser(_email.text, _password.text);

    if (user != null) {
      final success = await firebase_CreateDocument('Users', user.uid, {
        'firstName': _firstName.text,
        'lastName': _lastName.text,
        'email': _email.text,
        'geohash': _geohash
      });
      setState(() {
        widget.dm.setToggleLoading(false);
      });
      if (success) {
        nav_PushAndRemove(context, ExploreMain(dm: widget.dm));
      } else {
        setState(() {
          widget.dm.setToggleLoading(false);
          widget.dm.alertSomethingWrong();
        });
      }
    } else {
      setState(() {
        widget.dm.setToggleLoading(false);
        widget.dm.alertSomethingWrong();
      });
    }
  }

//
  @override
  Widget build(BuildContext context) {
    return MainView(
        dm: widget.dm,
        background: const ImageView(
          imagePath: 'assets/splash.png',
          objectFit: BoxFit.fill,
        ),
        mobile: [
          //
          PaddingView(
            child: Row(
              children: [
                IconButtonView(
                    icon: Icons.arrow_back,
                    onPress: () {
                      //
                      nav_Pop(context);
                    })
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: SizedBox(
                width: getWidth(context),
                child: PaddingView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TextView(
                        text: 'Sign Up',
                        font: 'poppins',
                        size: 30,
                        spacing: -1,
                        weight: FontWeight.w500,
                      ),
                      const TextView(
                        text: 'first name',
                      ),
                      BorderView(
                        allColor: Colors.black38,
                        radius: 8,
                        child: TextfieldView(
                          controller: _firstName,
                          placeholder: 'ex. John',
                          backgroundColor: Colors.white,
                          isCap: true,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const TextView(
                        text: 'last name',
                      ),
                      BorderView(
                        allColor: Colors.black38,
                        radius: 8,
                        child: TextfieldView(
                          controller: _lastName,
                          placeholder: 'ex. Doe',
                          backgroundColor: Colors.white,
                          isCap: true,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const TextView(
                        text: 'email',
                      ),
                      BorderView(
                        allColor: Colors.black38,
                        radius: 8,
                        child: TextfieldView(
                          controller: _email,
                          placeholder: 'ex. jdoe@gmail.com',
                          backgroundColor: Colors.white,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const TextView(
                        text: 'location',
                      ),
                      BorderView(
                        radius: 10,
                        allColor: Colors.black38,
                        child: RoundedCornersView(
                          backgroundColor: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MapView(
                                  delta: .0004,
                                  isSearchable: true,
                                  height: 180,
                                  locations: [
                                    {
                                      'latitude': testCoordinates.latitude,
                                      'longitude': testCoordinates.longitude
                                    }
                                  ],
                                  onMarkerTap: (loc) {
                                    //
                                    setState(() {
                                      widget.dm.setBubbleText('Location Set');
                                      widget.dm.setToggleBubble(true);
                                      _geohash = Geohash.encode(
                                          loc['latitude'], loc['longitude']);
                                      Future.delayed(const Duration(seconds: 5),
                                          () {
                                        setState(() {
                                          widget.dm.setToggleBubble(false);
                                        });
                                      });
                                    });
                                  }),
                              PaddingView(
                                child: TextView(
                                  text:
                                      'Tap on the marker to confirm the location.',
                                  size: 14,
                                  color: hexToColor("#2865F5"),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const TextView(
                        text: 'password',
                      ),
                      BorderView(
                        allColor: Colors.black38,
                        radius: 8,
                        child: TextfieldView(
                          controller: _password,
                          placeholder: 'min 8 characters',
                          backgroundColor: Colors.white,
                          isPassword: true,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const TextView(
                        text: 'confirm password',
                      ),
                      BorderView(
                        allColor: Colors.black38,
                        radius: 8,
                        child: TextfieldView(
                          controller: _confirmPassword,
                          placeholder: 'passwords must match',
                          backgroundColor: Colors.white,
                          isPassword: true,
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
          PaddingView(
              paddingBottom: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ButtonView(
                    child: PillView(
                        paddingV: 12,
                        paddingH: 18,
                        backgroundColor: Colors.black,
                        child: Row(
                          children: [
                            const TextView(
                              text: 'sign up',
                              size: 18,
                              color: Colors.white,
                              weight: FontWeight.w500,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.check,
                              color: hexToColor("#1689FF"),
                              size: 24,
                            ),
                          ],
                        )),
                    onPress: () {
                      onSignUp();
                    },
                  ),
                ],
              ))
        ]);
  }
}
