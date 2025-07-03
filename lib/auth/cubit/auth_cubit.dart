import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/auth/auth_status.dart';
import 'package:note_app/models/user_model.dart';
import 'package:note_app/notes/cubit/note_cubit.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState.loading());

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  void checkAuth() {
    emit(const AuthState.loading());

    _auth.authStateChanges().listen((user) async {
      if (user == null) {
        emit(const AuthState.unauthenticated());
      } else {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        final appUser = AppUser.fromFirebase(user, doc.data());
        emit(AuthState.authenticated(appUser));
      }
    });
  }

  Future<bool> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      final appUser = AppUser.fromFirebase(userCredential.user!, doc.data());

      emit(AuthState.authenticated(appUser));
      return true;
    } catch (e) {
      emit(const AuthState.unauthenticated());
      return false;
    }
  }

  Future<bool> signup(String username, String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      await userCredential.user!.updateDisplayName(username);

      await _firestore.collection('users').doc(uid).set({
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final appUser = AppUser(uid: uid, email: email, username: username);

      emit(AuthState.authenticated(appUser));
      return true;
    } catch (e) {
      emit(const AuthState.unauthenticated());
      return false;
    }
  }

 void logout(BuildContext context) async {
    context.read<NotesCubit>().cancelSubscription();
    await _auth.signOut();
    emit(const AuthState.unauthenticated());
  }

}
