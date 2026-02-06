import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import './view_models/dashboard_view_model.dart';
import './widgets/job_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DashboardViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(title: const Text('Job Feed'), centerTitle: false),
      body: Consumer<DashboardViewModel>(
        builder: (context, viewModel, child) {
          switch (viewModel.state) {
            case DashboardState.loading:
            case DashboardState.initial:
              return const Center(child: CircularProgressIndicator());
            case DashboardState.error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    viewModel.errorMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.red[700]),
                  ),
                ),
              );
            case DashboardState.success:
              if (viewModel.jobs.isEmpty) {
                return const Center(
                  child: Text('Nenhuma vaga encontrada no momento.'),
                );
              }
              return RefreshIndicator(
                onRefresh: viewModel.fetchJobs,
                child: ListView.builder(
                  itemCount: viewModel.jobs.length,
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemBuilder: (context, index) {
                    final job = viewModel.jobs[index];
                    return JobCard(job: job);
                  },
                ),
              );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the AddJobScreen, which is the second tab (index 1)
          // This is a placeholder navigation. For a more robust solution,
          // consider a shared state for tab management if not already in place.
          // For now, this assumes a simple tab switch logic might be handled by MainWrapper.
          // A better way is to push a new route if it's not tab-based.
          // Let's create a new route for adding jobs.
          context.push('/add_job').then((_) {
            // After returning from the add job screen, refresh the list.
            viewModel.fetchJobs();
          });
        },
        backgroundColor: const Color(0xFF1A1A1A),
        child: const Icon(CupertinoIcons.add, color: Colors.white),
        shape: const CircleBorder(),
      ),
    );
  }
}
