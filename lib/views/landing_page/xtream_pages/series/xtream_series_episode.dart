// ignore_for_file: avoid_print, deprecated_member_use, unused_local_variable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:seizhtv/models/xtreams_models/xtream_series_episode.dart';
import 'package:seizhtv/models/xtreams_models/xtream_series_season.dart';
import '../../../../data_containers/favorites.dart';
import '../../../../globals/data.dart';
import '../../../../globals/network_image_viewer.dart';
import '../../../../globals/palette.dart';
import '../../../../globals/video_loader.dart';
import '../../../../m3u/zm3u_handler.dart';

class XtreamSeriesEpisodePage extends StatefulWidget {
  XtreamSeriesEpisodePage({
    super.key,
    required this.episode,
    required this.season,
    required this.seriesId,
  });
  final int seriesId;
  final List<EpisodesModel> episode;
  final List<SeasonsModel> season;

  @override
  State<XtreamSeriesEpisodePage> createState() =>
      _XtreamSeriesEpisodePageState();
}

class _XtreamSeriesEpisodePageState extends State<XtreamSeriesEpisodePage> {
  // late bool isFavorite = widget.data.isInFavorite("series");
  static final Favorites _vm = Favorites.instance;
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  // late int? chosenIndex = widget.data.data.length == 1 ? 0 : null;
  String dropdownvalue = "1";
  List<String> seasonsNum = [];
  List<EpisodesModel> epi = [];
  int episodesCount = 0;

  fetchEpisode() {
    List<String> seasonNum = [];
    for (EpisodesModel e in widget.episode) {
      seasonNum.add("${e.season}");
      seasonsNum = seasonNum.toSet().toList();
      if (e.season == int.parse(dropdownvalue)) {
        epi.add(e);
      }
    }
  }

  fetchFav() async {
    await _handler
        .getDataFrom(type: CollectionType.favorites, refId: refId!)
        .then((value) {
          if (value != null) {
            _vm.populate(value);
          }
        });
  }

  @override
  void initState() {
    fetchEpisode();
    fetchFav();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          elevation: 0,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text:
                              "${widget.season.length} Season${widget.season.length > 1 ? "s" : ""} - ${widget.episode.length} ",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(.5),
                          ),
                          children: [
                            TextSpan(
                              text:
                                  "Episode${widget.episode.length > 1 ? "s" : ""}"
                                      .tr(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    widget.season.length == 1
                        ? Container(width: 150)
                        : Container(
                            height: 50,
                            width: 130,
                            margin: const EdgeInsets.only(left: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(
                              color: ColorPalette().highlight,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: DropdownButton(
                              elevation: 0,
                              isExpanded: true,
                              underline: Container(),
                              items: seasonsNum.map((value) {
                                return DropdownMenuItem(
                                  value: value,
                                  child: Text("Season $value"),
                                );
                              }).toList(),
                              value: dropdownvalue == ""
                                  ? seasonsNum[0]
                                  : dropdownvalue,
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: "Poppins",
                              ),
                              icon: const Icon(Icons.keyboard_arrow_down),
                              onChanged: (value) {
                                setState(() {
                                  dropdownvalue = value!;
                                  print("DROPDOWN VALUE: $dropdownvalue");
                                  epi.clear();
                                  for (EpisodesModel e in widget.episode) {
                                    print(
                                      "EPIS: ${e.season} == $dropdownvalue = ${e.season == int.parse(dropdownvalue)}",
                                    );
                                    if (e.season == int.parse(dropdownvalue)) {
                                      print("EPIS: ${e.title} - ${e.season}");
                                      epi.add(e);
                                    }
                                  }
                                });
                              },
                            ),
                          ),
                  ],
                ),
                const SizedBox(height: 30),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: epi.length,
                  itemBuilder: (_, i) {
                    return ListTile(
                      onTap: () async {
                        // epi.addToHistory(refId!);
                        await VideoLoader().loadVideo(
                          context,
                          link:
                              "${widget.seriesId}.${epi[i].season}.${epi[i].episodeNum}",
                          movieExtension: epi[i].containerExtension,
                          title: epi[i].title,
                          type: "series",
                          image: epi[i].info?.movieImage,
                          fromXtream: true,
                        );
                      },
                      contentPadding: EdgeInsets.zero,
                      // trailing: FavoriteIconButton(
                      //   onPressedCallback: (bool f) async {
                      //     if (f) {
                      //       await e.addToFavorites(refId!);
                      //     } else {
                      //       await e.removeFromFavorites(refId!);
                      //     }
                      //     await fetchFav();
                      //   },
                      //   initValue: e.existsInFavorites("series"),
                      //   iconSize: 20,
                      // ),
                      leading: SizedBox(
                        width: 85,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: NetworkImageViewer(
                            url: epi[i].info?.movieImage,
                            title: "false",
                            height: 60,
                            width: 85,
                            color: ColorPalette().highlight,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                      title: Text(epi[i].title),
                    );
                  },
                  separatorBuilder: (_, i) =>
                      Divider(color: Colors.white.withOpacity(.3)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
