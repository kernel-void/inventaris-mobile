import '../core/api/api_client.dart';
import '../../models/item.dart';

class ItemService {
  ItemService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient.instance;

  final ApiClient _api;

  /// Ambil daftar item dengan pagination. Mengembalikan (items, hasMore).
  Future<(List<Item>, bool)> all({
    String? search,
    int? categoryId,
    int? roomId,
    bool? lowStock,
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await _api.request('/items', queryParameters: {
      'search': ?search,
      'category_id': ?categoryId,
      'room_id': ?roomId,
      'low_stock': ?lowStock,
      'page': page,
      'per_page': perPage,
    });

    final body = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : const <String, dynamic>{};
    final items = (body['data'] as List? ?? [])
        .map((e) => Item.fromJson(e as Map<String, dynamic>))
        .toList();

    final meta = body['meta'] is Map<String, dynamic>
        ? body['meta'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final currentPage = meta['current_page'] as int? ?? page;
    final lastPage = meta['last_page'] as int? ?? currentPage;

    return (items, currentPage < lastPage);
  }

  Future<Item> show(int id) async {
    final response = await _api.request('/items/$id');
    final data = response.data is Map<String, dynamic>
        ? (response.data as Map<String, dynamic>)['data']
        : null;
    return Item.fromJson(data as Map<String, dynamic>);
  }

  Future<Item> create(Map<String, dynamic> payload) async {
    final response = await _api.request('/items', method: 'POST', data: payload);
    final data = response.data is Map<String, dynamic>
        ? (response.data as Map<String, dynamic>)['data']
        : null;
    return Item.fromJson(data as Map<String, dynamic>);
  }

  Future<Item> update(int id, Map<String, dynamic> payload) async {
    final response = await _api.request('/items/$id', method: 'PUT', data: payload);
    final data = response.data is Map<String, dynamic>
        ? (response.data as Map<String, dynamic>)['data']
        : null;
    return Item.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(int id) => _api.request('/items/$id', method: 'DELETE');
}
