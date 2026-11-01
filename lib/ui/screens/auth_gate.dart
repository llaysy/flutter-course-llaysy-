import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/catalog/catalog_bloc.dart';
import '../../bloc/catalog/catalog_event.dart';
import '../../data/repositories/catalog_repository.dart';
import 'catalog_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.unknown:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          case AuthStatus.authenticated:
            final user = state.user!;
            return BlocProvider<CatalogBloc>(
              key: ValueKey(user.uid),
              create: (context) => CatalogBloc(
                repository: context.read<CatalogRepository>(),
                uid: user.uid,
              )..add(const CatalogStarted()),
              child: const CatalogScreen(),
            );
          case AuthStatus.unauthenticated:
            return const LoginScreen();
        }
      },
    );
  }
}
