import 'category.dart';
import 'room.dart';

class Item {
  const Item({
    required this.id,
    required this.code,
    required this.name,
    required this.stock,
    this.categoryId,
    this.roomId,
    this.category,
    this.room,
    this.brand,
    this.unit,
    this.acquisitionYear,
    this.condition,
    this.description,
  });

  final int id;
  final String code;
  final String name;
  final int stock;
  final int? categoryId;
  final int? roomId;
  final Category? category;
  final Room? room;
  final String? brand;
  final String? unit;
  final String? acquisitionYear;
  final String? condition;
  final String? description;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json['id'] as int,
        code: json['code'] as String? ?? '',
        name: json['name'] as String? ?? '',
        stock: json['stock'] as int? ?? 0,
        categoryId: json['category_id'] as int?,
        roomId: json['room_id'] as int?,
        category: json['category'] is Map<String, dynamic>
            ? Category.fromJson(json['category'] as Map<String, dynamic>)
            : null,
        room: json['room'] is Map<String, dynamic>
            ? Room.fromJson(json['room'] as Map<String, dynamic>)
            : null,
        brand: json['brand'] as String?,
        unit: json['unit'] as String?,
        acquisitionYear: json['acquisition_year']?.toString(),
        condition: json['condition'] as String?,
        description: json['description'] as String?,
      );

  bool get isLowStock => stock <= 5;

  Map<String, dynamic> toPayload() => {
        'name': name,
        'category_id': categoryId,
        'room_id': roomId,
        'brand': brand,
        'unit': unit,
        'acquisition_year': acquisitionYear,
        'condition': condition,
        'stock': stock,
        'description': description,
      };
}
