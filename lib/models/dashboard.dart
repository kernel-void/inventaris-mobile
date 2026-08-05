import 'item.dart';

class DashboardStats {
  const DashboardStats({
    this.totalItems = 0,
    this.totalCategories = 0,
    this.totalRooms = 0,
    this.totalIncoming = 0,
    this.totalOutgoing = 0,
    this.lowStock = 0,
  });

  final int totalItems;
  final int totalCategories;
  final int totalRooms;
  final int totalIncoming;
  final int totalOutgoing;
  final int lowStock;

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
        totalItems: json['total_items'] as int? ?? 0,
        totalCategories: json['total_categories'] as int? ?? 0,
        totalRooms: json['total_rooms'] as int? ?? 0,
        totalIncoming: json['total_incoming'] as int? ?? 0,
        totalOutgoing: json['total_outgoing'] as int? ?? 0,
        lowStock: json['low_stock'] as int? ?? 0,
      );
}

class DashboardMonthly {
  const DashboardMonthly({
    this.labels = const [],
    this.incoming = const [],
    this.outgoing = const [],
  });

  final List<String> labels;
  final List<int> incoming;
  final List<int> outgoing;

  factory DashboardMonthly.fromJson(Map<String, dynamic> json) =>
      DashboardMonthly(
        labels: (json['labels'] as List?)?.map((e) => e.toString()).toList() ?? [],
        incoming:
            (json['incoming'] as List?)?.map((e) => (e as num).toInt()).toList() ??
                [],
        outgoing:
            (json['outgoing'] as List?)?.map((e) => (e as num).toInt()).toList() ??
                [],
      );
}

class DashboardData {
  const DashboardData({
    required this.stats,
    required this.monthly,
    this.lowStockItems = const [],
  });

  final DashboardStats stats;
  final DashboardMonthly monthly;
  final List<Item> lowStockItems;

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
        stats: DashboardStats.fromJson(json['stats'] as Map<String, dynamic>? ?? {}),
        monthly: DashboardMonthly.fromJson(
          json['monthly'] as Map<String, dynamic>? ?? {},
        ),
        lowStockItems: (json['low_stock_items'] as List?)
                ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
