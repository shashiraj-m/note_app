import 'package:equatable/equatable.dart';
import 'package:note_app/models/note_model.dart';

enum NotesStatus { initial, loading, success, failure }

class NotesState extends Equatable {
  final NotesStatus status;
  final List<Note> notes;
  final String? errorMessage;

  const NotesState({
    this.status = NotesStatus.initial,
    this.notes = const [],
    this.errorMessage,
  });

  NotesState copyWith({
    NotesStatus? status,
    List<Note>? notes,
    String? errorMessage,
  }) {
    return NotesState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notes, errorMessage];
}
