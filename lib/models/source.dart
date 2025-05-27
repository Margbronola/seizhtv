class M3uSource {
  final String source;
  final bool isFile;
  final String name;
  final bool? isOnLogin;

  const M3uSource({
    required this.source,
    required this.isFile,
    required this.name,
    required this.isOnLogin,
  });

  factory M3uSource.fromFirestore(Map<String, dynamic> json) => M3uSource(
    source: json['source'],
    isFile: json['is_file'],
    name: json['name'],
    isOnLogin: json['is_on_login'],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "is_file": isFile,
    "source": source,
    "is_on_login": isOnLogin,
  };

  @override
  String toString() => "${toJson()}";
}
