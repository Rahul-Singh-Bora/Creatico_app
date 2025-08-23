import 'package:creatico/features/auth/bloc/auth_bloc.dart';
import 'package:creatico/features/auth/bloc/auth_event.dart';
import 'package:creatico/features/auth/bloc/auth_state.dart' as app_auth;
import 'package:creatico/features/login/presentation/widgets/google_signin_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, app_auth.AuthState>(
        listener: (context, state) {
          if (state is app_auth.AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("⚠️ ${state.message}")),
            );
          }
        },
        builder: (context, state) {
          if (state is app_auth.AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Welcome to Creatico 👋",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                GoogleSignInButton(
                          isLoading: state is app_auth.AuthLoading,
                          onPressed: () {
                            context.read<AuthBloc>().add(
                              GoogleSignInRequested(),
                            );
                          },
                        ),
              ],
            ),
          );
        },
      ),
    );
  }
}
