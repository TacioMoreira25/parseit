import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/themes/theme_provider.dart';
import 'view_models/dashboard_view_model.dart';
import 'widgets/job_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Vagas'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          ),
        ],
      ),
      body: Consumer<DashboardViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading)
            return const Center(child: CircularProgressIndicator());

          if (viewModel.jobs.isEmpty) {
            return const Center(child: Text('Nenhuma vaga salva ainda.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.jobs.length,
            itemBuilder: (context, index) =>
                JobCard(job: viewModel.jobs[index]),
          );
        },
      ),
    );
  }
}
