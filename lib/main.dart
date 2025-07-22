import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/auth/auth_status.dart';
import 'package:note_app/auth/cubit/auth_cubit.dart';
import 'package:note_app/auth/view/signin_page.dart';
import 'package:note_app/custom_widgets/shimmer_loader.dart';
import 'package:note_app/firebase_options.dart';
import 'package:note_app/notes/cubit/note_cubit.dart';
import 'package:note_app/notes/view/notes_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()..checkAuth()),
        BlocProvider(create: (_) => NotesCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Color(0xFFFFF8E5),
          appBarTheme: AppBarTheme(backgroundColor: Colors.white),
        ),
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state.status == AuthStatus.loading) {
              return Scaffold(body: homeScreen());
            } else if (state.status == AuthStatus.authenticated) {
              return const NotesPage();
            } else {
              return const SigninPage();
            }
          },
        ),
      ),
    );
  }
}
