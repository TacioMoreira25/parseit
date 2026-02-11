import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_models/add_job_view_model.dart';

class AddJobScreen extends StatelessWidget {
  const AddJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddJobViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Nova Vaga')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: viewModel.titleController,
              decoration: const InputDecoration(
                labelText: 'Título da Vaga',
                border: OutlineInputBorder(),
                hintText: 'Ex: Senior Java Developer',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: viewModel.companyController,
              decoration: const InputDecoration(
                labelText: 'Empresa',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: viewModel.descriptionController,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Descrição ou Requisitos',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
                hintText:
                    'Cole aqui o texto da vaga para extrairmos os termos...',
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        final success = await viewModel.saveJob();
                        if (success && context.mounted) Navigator.pop(context);
                      },
                child: viewModel.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'SALVAR VAGA E GERAR ESTUDO',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
