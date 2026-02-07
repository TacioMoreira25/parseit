import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../domain/models/job.dart';
import '../dashboard/view_models/dashboard_view_model.dart';

class EditJobScreen extends StatefulWidget {
  final Job job;
  const EditJobScreen({super.key, required this.job});

  @override
  State<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _linkController;
  late final TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.job.title);
    _linkController = TextEditingController(text: widget.job.url);
    _descriptionController = TextEditingController(
      text: widget.job.description,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _linkController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdate() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final viewModel = Provider.of<DashboardViewModel>(context, listen: false);
    final success = await viewModel.updateJobDetails(
      jobId: widget.job.id,
      title: _titleController.text,
      link: _linkController.text,
      description: _descriptionController.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Vaga atualizada com sucesso!' : viewModel.errorMessage,
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      Navigator.of(context).pop();
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Vaga')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextFormField(_titleController, 'Título da Vaga'),
              const SizedBox(height: 16),
              _buildTextFormField(
                _linkController,
                'Link (Opcional)',
                isOptional: true,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                _descriptionController,
                'Descrição',
                maxLines: 10,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                icon: _isLoading
                    ? const SizedBox.shrink()
                    : const Icon(CupertinoIcons.check_mark_circled, size: 20),
                label: Text(_isLoading ? 'Salvando...' : 'Salvar Alterações'),
                onPressed: _isLoading ? null : _submitUpdate,
                style: FilledButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF1A1A1A),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
    TextEditingController controller,
    String label, {
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
        labelText: label,
        labelStyle: GoogleFonts.inter(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
      ),
    );
  }
}
