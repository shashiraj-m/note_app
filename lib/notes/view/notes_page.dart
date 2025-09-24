import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_app/auth/auth_status.dart';
import 'package:note_app/auth/view/signin_page.dart';
import 'package:note_app/custom_widgets/shimmer_loader.dart';
import 'package:note_app/models/note_model.dart';
import 'package:note_app/notes/cubit/note_cubit.dart';
import 'package:note_app/notes/cubit/notes_status.dart';
import 'package:note_app/notes/view/note_detail.dart';
import 'package:note_app/notes/view/notes_input.dart';
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

  void _openNoteDialog() async {
    await showDialog(context: context, builder: (_) => NoteInputDialog());
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final user = context.select((AuthCubit cubit) => cubit.state.user);
    final username = user?.username ?? "User";
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFont(double base) => screenWidth < 600 ? base : base * 1.2;
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          // Navigate to login page if user logs out
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SigninPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
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
          backgroundColor: Color(0xFFF9BDAE),
          onPressed: _openNoteDialog,
          label: Text(
            "Add Note",
            style: TextStyle(fontSize: scaleFont(14), color: Color(0xFF4682C4)),
          ),
          icon: const Icon(Icons.edit, color: Color(0xFF4682C4)),
        ),
        body: BlocBuilder<NotesCubit, NotesState>(
          builder: (context, state) {
            if (state.status == NotesStatus.loading) {
              return notesList();
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

                mainAxisExtent: isTablet ? 150 : 120,
              ),
              itemCount: state.notes.length,
              itemBuilder: (_, index) {
                final note = state.notes[index];

                if (note.type == NoteType.note) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<NotesCubit>(),
                            child: NoteViewPage(
                              noteId: note.noteId,
                              userId: note.uid,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
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
                                    style: TextStyle(
                                      fontSize: scaleFont(14),
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          right: -2,
                          top: -2,
                          child: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Color(0xFFE53935),
                            ),
                            onPressed: () {
                              context.read<NotesCubit>().deleteNote(
                                note.noteId,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<NotesCubit>(),
                            child: NoteViewPage(
                              noteId: note.noteId,
                              userId: note.uid,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
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
                                  child: ListView.builder(
                                    itemCount: note.items.length,
                                    itemBuilder: (context, itemIndex) {
                                      final item = note.items[itemIndex];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        child: Text(
                                          '${item.name} - ${item.weight} • ₹${item.price}',
                                          style: TextStyle(
                                            fontSize: scaleFont(14),
                                            decoration: item.isBought
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          right: -2,
                          top: -2,
                          child: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Color(0xFFE53935),
                            ),
                            onPressed: () {
                              context.read<NotesCubit>().deleteNote(
                                note.noteId,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
