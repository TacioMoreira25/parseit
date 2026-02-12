import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_models/add_job_view_model.dart';

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddJobViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Nova Vaga')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Informações Básicas",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),

                _buildTextField(
                  controller: viewModel.titleController,
                  label: 'Título da Vaga',
                  hint: 'Ex: Desenvolvedor Mobile',
                  icon: Icons.work_outline,
                  validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: viewModel.companyController,
                        label: 'Empresa',
                        icon: Icons.business,
                        validator: (v) =>
                            v?.isEmpty == true ? 'Obrigatório' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: viewModel.salaryController,
                        label: 'Salário (Opcional)',
                        hint: 'Ex: 5k',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const Text(
                  "Detalhes & Status",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        value: viewModel.selectedStatus,
                        label: 'Status',
                        items: const [
                          DropdownMenuItem(
                            value: 'applied',
                            child: Text('Aplicado'),
                          ),
                          DropdownMenuItem(
                            value: 'interview',
                            child: Text('Entrevista'),
                          ),
                          DropdownMenuItem(
                            value: 'offer',
                            child: Text('Oferta'),
                          ),
                          DropdownMenuItem(
                            value: 'rejected',
                            child: Text('Rejeitado'),
                          ),
                        ],
                        onChanged: (v) => viewModel.setStatus(v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown(
                        value: viewModel.selectedJobType,
                        label: 'Nível',
                        items: const [
                          DropdownMenuItem(
                            value: 'Estágio',
                            child: Text('Estágio'),
                          ),
                          DropdownMenuItem(
                            value: 'Junior',
                            child: Text('Júnior'),
                          ),
                          DropdownMenuItem(
                            value: 'Pleno',
                            child: Text('Pleno'),
                          ),
                          DropdownMenuItem(
                            value: 'Senior',
                            child: Text('Sênior'),
                          ),
                        ],
                        onChanged: (v) => viewModel.setJobType(v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        value: viewModel.selectedLocation,
                        label: 'Localização',
                        items: const [
                          DropdownMenuItem(
                            value: 'Remoto',
                            child: Text('Remoto'),
                          ),
                          DropdownMenuItem(
                            value: 'Híbrido',
                            child: Text('Híbrido'),
                          ),
                          DropdownMenuItem(
                            value: 'Presencial',
                            child: Text('Presencial'),
                          ),
                        ],
                        onChanged: (v) => viewModel.setLocation(v!),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const Text(
                  "Conteúdo",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),

                _buildTextField(
                  controller: viewModel.linkController,
                  label: 'Link da Vaga (URL)',
                  icon: Icons.link,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 12),

                _buildTextField(
                  controller: viewModel.descriptionController,
                  label: 'Descrição Completa',
                  hint: 'Cole aqui os requisitos...',
                  maxLines: 6,
                  alignLabelWithHint: true,
                  validator: (v) =>
                      v?.isEmpty == true ? 'A descrição é obrigatória' : null,
                ),

                const SizedBox(height: 32),

                SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: const Color(0xFF1A1A1A),
                    ),
                    icon: viewModel.isLoading
                        ? const SizedBox.shrink()
                        : const Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                          ),
                    label: viewModel.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'SALVAR VAGA',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              final success = await viewModel.saveJob();
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Vaga salva com sucesso!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pop(context);
                              }
                            }
                          },
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    bool alignLabelWithHint = false,
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: alignLabelWithHint,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required String label,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          onChanged: onChanged,
          items: items,
        ),
      ),
    );
  }
}
