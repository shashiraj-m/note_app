import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/models/note_model.dart';
import 'package:note_app/notes/cubit/note_cubit.dart';

class NoteInputDialog extends StatefulWidget {
  const NoteInputDialog({super.key});

  @override
  State<NoteInputDialog> createState() => _NoteInputDialogState();
}

class _NoteInputDialogState extends State<NoteInputDialog> {
  NoteType selectedType = NoteType.note;

  final titleController = TextEditingController();
  final messageController = TextEditingController();

  List<GroceryItem> items = [];

  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.price);

  void addItem() {
    setState(() {
      items.add(GroceryItem(name: '', weight: '', price: 0.0, isBought: false));
    });
  }

  void updateItem(int index, GroceryItem newItem) {
    setState(() {
      items[index] = newItem;
    });
  }

  void removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void saveNote() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final docRef = FirebaseFirestore.instance.collection('notes').doc();

    final noteId = docRef.id;

    final note = Note(
      noteId: noteId,
      uid: uid.toString(),
      title: titleController.text.trim(),
      message: selectedType == NoteType.note
          ? messageController.text.trim()
          : '',
      createdAt: DateTime.now(),
      type: selectedType,
      items: selectedType == NoteType.note ? [] : items,
    );

    context.read<NotesCubit>().addNote(note);
    Navigator.pop(context);
  }

  Widget buildGroceryInputList() {
    return Column(
      children: [
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  initialValue: item.name,
                  onChanged: (val) {
                    updateItem(index, item.copyWith(name: val));
                  },
                  decoration: const InputDecoration(labelText: 'Item'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextFormField(
                  initialValue: item.weight.toString(),

                  onChanged: (val) {
                    updateItem(index, item.copyWith(weight: val));
                  },
                  decoration: const InputDecoration(labelText: 'Weight'),
                ),
              ),

              IconButton(
                icon: const Icon(Icons.delete, color: Color(0xFFE53935)),
                onPressed: () => removeItem(index),
              ),
            ],
          );
        }),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add Item'),
          onPressed: addItem,
        ),
        const SizedBox(height: 12),
        Text('Total Price: ₹${totalPrice.toStringAsFixed(2)}'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xFFFFF8E5),
      title: const Text('Add New Entry'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<NoteType>(
              value: selectedType,
              items: NoteType.values.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e.name[0].toUpperCase() + e.name.substring(1)),
                );
              }).toList(),
              onChanged: (val) => setState(() => selectedType = val!),
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            if (selectedType == NoteType.note)
              TextField(
                controller: messageController,
                decoration: const InputDecoration(labelText: 'Message'),
                maxLines: 3,
              )
            else
              buildGroceryInputList(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: saveNote, child: const Text('Save')),
      ],
    );
  }
}
