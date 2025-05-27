import 'package:seizhtv/models/xtreams_models/xtream_series_season.dart';

import 'xtream_series_episode.dart';

class XtreamSeriesInfo {
  final List<SeasonsModel> season;
  final XtreamSeriesEpisodeModel episode;

  XtreamSeriesInfo({required this.episode, required this.season});

  factory XtreamSeriesInfo.fromJson(Map<String, dynamic> json) {
    return XtreamSeriesInfo(episode: json['episodes'], season: json['seasons']);
  }
}
