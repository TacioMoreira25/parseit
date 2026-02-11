import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/repositories/job_repository.dart';
import 'data/services/api_service.dart';
import 'routing/app_router.dart';
import 'ui/add_job/view_models/add_job_view_model.dart';
import 'ui/core/themes/app_theme.dart';
import 'ui/core/themes/theme_provider.dart';
import 'ui/dashboard/view_models/dashboard_view_model.dart';

void main() {
  final ApiService apiService = ApiService();
  final JobRepository jobRepository = JobRepository(apiService);

  runApp(MyApp(jobRepository: jobRepository));
}

class MyApp extends StatelessWidget {
  final JobRepository jobRepository;
  const MyApp({super.key, required this.jobRepository});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<JobRepository>(create: (_) => jobRepository),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(jobRepository),
        ),
        ChangeNotifierProvider(create: (_) => AddJobViewModel(jobRepository)),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'ParseIt',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
