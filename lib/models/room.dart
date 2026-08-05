class Room {
  const Room({
    required this.id,
    required this.name,
    this.location,
    this.pic,
  });

  final int id;
  final String name;
  final String? location;
  final String? pic;

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        location: json['location'] as String?,
        pic: json['pic'] as String?,
      );
}
