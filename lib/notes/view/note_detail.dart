import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/models/note_model.dart';
import 'package:note_app/notes/cubit/note_cubit.dart';
import 'package:note_app/notes/cubit/notes_status.dart';

class NoteViewPage extends StatefulWidget {
  final String noteId;
  final String userId;

  const NoteViewPage({super.key, required this.noteId, required this.userId});

  @override
  State<NoteViewPage> createState() => _NoteViewPageState();
}

class _NoteViewPageState extends State<NoteViewPage> {
  Note? currentNote;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  void _loadNote() async {
    await context.read<NotesCubit>().fetchNoteById(
      widget.noteId,
      widget.userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFont(double base) => screenWidth < 600 ? base : base * 1.2;
    return BlocBuilder<NotesCubit, NotesState>(
      builder: (context, state) {
        final note = state.editingNote;

        final isListNote =
            state.editingNote?.type == NoteType.grocery ||
            state.editingNote?.type == NoteType.vegetable;

        if (state.status == NotesStatus.failure) {
          return Scaffold(
            body: Center(child: Text(state.errorMessage ?? 'Note not found')),
          );
        }

        if (state.status == NotesStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(note!.title), centerTitle: true),
          body: Padding(
            padding: const EdgeInsets.all(5.0),
            child: isListNote
                ? _buildListView(context, note)
                : Text(note.message),
          ),
          floatingActionButton: isListNote
              ? FloatingActionButton.extended(
                  backgroundColor: Color(0xFFF9BDAE),
                  onPressed: () => _showAddItemDialog(context, note),
                  label: Text(
                    'Add Item',
                    style: TextStyle(
                      fontSize: scaleFont(14),
                      color: Color(0xFF4682C4),
                    ),
                  ),
                  icon: const Icon(Icons.edit, color: Color(0xFF4682C4)),
                )
              : null,
          bottomNavigationBar: isListNote
              ? BottomAppBar(
                  color: Colors.white,
                  height: 50,
                  child: BlocBuilder<NotesCubit, NotesState>(
                    builder: (context, state) {
                      final total =
                          state.editingNote?.items
                              .where((i) => i.isBought)
                              .fold(0.0, (sum, i) => sum + (i.price)) ??
                          0.0;
                      final totalItems = note.items.length;
                      final boughtItems = note.items
                          .where((item) => item.isBought)
                          .length;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Bought Items: $boughtItems/$totalItems',
                            style: TextStyle(
                              fontSize: scaleFont(16),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Total: ₹${total.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: scaleFont(16),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildListView(BuildContext context, Note note) {
    final boughtItems = note.items.where((item) => item.isBought).toList();
    final notBoughtItems = note.items.where((item) => !item.isBought).toList();
    final sortedItems = [...notBoughtItems, ...boughtItems];

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: sortedItems.length,
            itemBuilder: (context, index) {
              final item = sortedItems[index];
              final priceController = TextEditingController(
                text: item.price.toStringAsFixed(0),
              );
              final weightController = TextEditingController(text: item.weight);

              final weightFocus = FocusNode();

              weightFocus.addListener(() {
                if (!weightFocus.hasFocus) {
                  final updatedItem = item.copyWith(
                    weight: weightController.text,
                  );
                  _updateItem(context, note, updatedItem);
                }
              });
              return Dismissible(
                key: Key('${item.name}-$index'),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  final updatedItems = [...note.items]..removeAt(index);
                  final updatedNote = note.copyWith(items: updatedItems);
                  final cubit = context.read<NotesCubit>();
                  cubit.updateNote(updatedNote);

                  cubit.emit(cubit.state.copyWith(editingNote: updatedNote));

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item.name} deleted')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.only(right: 15, bottom: 5, top: 5),
                  child: Row(
                    children: [
                      Checkbox(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        checkColor: Colors.white,
                        focusColor: Color(0XFF63B687),
                        activeColor: Color(0XFF63B687),
                        value: item.isBought,
                        onChanged: (val) {
                          final updatedItem = item.copyWith(
                            isBought: val ?? false,
                          );
                          _updateItem(context, note, updatedItem);
                        },
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(item.name, style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: weightController,
                          focusNode: weightFocus,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Weight',
                            isDense: true,
                            hintText: 'e.g. 1kg',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),

                          onSubmitted: (value) {
                            final updatedItem = item.copyWith(weight: value);

                            _updateItem(context, note, updatedItem);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],

                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Price',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                          onSubmitted: (value) {
                            final newPrice = double.tryParse(value);
                            if (newPrice != null && newPrice != item.price) {
                              final updatedItem = item.copyWith(
                                price: newPrice,
                              );
                              _updateItem(context, note, updatedItem);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddItemDialog(BuildContext context, Note note) {
    final nameController = TextEditingController();
    final weightController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFFFFF8E5),
          title: const Text('Add New Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: 'Weight'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final weight = weightController.text.trim();
                final price =
                    double.tryParse(priceController.text.trim()) ?? 0.0;

                if (name.isNotEmpty && weight.isNotEmpty) {
                  final newItem = GroceryItem(
                    name: name,
                    weight: weight,
                    price: price,
                    isBought: false,
                  );

                  final updatedItems = [...note.items, newItem];
                  final updatedNote = note.copyWith(items: updatedItems);

                  final cubit = context.read<NotesCubit>();
                  cubit.updateNote(updatedNote);
                  cubit.emit(cubit.state.copyWith(editingNote: updatedNote));

                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _updateItem(BuildContext context, Note note, GroceryItem updatedItem) {
    final updatedItems = note.items.map((item) {
      return item.name == updatedItem.name ? updatedItem : item;
    }).toList();

    final updatedNote = note.copyWith(items: updatedItems);
    final cubit = context.read<NotesCubit>();
    cubit.updateNote(updatedNote);
    cubit.emit(cubit.state.copyWith(editingNote: updatedNote));
  }
}
