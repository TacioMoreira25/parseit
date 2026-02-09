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
        onPressed: () async {
          final result = await context.push<bool>('/add_job');
          if (result == true) {
            viewModel.fetchJobs();
          }
        },
        backgroundColor: const Color(0xFF1A1A1A),
        child: const Icon(CupertinoIcons.add, color: Colors.white),
        shape: const CircleBorder(),
      ),
    );
  }
}
