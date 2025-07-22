import 'package:cloud_firestore/cloud_firestore.dart';

enum NoteType { note, grocery, vegetable }

class GroceryItem {
  final String name;
  final String weight;
  final double price;
  final bool isBought;

  GroceryItem({
    required this.name,
    required this.weight,
    required this.price,
    required this.isBought,
  });

  factory GroceryItem.fromMap(Map<String, dynamic> map) {
    return GroceryItem(
      name: map['name'] ?? '',
      weight: map['weight'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      isBought: map['isBought'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'weight': weight,
      'price': price,
      'isBought': isBought,
    };
  }

  GroceryItem copyWith({
    String? name,
    String? weight,
    double? price,
    bool? isBought,
  }) {
    return GroceryItem(
      name: name ?? this.name,
      weight: weight ?? this.weight,
      price: price ?? this.price,
      isBought: isBought ?? this.isBought,
    );
  }

  @override
  String toString() {
    return 'GroceryItem(name: $name, weight: $weight, price: $price, isBought: $isBought)';
  }
}

class Note {
  final String noteId;
  final String uid;
  final String title;
  final String message;
  final DateTime createdAt;
  final NoteType type;
  final List<GroceryItem> items;

  Note({
    required this.noteId,
    required this.uid,
    required this.title,
    required this.message,
    required this.createdAt,
    this.type = NoteType.note,
    this.items = const [],
  });

  factory Note.fromMap(Map<String, dynamic> map, String id) {
    return Note(
      noteId: id,
      uid: map['uid'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: NoteType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'note'),
        orElse: () => NoteType.note,
      ),
      items:
          (map['items'] as List<dynamic>?)
              ?.map((e) => GroceryItem.fromMap(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'noteId': noteId,
      'uid': uid,
      'title': title,
      'message': message,
      'createdAt': createdAt,
      'type': type.name,
      'items': items.map((e) => e.toMap()).toList(),
    };
  }

  Note copyWith({
    String? noteId,
    String? uid,
    String? title,
    String? message,
    DateTime? createdAt,
    NoteType? type,
    List<GroceryItem>? items,
  }) {
    return Note(
      noteId: noteId ?? this.noteId,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      items: items ?? this.items,
    );
  }

  @override
  String toString() {
    return 'Note(noteId: $noteId, uid: $uid, title: $title, message: $message, createdAt: $createdAt, type: $type, items: $items)';
  }
}
