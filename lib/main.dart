import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/transactions/presentation/bloc/summary_bloc.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';
import 'features/transactions/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const SpendArc());
}

class SpendArc extends StatelessWidget {
  const SpendArc({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: di.sl<AuthBloc>()),
        BlocProvider.value(value: di.sl<TransactionBloc>()),
        BlocProvider.value(value: di.sl<SummaryBloc>()),
      ],
      child: MaterialApp(
        title: 'SpendArc',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const _RootPage(),
      ),
    );
  }
}

class _RootPage extends StatelessWidget {
  const _RootPage();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.read<TransactionBloc>().add(LoadTransactions());
        }
      },
      builder: (context, state) {
        if (state is AuthAuthenticated) return const HomePage();
        return const LoginPage();
      },
    );
  }
}
