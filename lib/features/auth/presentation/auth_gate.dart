import 'package:creatico/features/auth/bloc/auth_bloc.dart';
import 'package:creatico/features/auth/bloc/auth_state.dart';
import 'package:creatico/features/idea/presentation/pages/idea_chat_screen.dart';
import 'package:creatico/features/login/presentation/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthUnauthenticated || state is AuthInitial) {
          return const LoginScreen();
        }

        if (state is AuthAuthenticated) {
          return const IdeasChatScreen(); // ✅ Your home screen
        }

        if (state is AuthError) {
          return Scaffold(
            body: Center(
              child: Text("Auth error: ${state.message}"),
            ),
          );
        }

        return const LoginScreen(); // fallback
      },
    );
  }
}
