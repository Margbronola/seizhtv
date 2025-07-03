class SeasonsModel {
  final int? id;
  final String? episodeCount;
  final int? seasonNumber;

  SeasonsModel({
    required this.episodeCount,
    required this.id,
    required this.seasonNumber,
  });

  factory SeasonsModel.fromJson(Map<String, dynamic> json) {
    return SeasonsModel(
      episodeCount: json['episode_count'].toString(),
      id: json['id'],
      seasonNumber: json['season_number'],
    );
  }
}
