import 'item.dart';

class IncomingItem {
  const IncomingItem({
    required this.id,
    required this.transactionNumber,
    required this.date,
    required this.quantity,
    this.item,
    this.description,
    this.createdBy,
  });

  final int id;
  final String transactionNumber;
  final String date;
  final int quantity;
  final Item? item;
  final String? description;
  final String? createdBy;

  factory IncomingItem.fromJson(Map<String, dynamic> json) => IncomingItem(
        id: json['id'] as int,
        transactionNumber: json['transaction_number'] as String? ?? '',
        date: json['date'] as String? ?? '',
        quantity: json['quantity'] as int? ?? 0,
        item: json['item'] is Map<String, dynamic>
            ? Item.fromJson(json['item'] as Map<String, dynamic>)
            : null,
        description: json['description'] as String?,
        createdBy: json['created_by'] as String?,
      );
}
