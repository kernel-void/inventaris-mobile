import 'item.dart';

class OutgoingItem {
  const OutgoingItem({
    required this.id,
    required this.transactionNumber,
    required this.date,
    required this.quantity,
    this.item,
    this.destination,
    this.description,
    this.createdBy,
  });

  final int id;
  final String transactionNumber;
  final String date;
  final int quantity;
  final Item? item;
  final String? destination;
  final String? description;
  final String? createdBy;

  factory OutgoingItem.fromJson(Map<String, dynamic> json) => OutgoingItem(
        id: json['id'] as int,
        transactionNumber: json['transaction_number'] as String? ?? '',
        date: json['date'] as String? ?? '',
        quantity: json['quantity'] as int? ?? 0,
        item: json['item'] is Map<String, dynamic>
            ? Item.fromJson(json['item'] as Map<String, dynamic>)
            : null,
        destination: json['destination'] as String?,
        description: json['description'] as String?,
        createdBy: json['created_by'] as String?,
      );
}
