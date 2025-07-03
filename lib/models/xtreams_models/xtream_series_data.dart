class XtreamSeriesDataModel {
  final int num;
  final String title;
  final String? type;
  final int? seriesId;
  final String? cover;
  final String? plot;
  final String? cast;
  final String? director;
  final String? genre;
  final String? releaseDate;
  final String? youtubeTrailer;
  final String? year;
  final String? categoryId;
  final String? backdropPath;
  final String? rating;

  XtreamSeriesDataModel({
    required this.cover,
    required this.title,
    required this.num,
    required this.seriesId,
    required this.type,
    required this.cast,
    required this.director,
    required this.genre,
    required this.plot,
    required this.releaseDate,
    required this.youtubeTrailer,
    required this.year,
    required this.categoryId,
    required this.backdropPath,
    required this.rating,
  });

  factory XtreamSeriesDataModel.fromJson(Map<String, dynamic> json) {
    return XtreamSeriesDataModel(
      cover: json['cover'],
      title: json['name'],
      num: json['num'],
      seriesId: json['series_id'],
      type: json['stream_type'],
      year: json['year'],
      plot: json['plot'],
      cast: json['cast'],
      director: json['director'],
      genre: json['genre'],
      releaseDate: json['releaseDate'],
      youtubeTrailer: json['youtube_trailer'],
      categoryId: json['category_id'],
      backdropPath: json['backdrop_path'[0]],
      rating: json['rating'],
    );
  }
}
