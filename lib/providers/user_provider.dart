import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../models/user.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  UserProvider({UserService? userService})
      : _userService = userService ?? UserService();

  final UserService _userService;

  List<User> _users = [];
  List<RoleOption> _roles = [];
  int _total = 0;
  int _online = 0;
  bool _loading = false;
  String? _error;

  List<User> get users => _users;
  List<RoleOption> get roles => _roles;
  int get total => _total;
  int get online => _online;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadUsers() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _userService.all();
      _users = data.users;
      _roles = data.roles;
      _total = data.total;
      _online = data.online;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<User> createUser(Map<String, dynamic> payload) async {
    final user = await _userService.create(payload);
    await loadUsers();
    return user;
  }

  Future<User> updateUser(int id, Map<String, dynamic> payload) async {
    final user = await _userService.update(id, payload);
    await loadUsers();
    return user;
  }

  Future<void> deleteUser(int id) async {
    await _userService.delete(id);
    await loadUsers();
  }
}
