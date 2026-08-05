class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.roles = const [],
    this.permissions = const [],
  });

  final int id;
  final String name;
  final String email;
  final String? avatar;
  final List<String> roles;
  final List<String> permissions;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        avatar: json['avatar'] as String?,
        roles: (json['roles'] as List?)?.map((e) => e.toString()).toList() ?? [],
        permissions:
            (json['permissions'] as List?)?.map((e) => e.toString()).toList() ?? [],
      );

  bool can(String permission) => permissions.contains(permission);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatar': avatar,
        'roles': roles,
        'permissions': permissions,
      };
}

class RoleOption {
  const RoleOption({required this.id, required this.name});

  final int id;
  final String name;

  factory RoleOption.fromJson(Map<String, dynamic> json) => RoleOption(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
      );
}
