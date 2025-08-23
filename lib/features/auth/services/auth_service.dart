// ignore_for_file: avoid_print

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


final supabase = Supabase.instance.client;

Future<AuthResponse> googleSignIn() async {
  final webClientId = dotenv.env['WEB_CLIENT_ID'];
  print('[Auth Debug] WEB_CLIENT_ID from .env: $webClientId');

  final GoogleSignIn googleSignIn = GoogleSignIn(serverClientId: webClientId);

  await googleSignIn.signOut();

  final googleUser = await googleSignIn.signIn();
  print('[GoogleSignIn] googleUser: $googleUser');

  if (googleUser == null) {
    print('[GoogleSignIn] User cancelled or sign-in failed.');
    throw Exception('Google sign-in was cancelled or failed.');
  }

  final googleAuth = await googleUser.authentication;
  final accessToken = googleAuth.accessToken;
  final idToken = googleAuth.idToken;

  if (accessToken == null || idToken == null) {
    throw Exception('Missing Google auth tokens.');
  }

  final res = await supabase.auth.signInWithIdToken(
    provider: OAuthProvider.google,
    idToken: idToken,
    accessToken: accessToken,
  );

  print('[Auth Debug] Session User: ${res.session?.user}');
 

  return res;
}

