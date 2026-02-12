import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dashboard/dashboard_screen.dart';
import 'dashboard/view_models/dashboard_view_model.dart';

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardViewModel = context.read<DashboardViewModel>();

    return Scaffold(
      body: const DashboardScreen(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_job_fab',
        onPressed: () {
          context.push('/add_job').then((result) {
            dashboardViewModel.fetchJobs();
            dashboardViewModel.startTagPolling();
          });
        },
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
