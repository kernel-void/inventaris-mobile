import '../core/api/api_client.dart';
import '../../models/incoming_item.dart';
import '../../models/outgoing_item.dart';

class TransactionService {
  TransactionService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient.instance;

  final ApiClient _api;

  Future<(List<IncomingItem>, bool)> incoming({
    String? search,
    String? from,
    String? to,
    int? itemId,
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await _api.request('/incoming-items', queryParameters: {
      'search': ?search,
      'from': ?from,
      'to': ?to,
      'item_id': ?itemId,
      'page': page,
      'per_page': perPage,
    });
    final body = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : const <String, dynamic>{};
    final items = (body['data'] as List? ?? [])
        .map((e) => IncomingItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return (items, _hasMore(body, page));
  }

  Future<(List<OutgoingItem>, bool)> outgoing({
    String? search,
    String? from,
    String? to,
    int? itemId,
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await _api.request('/outgoing-items', queryParameters: {
      'search': ?search,
      'from': ?from,
      'to': ?to,
      'item_id': ?itemId,
      'page': page,
      'per_page': perPage,
    });
    final body = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : const <String, dynamic>{};
    final items = (body['data'] as List? ?? [])
        .map((e) => OutgoingItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return (items, _hasMore(body, page));
  }

  Future<IncomingItem> storeIncoming({
    required int itemId,
    required String date,
    required int quantity,
    String? description,
  }) async {
    final response = await _api.request('/incoming-items', method: 'POST', data: {
      'item_id': itemId,
      'date': date,
      'quantity': quantity,
      'description': description,
    });
    final data = response.data is Map<String, dynamic>
        ? (response.data as Map<String, dynamic>)['data']
        : null;
    return IncomingItem.fromJson(data as Map<String, dynamic>);
  }

  Future<OutgoingItem> storeOutgoing({
    required int itemId,
    required String date,
    required int quantity,
    String? destination,
    String? description,
  }) async {
    final response = await _api.request('/outgoing-items', method: 'POST', data: {
      'item_id': itemId,
      'date': date,
      'quantity': quantity,
      'destination': destination,
      'description': description,
    });
    final data = response.data is Map<String, dynamic>
        ? (response.data as Map<String, dynamic>)['data']
        : null;
    return OutgoingItem.fromJson(data as Map<String, dynamic>);
  }

  bool _hasMore(Map<String, dynamic> body, int page) {
    final meta = body['meta'] is Map<String, dynamic>
        ? body['meta'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final currentPage = meta['current_page'] as int? ?? page;
    final lastPage = meta['last_page'] as int? ?? currentPage;
    return currentPage < lastPage;
  }
}
