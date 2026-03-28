class UserModel {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? username;
  String? token;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.username,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      username: json['username']?.toString(),
      token: json['token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'username': username,
      'token': token,
    };
  }
}
