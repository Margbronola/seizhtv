class SeasonsModel {
  final int id;
  final int? episodeCount;
  final int? seasonNumber;

  SeasonsModel({
    required this.episodeCount,
    required this.id,
    required this.seasonNumber,
  });

  factory SeasonsModel.fromJson(Map<String, dynamic> json) {
    return SeasonsModel(
      episodeCount: json['episode_count'],
      id: json['id'],
      seasonNumber: json['season_number'],
    );
  }
}
