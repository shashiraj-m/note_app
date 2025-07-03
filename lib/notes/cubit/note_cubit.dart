import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:note_app/models/note_model.dart';
import 'package:note_app/notes/cubit/notes_status.dart';


class NotesCubit extends Cubit<NotesState> {
  NotesCubit() : super(const NotesState());

  final _firestore = FirebaseFirestore.instance;
  StreamSubscription? _notesSub;

  void listenToNotes(String uid) {
    emit(state.copyWith(status: NotesStatus.loading));
    _notesSub?.cancel();

    _notesSub = _firestore
        .collection('notes')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            final notes = snapshot.docs
                .map((doc) => Note.fromMap(doc.data(), doc.id))
                .toList();
            emit(state.copyWith(status: NotesStatus.success, notes: notes));
          },
          onError: (e) {
            emit(
              state.copyWith(
                status: NotesStatus.failure,
                errorMessage: e.toString(),
              ),
            );
            print('Firestore error: $e');
          },
        );
        
  }

void cancelSubscription() {
    _notesSub?.cancel();
    _notesSub = null;
  }

  Future<void> addNote(String uid, String title, String message) async {
    try {
      final docRef = _firestore.collection('notes').doc();
      final note = Note(
        noteId: docRef.id,
        uid: uid,
        title: title,
        message: message,
        createdAt: DateTime.now(),
      );
      await docRef.set(note.toMap());
    } catch (e) {
      print('Add note failed: $e');
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _firestore.collection('notes').doc(noteId).delete();
    } catch (e) {
      print('Delete note failed: $e');
    }
  }

  @override
  Future<void> close() {
    _notesSub?.cancel();
    cancelSubscription();
    return super.close();
  }
}
