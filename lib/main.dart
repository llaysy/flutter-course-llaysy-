import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/auth/auth_cubit.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/catalog_repository.dart';
import 'firebase_options.dart';
import 'ui/screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CatalogApp());
}

class CatalogApp extends StatelessWidget {
  const CatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => AuthRepository()),
        RepositoryProvider<CatalogRepository>(
          create: (_) => CatalogRepository(),
        ),
      ],
      child: BlocProvider<AuthCubit>(
        create: (context) => AuthCubit(context.read<AuthRepository>()),
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: AuthGate(),
        ),
      ),
    );
  }
}
