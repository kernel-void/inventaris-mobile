import '../core/api/api_client.dart';
import '../../models/category.dart';

class CategoryService {
  CategoryService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient.instance;

  final ApiClient _api;

  Future<List<Category>> all() async {
    final response = await _api.request('/categories');
    final data = response.data is Map<String, dynamic>
        ? (response.data as Map<String, dynamic>)['data']
        : null;
    if (data is! List) return [];
    return data
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Category> create(Map<String, dynamic> payload) async {
    final response = await _api.request('/categories', method: 'POST', data: payload);
    return _fromResponse(response);
  }

  Future<Category> update(int id, Map<String, dynamic> payload) async {
    final response =
        await _api.request('/categories/$id', method: 'PUT', data: payload);
    return _fromResponse(response);
  }

  Future<void> delete(int id) async {
    await _api.request('/categories/$id', method: 'DELETE');
  }

  Category _fromResponse(dynamic response) {
    final data = response.data is Map<String, dynamic>
        ? (response.data as Map<String, dynamic>)['data']
        : null;
    return Category.fromJson(data as Map<String, dynamic>);
  }
}
