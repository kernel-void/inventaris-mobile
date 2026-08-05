import '../core/api/api_client.dart';
import '../../models/dashboard.dart';

class DashboardService {
  DashboardService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient.instance;

  final ApiClient _api;

  Future<DashboardData> fetch() async {
    final response = await _api.request('/dashboard');
    final data = response.data is Map<String, dynamic>
        ? (response.data as Map<String, dynamic>)['data']
        : null;
    return DashboardData.fromJson(data as Map<String, dynamic>? ?? {});
  }
}
