import 'package:go_router/go_router.dart';
import 'package:mobile/ui/add_job/add_job_screen.dart';
import 'package:mobile/ui/main_wrapper.dart';
import '../domain/models/job.dart';
import '../ui/job_details/job_details_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // The root route now points to the MainWrapper with the BottomNavBar
      GoRoute(
        path: '/',
        builder: (context, state) => const MainWrapper(),
        routes: [
          // A nested route for adding a job, accessed from the dashboard
          GoRoute(
            path: 'add_job',
            builder: (context, state) => const AddJobScreen(),
          ),
        ],
      ),
      // The details route remains the same, accessed from the list
      GoRoute(
        path: '/details',
        builder: (context, state) {
          final job = state.extra as Job?;
          if (job != null) {
            return JobDetailsScreen(job: job);
          }
          // If the job is null, go back to the main wrapper
          return const MainWrapper();
        },
      ),
    ],
    errorBuilder: (context, state) =>
        const MainWrapper(), // Fallback to the main screen
  );
}
