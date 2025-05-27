// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print, must_be_immutable

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' as cup;
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/views/landing_page/xtream_pages/xtream_live.dart';
import 'package:seizhtv/views/landing_page/xtream_pages/xtream_movie.dart';
import '../../data_containers/loaded_m3u_data.dart';
import '../../globals/bottom_bar.dart';
import '../../globals/data.dart';
import '../../globals/data_cacher.dart';
import '../../globals/palette.dart';
import '../../m3u/categorized_m3u_data.dart';
import '../../m3u/zm3u_handler.dart';
import '../../services/movie_api.dart';
import '../../services/tv_series_api.dart';
import '../../services/xtream_api.dart';
import 'children/favorite.dart';
import 'children/home.dart';
import 'children/live.dart';
import 'children/movie.dart';
import 'children/series.dart';
import 'firestore_listener.dart';
import 'source_management.dart';
import 'xtream_pages/xtream_series.dart';

class MainLandingPage extends StatefulWidget {
  MainLandingPage({super.key, this.isXtreamCode = false});
  final bool isXtreamCode;

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
    userInfo == null ? const LivePage() : XtreamLivePage(),
    userInfo == null ? const MoviePage() : XtreamMoviePage(),
    userInfo == null ? const SeriesPage() : XtreamSeriesPage(),
    const FavoritePage(),
  ];

  fetchxtream() async {
    await XtreamApi()
        .getLiveStream(
          baseUrl: "${server!.serverProtocol}://${server!.url}:${server!.port}",
          username: userInfo!.username,
          password: userInfo!.password,
        )
        .then((value) {
          if (value!.isNotEmpty) {
            setState(() {
              liveXtreamData = value;
            });
          }
        });

    await XtreamApi()
        .getMovieStream(
          baseUrl: "${server!.serverProtocol}://${server!.url}:${server!.port}",
          username: userInfo!.username,
          password: userInfo!.password,
        )
        .then((value) {
          setState(() {
            movieXtreamData = value!;
          });
        });

    await XtreamApi()
        .getSeriesStream(
          baseUrl: "${server!.serverProtocol}://${server!.url}:${server!.port}",
          username: userInfo!.username,
          password: userInfo!.password,
        )
        .then((value) {
          setState(() {
            seriesXtreamData = value!;
          });
        });

    await XtreamApi()
        .getLiveCategoryStream(
          baseUrl: "${server!.serverProtocol}://${server!.url}:${server!.port}",
          username: userInfo!.username,
          password: userInfo!.password,
        )
        .then((value) {
          setState(() {
            xtreamLiveCategory = value!;
          });
        });

    await XtreamApi()
        .getMovieCategoryStream(
          baseUrl: "${server!.serverProtocol}://${server!.url}:${server!.port}",
          username: userInfo!.username,
          password: userInfo!.password,
        )
        .then((value) {
          setState(() {
            xtreamMovieCategory = value!;
          });
        });
  }

  Future<void> initPlatform() async {
    print("RFID IN INIT PLATFORM LANDING PAGE: $refId");
    String? file = _cacher.filePath;
    refId = _cacher.refId;
    if (mounted) setState(() {});
    print("FILEEEE: $file");
    if (file == null) {
      await Navigator.pushReplacement(
        context,
        PageTransition(
          child: const SourceManagementPage(),
          type: PageTransitionType.rightToLeft,
        ),
      );
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
      file == null && widget.isXtreamCode == true
          ? fetchxtream()
          : initPlatform();
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
