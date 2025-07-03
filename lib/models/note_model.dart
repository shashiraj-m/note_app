// note_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String noteId;
  final String uid;
  final String title;
  final String message;
  final DateTime createdAt;

  Note({
    required this.noteId,
    required this.uid,
    required this.title,
    required this.message,
    required this.createdAt,
  });

  factory Note.fromMap(Map<String, dynamic> map, String id) {
    return Note(
      noteId: id,
      uid: map['uid'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'noteId': noteId,
      'uid': uid,
      'title': title,
      'message': message,
      'createdAt': createdAt,
    };
  }
}
