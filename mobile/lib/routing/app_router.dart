import 'package:go_router/go_router.dart';
import 'package:mobile/ui/add_job/add_job_screen.dart';
import 'package:mobile/ui/edit_job/edit_job_screen.dart';
import 'package:mobile/ui/main_wrapper.dart';
import 'package:provider/provider.dart';
import '../data/repositories/cv_repository.dart';
import '../domain/models/job.dart';
import '../ui/cv_editor/cv_editor_screen.dart';
import '../ui/cv_editor/view_models/cv_editor_viewmodel.dart';
import '../ui/job_details/job_details_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/', // Reverted to original
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainWrapper(),
        routes: [
          GoRoute(
            path: 'add_job',
            builder: (context, state) => const AddJobScreen(),
          ),
          GoRoute(
            path: 'edit_job',
            builder: (context, state) {
              final job = state.extra as Job?;
              if (job != null) {
                return EditJobScreen(job: job);
              } else {
                return const MainWrapper(); // Fallback
              }
            },
          ),
          // The route now accepts a cvId as a parameter
          GoRoute(
            path: 'edit-cv/:cvId',
            builder: (context, state) {
              final cvId = state.pathParameters['cvId'];
              return CvEditorScreenProvider(cvId: cvId!);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/details',
        builder: (context, state) {
          final job = state.extra as Job?;
          if (job != null) {
            return JobDetailsScreen(job: job);
          } else {
            return const MainWrapper();
          }
        },
      ),
    ],
    errorBuilder: (context, state) => const MainWrapper(),
  );
}
