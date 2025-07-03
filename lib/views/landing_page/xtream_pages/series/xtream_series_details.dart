// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:seizhtv/extension/classified_data.dart';
import 'package:seizhtv/extension/state.dart';
import 'package:seizhtv/models/xtreams_models/xtream_data.dart';
import 'package:seizhtv/models/xtreams_models/xtream_series_episode.dart';
import 'package:seizhtv/models/xtreams_models/xtream_series_season.dart';
import '../../../../data_containers/favorites.dart';
import '../../../../globals/data.dart';
import '../../../../globals/network.dart';
import '../../../../globals/network_image_viewer.dart';
import '../../../../globals/palette.dart';
import '../../../../globals/ui_additional.dart';
import '../../../../m3u/classified_data.dart';
import '../../../../m3u/m3u_entry.dart';
import '../../../../m3u/zm3u_handler.dart';
import '../../../../models/tvseries_details.dart';
import '../../../../models/xtreams_models/xtream_series_data.dart';
import '../../../../services/tv_series_api.dart';
import '../../../../services/xtream_api.dart';
import '../../../../viewmodel/seriesdetails.dart';
import '../../children/details.dart';
import 'xtream_series_episode.dart';
import 'xtream_series_info.dart';

class XtreamSeriesDetailsPage extends StatefulWidget {
  const XtreamSeriesDetailsPage({
    super.key,
    required this.data,
    required this.title,
    this.year,
  });
  final XtreamSeriesDataModel data;
  final String title;
  final String? year;

  @override
  State<XtreamSeriesDetailsPage> createState() =>
      _XtreamSeriesDetailsPageState();
}

