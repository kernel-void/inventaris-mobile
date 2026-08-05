import '../core/api/api_client.dart';
import '../../models/room.dart';

class RoomService {
  RoomService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient.instance;

  final ApiClient _api;

  Future<List<Room>> all() async {
    final response = await _api.request('/rooms');
    final data = response.data is Map<String, dynamic>
        ? (response.data as Map<String, dynamic>)['data']
        : null;
    if (data is! List) return [];
    return data.map((e) => Room.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Room> create(Map<String, dynamic> payload) async {
    final response = await _api.request('/rooms', method: 'POST', data: payload);
    return _fromResponse(response);
  }

  Future<Room> update(int id, Map<String, dynamic> payload) async {
    final response = await _api.request('/rooms/$id', method: 'PUT', data: payload);
    return _fromResponse(response);
  }

  Future<void> delete(int id) async {
    await _api.request('/rooms/$id', method: 'DELETE');
  }

  Room _fromResponse(dynamic response) {
    final data = response.data is Map<String, dynamic>
        ? (response.data as Map<String, dynamic>)['data']
        : null;
    return Room.fromJson(data as Map<String, dynamic>);
  }
}
