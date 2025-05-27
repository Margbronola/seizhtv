class ServerInfoModel {
  final String url;
  final String port;
  final String serverProtocol;

  ServerInfoModel({
    required this.url,
    required this.port,
    required this.serverProtocol,
  });

  factory ServerInfoModel.fromJson(Map<String, dynamic> json) {
    return ServerInfoModel(
      url: json['url'],
      port: json['port'],
      serverProtocol: json['server_protocol'],
    );
  }
}
