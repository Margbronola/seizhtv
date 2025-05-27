// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/views/landing_page/source_management.dart';

import '../globals/data.dart';
import '../globals/data_cacher.dart';
import '../globals/logo.dart';

class SplashscreenPage extends StatefulWidget {
  const SplashscreenPage({super.key});

  @override
  State<SplashscreenPage> createState() => _SplashscreenPageState();
}

class _SplashscreenPageState extends State<SplashscreenPage> {
  final DataCacher _cacher = DataCacher.instance;

  Future<void> check() async {
    setState(() {
      refId = _cacher.refId;
      user = _cacher.m3uUser;
      sourceUrl = _cacher.source;
      playlistName = _cacher.playlistName;
      language = _cacher.language;
      file = _cacher.filePath;
      password = _cacher.password;
      userInfo = _cacher.userInfo;
      server = _cacher.serverInfo;
    });

    print("REF ID: $refId");
    print("USER: $user");
    print("SOURCE URL: $sourceUrl");
    print("PLAYLIST NAME: $playlistName");
    print("FILE: $file");
    print("XTREAM USER INFO: $userInfo");
    print("XTREAM SERVER INFO: $server");

    if (file != null || userInfo != null) {
      await Navigator.pushReplacementNamed(context, "/landing-page");
      return;
    }
    if (refId == null || user == null) {
      print("DIDI SUMULOD SA LOGIN");
      await Navigator.pushReplacementNamed(context, "/auth");
      return;
    } else {
      await Navigator.pushReplacement(
        context,
        PageTransition(
          child: const SourceManagementPage(),
          type: PageTransitionType.rightToLeft,
        ),
      );
    }
    return;
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await check();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: ColorPalette().gradient),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            const Expanded(child: LogoSVG()),
            Expanded(
              flex: 2,
              child: Center(
                child: Image.asset(
                  "assets/images/transsplash.gif",
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
