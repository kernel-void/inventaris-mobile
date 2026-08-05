import '../core/api/api_client.dart';
import '../../models/user.dart';

class UserListData {
  const UserListData({
    required this.users,
    required this.roles,
    this.total = 0,
    this.online = 0,
  });

  final List<User> users;
  final List<RoleOption> roles;
  final int total;
  final int online;
}

class UserService {
  UserService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient.instance;

  final ApiClient _api;

  /// Ambil daftar user + role tersedia + statistik.
  Future<UserListData> all() async {
    final response = await _api.request('/users');
    final body = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : const <String, dynamic>{};
    final stats = body['stats'] is Map<String, dynamic>
        ? body['stats'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return UserListData(
      users: (body['data'] as List? ?? [])
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      roles: (body['roles'] as List? ?? [])
          .map((e) => RoleOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: stats['total'] as int? ?? 0,
      online: stats['online'] as int? ?? 0,
    );
  }

  Future<User> create(Map<String, dynamic> payload) async {
    final response = await _api.request('/users', method: 'POST', data: payload);
    final data = response.data is Map<String, dynamic>
        ? (response.data as Map<String, dynamic>)['data']
        : null;
    return User.fromJson(data as Map<String, dynamic>);
  }

  Future<User> update(int id, Map<String, dynamic> payload) async {
    final response = await _api.request('/users/$id', method: 'PUT', data: payload);
    final data = response.data is Map<String, dynamic>
        ? (response.data as Map<String, dynamic>)['data']
        : null;
    return User.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(int id) => _api.request('/users/$id', method: 'DELETE');
}
