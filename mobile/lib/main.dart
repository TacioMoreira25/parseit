import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/cv_repository.dart';
import 'data/repositories/job_repository.dart';
import 'data/services/api_service.dart';
import 'routing/app_router.dart';
import 'ui/add_job/view_models/add_job_view_model.dart';
import 'ui/core/themes/app_theme.dart';
import 'ui/edit_cv/view_models/edit_cv_viewmodel.dart';
import 'ui/dashboard/view_models/dashboard_view_model.dart';

void main() {
  final ApiService apiService = ApiService();
  // Create repositories
  final JobRepository jobRepository = JobRepository(apiService);
  final CvRepository cvRepository = CvRepository(apiService);

  runApp(MyApp(jobRepository: jobRepository, cvRepository: cvRepository));
}

class MyApp extends StatelessWidget {
  final JobRepository jobRepository;
  final CvRepository cvRepository;

  const MyApp({
    super.key,
    required this.jobRepository,
    required this.cvRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repositories
        Provider<JobRepository>.value(value: jobRepository),
        Provider<CvRepository>.value(value: cvRepository),

        // ViewModels
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(jobRepository),
        ),
        ChangeNotifierProvider(create: (_) => AddJobViewModel(jobRepository)),
        ChangeNotifierProvider(
          create: (context) => EditCvViewModel(context.read<CvRepository>()),
        ),
      ],
      child: MaterialApp.router(
        title: 'ParseIt',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
