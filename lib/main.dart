import 'package:creatico/features/auth/presentation/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/services/storage_services.dart';
import 'features/auth/bloc/auth_bloc.dart';

import 'features/auth/repositories/auth_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  await dotenv.load(fileName: ".env");

  // Initialize local storage
  await StorageService.init();

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthRepository _authRepository = AuthRepository();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _authRepository,
      child: BlocProvider(
        create: (_) => AuthBloc(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Creatico',
          home: AuthGate()
        ),
      ),
    );
  }
}
