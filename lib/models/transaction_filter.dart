class TransactionFilter {
  const TransactionFilter({this.search, this.from, this.to, this.itemId});

  final String? search;
  final String? from;
  final String? to;
  final int? itemId;

  bool get isEmpty =>
      search == null && from == null && to == null && itemId == null;

  int get activeCount =>
      [search, from, to, itemId].where((v) => v != null).length;

  TransactionFilter copyWith({
    String? search,
    String? from,
    String? to,
    int? itemId,
  }) {
    return TransactionFilter(
      search: search ?? this.search,
      from: from ?? this.from,
      to: to ?? this.to,
      itemId: itemId ?? this.itemId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionFilter &&
        other.search == search &&
        other.from == from &&
        other.to == to &&
        other.itemId == itemId;
  }

  @override
  int get hashCode => Object.hash(search, from, to, itemId);
}
