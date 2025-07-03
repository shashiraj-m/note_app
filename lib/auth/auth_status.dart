import 'package:note_app/models/user_model.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final AppUser? user;

  const AuthState._({required this.status, this.user});

  const AuthState.loading() : this._(status: AuthStatus.loading);
  const AuthState.authenticated(AppUser user)
    : this._(status: AuthStatus.authenticated, user: user);
  const AuthState.unauthenticated()
    : this._(status: AuthStatus.unauthenticated);
}
