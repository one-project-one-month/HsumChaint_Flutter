class UserModel {
  final String id, name, roleName;
  final String? email, phone, username, contactPhoneNumber, refreshToken;
  final int roleId;
  final List<String> permissions;
  String? token;
  UserModel({
    required this.id,
    required this.name,
    this.roleName = '',
    this.email,
    this.phone,
    this.username,
    this.contactPhoneNumber,
    this.refreshToken,
    this.roleId = 3,
    this.permissions = const [],
    this.token,
  });
  bool get isMonk => roleId == 2;
  bool get isDonor => roleId == 3;
  bool can(String permission) => permissions.contains(permission);
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: (json['id'] ?? json['ID'] ?? '').toString(),
    name: (json['name'] ?? '').toString(),
    roleName: (json['roleName'] ?? '').toString(),
    email: json['email'],
    phone: json['phoneNumber'] ?? json['phone'],
    contactPhoneNumber: json['contactPhoneNumber'],
    roleId: (json['roleId'] as num?)?.toInt() ?? 0,
    permissions: List<String>.from(json['permissions'] ?? []),
    token: json['accessToken'] ?? json['token'],
    refreshToken: json['refreshToken'],
  );
  Map<String, dynamic> toJson() => {
    'id': int.tryParse(id) ?? id,
    'name': name,
    'email': email,
    'phoneNumber': phone,
    'contactPhoneNumber': contactPhoneNumber,
    'roleId': roleId,
    'roleName': roleName,
    'permissions': permissions,
    'accessToken': token,
    'refreshToken': refreshToken,
  };
}
