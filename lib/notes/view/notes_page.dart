import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_app/notes/cubit/note_cubit.dart';
import 'package:note_app/notes/cubit/notes_status.dart';
import '../../auth/cubit/auth_cubit.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    context.read<NotesCubit>().listenToNotes(user.uid);
  }

  void _openNoteDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("New Note"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<NotesCubit>().addNote(
                user.uid,
                titleController.text,
                messageController.text,
              );
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final user = context.select((AuthCubit cubit) => cubit.state.user);
    final username = user?.username ?? "User";
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFont(double base) => screenWidth < 600 ? base : base * 1.2;
    return Scaffold(
      appBar: AppBar(
        title: Text(username, style: TextStyle(fontSize: scaleFont(20))),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => context.read<AuthCubit>().logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNoteDialog,
        label: Text("Add Note", style: TextStyle(fontSize: scaleFont(14))),
        icon: const Icon(Icons.edit),
      ),
      body: BlocBuilder<NotesCubit, NotesState>(
        builder: (context, state) {
          if (state.status == NotesStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == NotesStatus.failure) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          } else if (state.notes.isEmpty) {
            return const Center(child: Text('No notes found.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 2 : 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: isTablet ? 140 : 120,
            ),
            itemCount: state.notes.length,
            itemBuilder: (_, index) {
              final note = state.notes[index];
              return Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: scaleFont(16),
                            ),
                          ),
                          Container(
                            height: 0.5,
                            width: double.infinity,
                            color: Colors.grey.shade300,
                            margin: EdgeInsets.symmetric(vertical: 4),
                          ),

                          Expanded(
                            child: Text(
                              note.message,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: scaleFont(14)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        context.read<NotesCubit>().deleteNote(note.noteId);
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
