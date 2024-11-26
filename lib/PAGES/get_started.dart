import 'package:ads_mayhem_2/PAGES/explore_main.dart';
import 'package:ads_mayhem_2/PAGES/explore_start.dart';
import 'package:flutter/material.dart';
import 'package:flutter_library_latest/COMPONENTS/button_view.dart';
import 'package:flutter_library_latest/COMPONENTS/image_view.dart';
import 'package:flutter_library_latest/COMPONENTS/main_view.dart';
import 'package:flutter_library_latest/COMPONENTS/padding_view.dart';
import 'package:flutter_library_latest/COMPONENTS/pill_view.dart';
import 'package:flutter_library_latest/COMPONENTS/text_view.dart';
import 'package:flutter_library_latest/FUNCTIONS/colors.dart';
import 'package:flutter_library_latest/FUNCTIONS/firebase.dart';
import 'package:flutter_library_latest/FUNCTIONS/nav.dart';
import 'package:flutter_library_latest/MODELS/datamaster.dart';
import 'package:flutter_library_latest/MODELS/screen.dart';

class GetStarted extends StatefulWidget {
  final DataMaster dm;
  const GetStarted({super.key, required this.dm});

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  void init() async {
    setState(() {
      widget.dm.setToggleLoading(true);
    });

    final signedIn = await widget.dm.checkUser('${widget.dm.appName}_Users');
    setState(() {
      widget.dm.setToggleLoading(false);
    });
    if (signedIn) {
      nav_PushAndRemove(context, ExploreMain(dm: widget.dm));
    }
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
        background: const ImageView(
          imagePath: 'assets/splash.png',
          objectFit: BoxFit.fill,
        ),
        mobile: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              PaddingView(
                child: TextView(
                  text: 'ads mayhem',
                  size: 18,
                  weight: FontWeight.w500,
                  font: 'poppins',
                ),
              ),
            ],
          ),
          //
          ImageView(
            imagePath: 'assets/get-started.png',
            width: double.infinity,
            height: getHeight(context) * 0.5,
            radius: 15,
          ),
          const PaddingView(
            paddingTop: 20,
            paddingLeft: 20,
            paddingRight: 20,
            paddingBottom: 20,
            child: TextView(
              text:
                  'Where ads belong.\nNo bots. No scammers.\nReal people - with genuine interest.',
              size: 20,
              font: 'poppins',
            ),
          ),
          const Spacer(
            flex: 1,
          ),
          PaddingView(
            child: ButtonView(
                child: PillView(
                    paddingV: 16,
                    backgroundColor: Colors.black,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.rocket_launch_rounded,
                          color: hexToColor("#2865F5"),
                          size: 26,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const TextView(
                          text: 'explore ads',
                          color: Colors.white,
                          size: 20,
                          font: 'poppins',
                        )
                      ],
                    )),
                onPress: () {
                  nav_PushAndRemove(context, ExploreStart(dm: widget.dm));
                }),
          ),
          const PaddingView(
              paddingBottom: 20,
              child: Center(
                child: TextView(
                  text: 'a nothing bagel. ver 2.0',
                  color: Colors.black45,
                  font: 'poppins',
                ),
              ))
        ]);
  }
}
