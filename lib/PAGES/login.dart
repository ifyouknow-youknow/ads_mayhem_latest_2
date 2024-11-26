import 'package:ads_mayhem_2/PAGES/explore_main.dart';
import 'package:ads_mayhem_2/PAGES/explore_start.dart';
import 'package:ads_mayhem_2/PAGES/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_library_latest/COMPONENTS/border_view.dart';
import 'package:flutter_library_latest/COMPONENTS/button_view.dart';
import 'package:flutter_library_latest/COMPONENTS/image_view.dart';
import 'package:flutter_library_latest/COMPONENTS/main_view.dart';
import 'package:flutter_library_latest/COMPONENTS/padding_view.dart';
import 'package:flutter_library_latest/COMPONENTS/pill_view.dart';
import 'package:flutter_library_latest/COMPONENTS/text_view.dart';
import 'package:flutter_library_latest/COMPONENTS/textfield_view.dart';
import 'package:flutter_library_latest/FUNCTIONS/colors.dart';
import 'package:flutter_library_latest/FUNCTIONS/firebase.dart';
import 'package:flutter_library_latest/FUNCTIONS/nav.dart';
import 'package:flutter_library_latest/MODELS/datamaster.dart';
import 'package:flutter_library_latest/MODELS/screen.dart';

class Login extends StatefulWidget {
  final DataMaster dm;
  const Login({super.key, required this.dm});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();

  void onLogIn() async {
    if (_email.text.isEmpty || _password.text.isEmpty) {
      setState(() {
        widget.dm.alertMissingInfo();
      });
      return;
    }

    setState(() {
      widget.dm.setToggleLoading(true);
    });
    final user = await auth_SignIn(
        _email.text, _password.text, '${widget.dm.appName}_Users', widget.dm);
    if (user != null) {
      await widget.dm.checkUser('${widget.dm.appName}_Users');
      setState(() {
        widget.dm.setToggleLoading(false);
      });
      nav_PushAndRemove(context, ExploreMain(dm: widget.dm));
    } else {
      setState(() {
        widget.dm.setToggleLoading(false);
        widget.dm.alertSomethingWrong();
      });
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
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
            paddingTop: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ButtonView(
                  child: const Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Aligns items horizontally
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Aligns items vertically
                    children: [
                      Icon(
                        Icons.arrow_back,
                        size: 18,
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      TextView(
                        text: 'explore',
                        size: 17,
                      ),
                    ],
                  ),
                  onPress: () {
                    nav_Pop(context);
                  },
                ),
                ButtonView(
                    child: PillView(
                        backgroundColor: hexToColor("#2865F5"),
                        child: const Row(
                          children: [
                            TextView(
                              text: 'sign up',
                              color: Colors.white,
                              size: 16,
                              weight: FontWeight.w500,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 18,
                            )
                          ],
                        )),
                    onPress: () {
                      //
                      nav_Push(context, SignUp(dm: widget.dm));
                    }),
              ],
            ),
          ),
          const Spacer(
            flex: 1,
          ),

          PaddingView(
            paddingBottom: 40,
            child: SizedBox(
              width: getWidth(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextView(
                    text: 'login',
                    font: 'poppins',
                    size: 38,
                    spacing: -1,
                    weight: FontWeight.w600,
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  BorderView(
                    allColor: Colors.black38,
                    radius: 8,
                    child: TextfieldView(
                      controller: _email,
                      placeholder: 'Email.',
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  BorderView(
                    allColor: Colors.black38,
                    radius: 8,
                    child: TextfieldView(
                      controller: _password,
                      placeholder: 'Password.',
                      isPassword: true,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ButtonView(
                        child: const TextView(
                          text: 'forgot password?',
                          size: 16,
                        ),
                        onPress: () async {
                          //
                          final success =
                              await auth_ForgotPassword(_email.text, widget.dm);
                          if (success) {
                            setState(() {
                              widget.dm.setToggleAlert(true);
                              widget.dm.setAlertTitle('Success!');
                              widget.dm.setAlertText(
                                  'An email has been sent. Check your junk or spam folder if not found.');
                            });
                          } else {
                            setState(() {
                              widget.dm.setToggleAlert(true);
                              widget.dm.setAlertTitle('Invalid Email');
                              widget.dm.setAlertText(
                                  'Please provide a valid email to send a reset password form.');
                            });
                          }
                        },
                      ),
                      ButtonView(
                          child: PillView(
                              paddingV: 12,
                              paddingH: 18,
                              backgroundColor: Colors.black,
                              child: Row(
                                children: [
                                  const TextView(
                                    text: 'log in',
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
                            onLogIn();
                          })
                    ],
                  )
                ],
              ),
            ),
          )
        ]);
  }
}
