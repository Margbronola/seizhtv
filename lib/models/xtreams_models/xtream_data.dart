class XtreamDataModel {
  final int num;
  final String? name;
  final String? type;
  final int? streamId;
  final String? icon;
  final String? categoryId;

  XtreamDataModel({
    required this.icon,
    required this.name,
    required this.num,
    required this.streamId,
    required this.type,
    required this.categoryId,
  });

  factory XtreamDataModel.fromJson(Map<String, dynamic> json) {
    return XtreamDataModel(
      icon: json['stream_icon'],
      name: json['name'],
      num: json['num'],
      streamId: json['stream_id'],
      type: json['stream_type'],
      categoryId: json['category_id'],
    );
  }
}
