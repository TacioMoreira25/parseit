import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'view_models/add_job_view_model.dart';

class AddJobScreen extends StatelessWidget {
  const AddJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AddJobViewModel>(context, listen: false);
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(title: const Text('Nova Vaga'), centerTitle: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextFormField(viewModel.titleController, 'Título da Vaga'),
              const SizedBox(height: 16),
              _buildTextFormField(
                viewModel.linkController,
                'Link (Opcional)',
                isOptional: true,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                viewModel.descriptionController,
                'Cole a descrição completa aqui...',
                maxLines: 8,
              ),
              const SizedBox(height: 32),
              _buildSubmitButton(formKey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.inter(fontSize: 15),
      validator: (value) {
        if (!isOptional && (value == null || value.isEmpty)) {
          return 'Este campo é obrigatório.';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFF00695C), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(GlobalKey<FormState> formKey) {
    return Consumer<AddJobViewModel>(
      builder: (context, viewModel, child) {
        return FilledButton.icon(
          icon: viewModel.state == AddJobState.loading
              ? const SizedBox.shrink()
              : const Icon(CupertinoIcons.sparkles, size: 20),
          label: Text(
            viewModel.state == AddJobState.loading
                ? 'Processando...'
                : 'Salvar e Processar',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          onPressed: viewModel.state == AddJobState.loading
              ? null
              : () async {
                  if (formKey.currentState?.validate() ?? false) {
                    final success = await viewModel.submitJob();
                    if (!context.mounted) return;

                    if (success) {
                      Navigator.pop(context, true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(viewModel.errorMessage),
                          backgroundColor: Colors.red[700],
                        ),
                      );
                    }
                  }
                },
          style: FilledButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF1A1A1A),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        );
      },
    );
  }
}
