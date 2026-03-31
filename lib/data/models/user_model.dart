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

Future<Map<String, dynamic>> fakeLoginResponse(
  String phone,
  String password,
) async {
  await Future.delayed(const Duration(seconds: 1));

  if (phone == '0999999999' && password == '123456') {
    return {
      "success": true,
      "message": "Login successful",
      "data": {
        "user": {
          "id": "1",
          "name": "Ashin Thila Ouda",
          "email": "ashin@example.com",
          "phone": phone,
          "username": "ashin123",
        },
        "token": "fake_token_abc123xyz",
      },
    };
  }

  return {"success": false, "message": "Invalid phone or password"};
}
