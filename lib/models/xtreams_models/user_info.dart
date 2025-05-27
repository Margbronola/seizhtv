class UserInfoModel {
  final String username;
  final String password;
  final String status;
  final String expDate;

  UserInfoModel({
    required this.expDate,
    required this.password,
    required this.status,
    required this.username,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      expDate: json['exp_date'],
      password: json['password'],
      status: json['status'],
      username: json['username'],
    );
  }
}
