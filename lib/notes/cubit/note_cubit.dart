import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:note_app/models/note_model.dart';
import 'package:note_app/notes/cubit/notes_status.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit() : super(const NotesState());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _notesSub;

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
            try {
              final notes = snapshot.docs.map((doc) {
                final data = doc.data();
                return Note.fromMap(data, doc.id);
              }).toList();

              emit(state.copyWith(status: NotesStatus.success, notes: notes));
            } catch (e) {
              emit(
                state.copyWith(
                  status: NotesStatus.failure,
                  errorMessage: 'Failed to parse notes: $e',
                ),
              );
            }
          },
          onError: (e) {
            emit(
              state.copyWith(
                status: NotesStatus.failure,
                errorMessage: 'Firestore error: $e',
              ),
            );
          },
        );
  }

  void cancelSubscription() {
    _notesSub?.cancel();
    _notesSub = null;
  }

  Future<void> addNote(Note note) async {
    try {
      final data = note.toMap();
      if (note.noteId.isEmpty) {
        await _firestore.collection('notes').add(data);
      } else {
        await _firestore.collection('notes').doc(note.noteId).set(data);
      }
    } catch (e) {
      emit(
        state.copyWith(status: NotesStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _firestore.collection('notes').doc(noteId).delete();
    } catch (e) {
      emit(
        state.copyWith(status: NotesStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  // Grocery Item methods (typed with Note and GroceryItem)
  void startEditing(Note note) {
    emit(state.copyWith(editingNote: note));
  }

  void addGroceryItem(GroceryItem item) {
    final current = state.editingNote;
    if (current == null) return;
    final updatedItems = List<GroceryItem>.from(current.items)..add(item);
    final updatedNote = current.copyWith(items: updatedItems);
    emit(state.copyWith(editingNote: updatedNote));
  }

  void toggleItemBought(int index, bool value) {
    final current = state.editingNote;
    if (current == null) return;
    final updatedItems = List<GroceryItem>.from(current.items);
    final item = updatedItems[index];
    updatedItems[index] = item.copyWith(isBought: value);
    emit(state.copyWith(editingNote: current.copyWith(items: updatedItems)));
  }

  void updateItemPrice(int index, double price) {
    final current = state.editingNote;
    if (current == null) return;
    final updatedItems = List<GroceryItem>.from(current.items);
    final item = updatedItems[index];
    updatedItems[index] = item.copyWith(price: price);
    emit(state.copyWith(editingNote: current.copyWith(items: updatedItems)));
  }

double calculateTotal() {
    final current = state.editingNote;
    if (current == null) return 0;
    return current.items
        .where((i) => i.isBought)
        .fold(0.0, (sum, i) => sum + (i.price));
  }


  Future<void> fetchNoteById(String noteId, String uid) async {
    emit(state.copyWith(status: NotesStatus.loading));
    try {
      final doc = await _firestore.collection('notes').doc(noteId).get();
      if (doc.exists && doc.data()?['uid'] == uid) {
        final note = Note.fromMap(doc.data()!, doc.id);
        emit(state.copyWith(status: NotesStatus.success, editingNote: note));
      } else {
        emit(
          state.copyWith(
            status: NotesStatus.failure,
            errorMessage: 'Note not found or access denied.',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: NotesStatus.failure,
          errorMessage: 'Error fetching note: $e',
        ),
      );
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      await _firestore.collection('notes').doc(note.noteId).update({
        'items': note.items.map((e) => e.toMap()).toList(),
      });

      // Optional: emit updated note to keep UI synced
      emit(state.copyWith(editingNote: note));
    } catch (e) {
      emit(
        state.copyWith(
          status: NotesStatus.failure,
          errorMessage: 'Failed to update note: $e',
        ),
      );
    }
  }
}
