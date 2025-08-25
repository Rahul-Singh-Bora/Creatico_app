import 'package:creatico/features/auth/presentation/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/services/storage_services.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/repositories/auth_repository.dart';
import 'features/idea/bloc/idea_bloc.dart';
import 'features/idea/data/repositories/repository.dart';
import 'features/chat/bloc/chat_bloc.dart';
import 'features/chat/data/repositories/chat_repository.dart';

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
  final IdeasRepository _ideasRepository = IdeasRepository();
  final ChatRepository _chatRepository = ChatRepository();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authRepository),
        RepositoryProvider.value(value: _ideasRepository),
        RepositoryProvider.value(value: _chatRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc()),
          BlocProvider(create: (_) => IdeasBloc(_ideasRepository)),
          BlocProvider(create: (_) => ChatBloc(_chatRepository)),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Creatico',
          home: AuthGate()
        ),
      ),
    );
  }
}
