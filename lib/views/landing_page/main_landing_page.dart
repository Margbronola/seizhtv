// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' as cup;

import '../../data_containers/loaded_m3u_data.dart';
import '../../globals/bottom_bar.dart';
import '../../globals/data.dart';
import '../../globals/data_cacher.dart';
import '../../globals/palette.dart';
import '../../m3u/categorized_m3u_data.dart';
import '../../m3u/zm3u_handler.dart';
import '../../services/movie_api.dart';
import '../../services/tv_series_api.dart';
import 'children/favorite.dart';
import 'children/home.dart';
import 'children/live.dart';
import 'children/movie.dart';
import 'children/series.dart';
import 'firestore_listener.dart';

class MainLandingPage extends StatefulWidget {
  const MainLandingPage({super.key});

  @override
  State<MainLandingPage> createState() => _MainLandingPageState();
}

class _MainLandingPageState extends State<MainLandingPage> {
  final GlobalKey<ZNavbarState> _kNavState = GlobalKey<ZNavbarState>();
  late final PageController controller;
  final FirestoreListener _firestoreListener = FirestoreListener.instance;
  final DataCacher _cacher = DataCacher.instance;
  final ZM3UHandler _handler = ZM3UHandler.instance;
  final LoadedM3uData _vm = LoadedM3uData.instance;

  final List<ZTab> tabs = [
    ZTabImage(
      text: "Home".tr(),
      path: "assets/icons/home.svg",
      imgType: ZImageType.svgAsset,
    ),
    ZTabIcon(text: "Live_Tv".tr(), icon: const Icon(cup.CupertinoIcons.tv)),
    ZTabImage(
      text: "Movies".tr(),
      path: "assets/icons/movies.svg",
      imgType: ZImageType.svgAsset,
    ),
    ZTabIcon(text: "Series".tr(), icon: const Icon(cup.CupertinoIcons.film)),
    ZTabImage(
      text: "favorites".tr(),
      path: "assets/icons/favourites.svg",
      imgType: ZImageType.svgAsset,
    ),
  ];

  late final List<Widget> content = [
    HomePage(
      onPagePressed: (int page) async {
        _kNavState.currentState!.updateIndex(page);
        await controller.animateToPage(
          page,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
    ),
    const LivePage(),
    const MoviePage(),
    const SeriesPage(),
    const FavoritePage(),
  ];

  Future<void> initPlatform() async {
    print("RFID IN INIT PLATFORM LANDING PAGE: $refId");
    String? file = _cacher.filePath;
    refId = _cacher.refId;
    if (mounted) setState(() {});
    print("FILEEEE: $file");
    if (file == null) {
      await Navigator.pushReplacementNamed(context, "/auth");
      await _cacher.clearData();
      return;
    }
    try {
      final CategorizedM3UData? value = await runExpensiveOperation(File(file));
      print("VALUEEEEE: $value");
      if (value == null) {
        await Navigator.pushReplacementNamed(context, "/auth");
        await _cacher.clearData();
      } else {
        _vm.populate(value);
      }
    } catch (e) {
      // handle error
      await Navigator.pushReplacementNamed(context, "/auth");
      await _cacher.clearData();
      return;
    }
  }

  Future<CategorizedM3UData?> runExpensiveOperation(File file) async {
    return await compute(_handler.getData, file);
  }

  @override
  void initState() {
    init();
    controller = PageController();
    refId = _cacher.refId;
    print("RFID IN INIT STATE LANDING PAGE: $refId");
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initPlatform();
    });
    _firestoreListener.listen();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  init() async {
    await MovieAPI().topRatedMovie();
    await TVSeriesAPI().topRatedTVShow();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette().card,
      body: PageView.builder(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (_, i) => content[i],
      ),
      bottomNavigationBar: cup.Container(
        color: ColorPalette().highlight,
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 5),
          child: ZNavbar(
            key: _kNavState,
            indicatorColor: ColorPalette().orange,
            backgroundColor: ColorPalette().highlight,
            activeColor: ColorPalette().white,
            indicatorSize: 3,
            indexCallback: (int i) {
              controller.animateToPage(
                i,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            inactiveColor: ColorPalette().white.withOpacity(0.5),
            tabs: tabs,
          ),
        ),
      ),
    );
  }
}
