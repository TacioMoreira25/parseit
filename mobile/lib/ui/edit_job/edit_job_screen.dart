import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _companyController;
  late final TextEditingController _linkController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _salaryController;

  late String _status;
  late String _jobType;
  late String _location;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.job.title);
    _companyController = TextEditingController(text: widget.job.company);
    _linkController = TextEditingController(text: widget.job.url);
    _descriptionController = TextEditingController(
      text: widget.job.description,
    );
    _salaryController = TextEditingController(text: widget.job.salary);

    _status =
        [
          'applied',
          'interview',
          'offer',
          'rejected',
        ].contains(widget.job.status)
        ? widget.job.status
        : 'applied';

    _jobType = widget.job.jobType.isNotEmpty ? widget.job.jobType : 'Junior';
    _location = widget.job.location.isNotEmpty ? widget.job.location : 'Remoto';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _linkController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdate() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    final viewModel = Provider.of<DashboardViewModel>(context, listen: false);

    final success = await viewModel.updateJobFull(
      jobId: widget.job.id,
      title: _titleController.text,
      company: _companyController.text,
      link: _linkController.text,
      description: _descriptionController.text,
      status: _status,
      jobType: _jobType,
      location: _location,
      salary: _salaryController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              _buildTextFormField(_titleController, 'Título', Icons.work),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      _companyController,
                      'Empresa',
                      Icons.business,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextFormField(
                      _salaryController,
                      'Salário',
                      Icons.attach_money,
                      isOptional: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      value: _status,
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
                        DropdownMenuItem(value: 'offer', child: Text('Oferta')),
                        DropdownMenuItem(
                          value: 'rejected',
                          child: Text('Rejeitado'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _status = v as String),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      value: _jobType,
                      label: 'Nível',
                      items: ['Estágio', 'Junior', 'Pleno', 'Senior']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _jobType = v as String),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildDropdown(
                value: _location,
                label: 'Localização',
                items: ['Remoto', 'Híbrido', 'Presencial']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _location = v as String),
              ),
              const SizedBox(height: 12),

              _buildTextFormField(
                _linkController,
                'Link',
                Icons.link,
                isOptional: true,
              ),
              const SizedBox(height: 12),

              _buildTextFormField(
                _descriptionController,
                'Descrição',
                Icons.notes,
                maxLines: 8,
              ),

              const SizedBox(height: 32),
              FilledButton.icon(
                icon: _isLoading
                    ? const SizedBox.shrink()
                    : const Icon(
                        CupertinoIcons.floppy_disk,
                        color: Colors.white,
                      ),
                label: Text(
                  _isLoading ? 'Salvando...' : 'Salvar Alterações',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onPressed: _isLoading ? null : _submitUpdate,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int maxLines = 1,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      validator: (v) =>
          !isOptional && (v == null || v.isEmpty) ? 'Obrigatório' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    // Garante que o valor existe na lista
    final validValue = items.any((i) => i.value == value)
        ? value
        : items.first.value;

    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: validValue,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
