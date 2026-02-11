import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../domain/models/job.dart';
import '../ui/add_job/add_job_screen.dart';
import '../ui/edit_job/edit_job_screen.dart';
import '../ui/job_details/job_details_screen.dart';
import '../ui/main_wrapper.dart';

class AppRouter {
  AppRouter._();

  // Chave global para limpar qualquer reserva de chave anterior no Navigator
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    routes: [
      // Rota Raiz
      GoRoute(path: '/', builder: (context, state) => const MainWrapper()),

      GoRoute(
        path: '/details',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final job = state.extra as Job?;
          if (job != null) {
            return JobDetailsScreen(job: job);
          }
          return const MainWrapper();
        },
      ),

      GoRoute(
        path: '/add_job',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddJobScreen(),
      ),

      GoRoute(
        path: '/edit_job',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final job = state.extra as Job?;
          return job != null ? EditJobScreen(job: job) : const MainWrapper();
        },
      ),
    ],
    errorBuilder: (context, state) =>
        const Scaffold(body: Center(child: Text('Erro de Rota'))),
  );
}