class _XtreamSeriesDetailsPageState extends State<XtreamSeriesDetailsPage>
    with SingleTickerProviderStateMixin {
  static final SeriesDetailsViewModel _viewModel =
      SeriesDetailsViewModel.instance;
  static final Favorites _vm = Favorites.instance;
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  // late bool isFavorite = widget.data.isInFavorite("series");
  late TabController _tabController;
  // late int? chosenIndex = widget.data.data.length == 1 ? 0 : null;
  late ClassifiedData data;
  List<SeasonsModel>? seasons;
  List<EpisodesModel>? episodes;
  bool isloading = false;

  @override
  void initState() {
    fetchFav();
    print("SERIES ID: ${widget.data.seriesId}");

    XtreamApi()
        .getSeriesInfo(
          baseUrl: "${server!.serverProtocol}://${server!.url}:${server!.port}",
          username: userInfo!.username,
          password: userInfo!.password,
          seriesId: widget.data.seriesId,
        )
        ?.then((value) {
          setState(() {
            print("SERIES SEASON: $value");
            final List<dynamic> jsonList = value['seasons'];
            seasons = jsonList
                .map((json) => SeasonsModel.fromJson(json))
                .toList();
            final Map<String, dynamic> jsonList2 = value['episodes'];
            episodes = jsonList2.entries
                .map((e) => XtreamSeriesEpisodeModel.fromKeyVal(e))
                .expand((e) => e.episode)
                .toList();
          });
        });
    _tabController = TabController(vsync: this, length: 2);
    super.initState();
  }

  fetchFav() async {
    // await _handler
    //     .getDataFrom(type: CollectionType.favorites, refId: refId!)
    //     .then((value) {
    //       if (value != null) {
    //         _vm.populate(value);
    //       }
    //     });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Scaffold(
          backgroundColor: ColorPalette().card,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: appbar1(),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: widget.data.cover ?? "",
                    placeholder: (context, url) =>
                        UIAdditional().shimmerLoading(
                          ColorPalette().highlight,
                          200,
                          width: double.infinity,
                        ),
                    errorWidget: (context, url, error) => Image.asset(
                      widget.data.cover ?? "",
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.data.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 22,
                                height: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: size.width * .30,
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white.withOpacity(.7),
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: MaterialButton(
                              padding: EdgeInsets.zero,
                              onPressed: () async {
                                // if (!isFavorite) {
                                //   showDialog(
                                //     context: context,
                                //     builder: (BuildContext context) {
                                //       Future.delayed(
                                //         const Duration(seconds: 5),
                                //         () {
                                //           Navigator.of(context).pop(true);
                                //         },
                                //       );
                                //       return Dialog(
                                //         alignment: Alignment.topCenter,
                                //         shape: RoundedRectangleBorder(
                                //           borderRadius: BorderRadius.circular(10.0),
                                //         ),
                                //         child: Container(
                                //           height: 50,
                                //           padding: const EdgeInsets.symmetric(
                                //             vertical: 15,
                                //             horizontal: 20,
                                //           ),
                                //           child: Row(
                                //             mainAxisAlignment:
                                //                 MainAxisAlignment.spaceBetween,
                                //             children: [
                                //               Text(
                                //                 "Added_to_Favorites".tr(),
                                //                 style: const TextStyle(
                                //                   fontSize: 16,
                                //                 ),
                                //               ),
                                //               IconButton(
                                //                 padding: const EdgeInsets.all(0),
                                //                 onPressed: () {
                                //                   Navigator.of(context).pop();
                                //                 },
                                //                 icon: const Icon(
                                //                   Icons.close_rounded,
                                //                 ),
                                //               ),
                                //             ],
                                //           ),
                                //         ),
                                //       );
                                //     },
                                //   );
                                //   for (M3uEntry m3u in widget.data.data) {
                                //     await m3u.addToFavorites(refId!);
                                //   }
                                // } else {
                                //   for (M3uEntry m3u in widget.data.data) {
                                //     await m3u.removeFromFavorites(refId!);
                                //   }
                                // }
                                // await fetchFav();
                              },
                              color: Colors.transparent,
                              elevation: 0,
                              height: 40,
                              child: Center(
                                child:
                                    // !isFavorite
                                    //     ?
                                    Text(
                                      "Add_to_favorites".tr(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white.withOpacity(.7),
                                      ),
                                    ),
                                // : Text(
                                //     "Favorites".tr(),
                                //     textAlign: TextAlign.center,
                                //     style: TextStyle(
                                //       fontSize: 10,
                                //       fontWeight: FontWeight.w800,
                                //       color: Colors.white.withOpacity(.7),
                                //     ),
                                //   ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text("${widget.data.year}"),
                          const SizedBox(width: 15),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                            child: Text("${widget.data.rating}"),
                          ),
                          const SizedBox(width: 15),
                          SizedBox(
                            height: 25,
                            width: 30,
                            child: MaterialButton(
                              color: Colors.grey,
                              padding: const EdgeInsets.all(0),
                              onPressed: () {},
                              child: const Text(
                                "HD",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Text(
                        "Storyline".tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.data.plot ?? "",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 550,
                        child: Column(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey),
                                ),
                              ),
                              child: DefaultTabController(
                                length: 2,
                                child: TabBar(
                                  controller: _tabController,
                                  indicatorColor: ColorPalette().orange,
                                  indicatorWeight: 2,
                                  tabs: [
                                    Text(
                                      "Episodes".tr(),
                                      style: TextStyle(
                                        color: ColorPalette().white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "Info".tr(),
                                      style: TextStyle(
                                        color: ColorPalette().white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  XtreamSeriesEpisodePage(
                                    episode: episodes!,
                                    season: seasons!,
                                    seriesId: int.parse(
                                      "${widget.data.seriesId}",
                                    ),
                                  ),
                                  XtreamSeriesInfoPage(data: widget.data),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        isloading
            ? Container(
                color: ColorPalette().highlight.withOpacity(0.5),
                child: Center(
                  child: Image.asset(
                    "assets/images/transsplash.gif",
                    fit: BoxFit.fitWidth,
                  ),
                ),
              )
            : Container(),
      ],
    );
  }
}
