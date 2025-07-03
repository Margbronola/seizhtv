class XtreamSeriesEpisodeModel {
  final String? key;
  final List<EpisodesModel> episode;

  XtreamSeriesEpisodeModel({required this.episode, required this.key});

  factory XtreamSeriesEpisodeModel.fromKeyVal(MapEntry keymap) {
    final List episodes = keymap.value;

    return XtreamSeriesEpisodeModel(
      episode: episodes.map((e) => EpisodesModel.fromJson(e)).toList(),
      key: keymap.key,
    );
  }

  factory XtreamSeriesEpisodeModel.fromJson(Map<String, dynamic> json) {
    List epi = [];

    if (json['episodes'] != null) {
      final dynamic epiVal = json['episodes'];
      if (epiVal.runtimeType is List) {
        epi = epiVal;
      } else {
        epi.add(epiVal);
      }
    }
    return XtreamSeriesEpisodeModel(
      episode: epi.map((e) => EpisodesModel.fromJson(e)).toList(),
      key: json['key'],
    );
  }
}

class EpisodesModel {
  final String id;
  final String title;
  final String? containerExtension;
  final Info? info;
  final int season;
  final String? episodeNum;

  EpisodesModel({
    required this.containerExtension,
    required this.id,
    required this.title,
    required this.info,
    required this.season,
    required this.episodeNum,
  });

  factory EpisodesModel.fromJson(Map<String, dynamic> json) {
    return EpisodesModel(
      containerExtension: json['container_extension'],
      id: json['id'],
      title: json['title'],
      info: Info.fromJson(json['info']),
      season: json['season'],
      episodeNum: json['episode_num'].toString(),
    );
  }
}

class Info {
  final String? tmdbId;
  final String? movieImage;

  Info({required this.movieImage, required this.tmdbId});

  factory Info.fromJson(Map<String, dynamic> json) {
    return Info(
      movieImage: json['movie_image'],
      tmdbId: json['tmdb_id'].toString(),
    );
  }
}
