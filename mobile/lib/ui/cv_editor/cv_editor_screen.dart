import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/repositories/cv_repository.dart';
import '../../domain/models/cv_block.dart';
import 'view_models/cv_editor_viewmodel.dart';

class CvEditorScreenProvider extends StatelessWidget {
  final String cvId;
  const CvEditorScreenProvider({super.key, required this.cvId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          CvEditorViewModel(context.read<CvRepository>(), cvId),
      child: const CvEditorScreen(),
    );
  }
}

class CvEditorScreen extends StatelessWidget {
  const CvEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CvEditorViewModel>();

    // Carrega a fonte selecionada ou usa Inter como padrão
    final currentFont = GoogleFonts.getFont(viewModel.currentFont);

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.getTextTheme(
          viewModel.currentFont,
          Theme.of(context).textTheme,
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F2F5), // Fundo cinza suave
        appBar: AppBar(
          title: Text(
            viewModel.isEditing ? 'Editando...' : 'Visualizar CV',
            style: currentFont.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black87,
          actions: [
            if (viewModel.isSaving)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),

            // Botão Alternar Modo
            IconButton(
              icon: Icon(viewModel.isEditing ? Icons.check_circle : Icons.edit),
              color: viewModel.isEditing
                  ? const Color(0xFF00695C)
                  : Colors.black87,
              tooltip: viewModel.isEditing ? 'Concluir Edição' : 'Editar',
              onPressed: viewModel.toggleEditMode,
            ),

            // Menu de Opções (Apenas modo leitura)
            if (!viewModel.isEditing)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'font') _showFontPicker(context, viewModel);
                  if (value == 'pdf') _generatePDF(context);
                  if (value == 'delete') _confirmDeleteCV(context, viewModel);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'font',
                    child: ListTile(
                      leading: Icon(Icons.font_download),
                      title: Text('Alterar Fonte'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'pdf',
                    child: ListTile(
                      leading: Icon(Icons.picture_as_pdf),
                      title: Text('Baixar PDF'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text(
                        'Excluir CV',
                        style: TextStyle(color: Colors.red),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
          ],
        ),
        body: viewModel.isEditing
            ? _buildEditView(context, viewModel)
            : _buildReadView(context, viewModel),
        floatingActionButton: viewModel.isEditing
            ? FloatingActionButton.extended(
                backgroundColor: const Color(0xFF1A1A1A),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Adicionar Seção",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => _showAddBlockModal(context, viewModel),
              )
            : null,
      ),
    );
  }

  // --- MODO EDIÇÃO ---
  Widget _buildEditView(BuildContext context, CvEditorViewModel viewModel) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
      itemCount: viewModel.blocks.length,
      onReorder: viewModel.onReorder,
      proxyDecorator: (child, index, animation) => Material(
        elevation: 8,
        color: Colors.white,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        child: child,
      ),
      itemBuilder: (context, index) {
        final block = viewModel.blocks[index];
        return Container(
          key: ValueKey(block.id),
          margin: const EdgeInsets.only(bottom: 16),
          child: Dismissible(
            key: ValueKey("dismiss-${block.id}"),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.delete_outline, color: Colors.red[900]),
            ),
            confirmDismiss: (_) => _confirmDeleteBlock(context),
            onDismissed: (_) => viewModel.deleteBlock(block.id),
            child: Material(
              color: Colors.white,
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.drag_indicator,
                          color: Colors.grey[300],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          block.type,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    _contentWidget(block, context, true),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- MODO LEITURA (VISUALIZAÇÃO DE DOCUMENTO) ---
  Widget _buildReadView(BuildContext context, CvEditorViewModel viewModel) {
    if (viewModel.blocks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "Seu currículo está em branco.\nToque no lápis para começar.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: viewModel.blocks
              .map(
                (block) => Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: _contentWidget(block, context, false),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  // --- SELETOR DE WIDGETS ---
  Widget _contentWidget(CVBlock block, BuildContext context, bool isEditing) {
    final vm = context.read<CvEditorViewModel>();
    switch (block.type) {
      case 'HEADER':
        return isEditing
            ? _HeaderBlockEdit(block: block, vm: vm)
            : _HeaderBlockRead(block: block);
      case 'TEXT':
        return isEditing
            ? _TextBlockEdit(block: block, vm: vm)
            : _TextBlockRead(block: block);
      case 'EXPERIENCE':
        return isEditing
            ? _ExperienceBlockEdit(block: block, vm: vm)
            : _ExperienceBlockRead(block: block);
      case 'EDUCATION':
        return isEditing
            ? _EducationBlockEdit(block: block, vm: vm)
            : _EducationBlockRead(block: block);
      case 'SKILL':
        return isEditing
            ? _SkillBlockEdit(block: block, vm: vm)
            : _SkillBlockRead(block: block);
      case 'PROJECT':
        return isEditing
            ? _ProjectBlockEdit(block: block, vm: vm)
            : _ProjectBlockRead(block: block);
      default:
        return const SizedBox();
    }
  }

  // --- UTILITÁRIOS ---
  void _showFontPicker(BuildContext context, CvEditorViewModel viewModel) {
    final fonts = [
      'Inter',
      'Roboto',
      'Lora',
      'Open Sans',
      'Lato',
      'Montserrat',
      'Merriweather',
    ];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: fonts
            .map(
              (f) => ListTile(
                title: Text(f, style: GoogleFonts.getFont(f)),
                trailing: viewModel.currentFont == f
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  viewModel.updateFont(f);
                  Navigator.pop(ctx);
                },
              ),
            )
            .toList(),
      ),
    );
  }

  void _showAddBlockModal(BuildContext context, CvEditorViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Cabeçalho"),
              onTap: () {
                viewModel.addBlock('HEADER');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notes),
              title: const Text("Texto Livre"),
              onTap: () {
                viewModel.addBlock('TEXT');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text("Experiência"),
              onTap: () {
                viewModel.addBlock('EXPERIENCE');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text("Educação"),
              onTap: () {
                viewModel.addBlock('EDUCATION');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text("Habilidades"),
              onTap: () {
                viewModel.addBlock('SKILL');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.rocket_launch),
              title: const Text("Projeto"),
              onTap: () {
                viewModel.addBlock('PROJECT');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDeleteBlock(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Remover seção?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  "Remover",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _confirmDeleteCV(BuildContext context, CvEditorViewModel viewModel) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir Currículo?"),
        content: const Text("Esta ação não pode ser desfeita."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteCV();
              Navigator.pop(ctx); // Fecha Dialog
              Navigator.pop(context); // Fecha Tela
            },
            child: const Text(
              "Excluir Definitivamente",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _generatePDF(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Geração de PDF em breve...")));
  }
}

// =============================================================================
// WIDGETS DE LEITURA (READ MODE)
// =============================================================================

class _HeaderBlockRead extends StatelessWidget {
  final CVBlock block;
  const _HeaderBlockRead({required this.block});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          block.content['name'] ?? 'Seu Nome',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            if (block.content['email']?.isNotEmpty ?? false)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.email_outlined,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    block.content['email'],
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            if (block.content['linkedin']?.isNotEmpty ?? false)
              GestureDetector(
                onTap: () => launchUrl(Uri.parse(block.content['linkedin'])),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.link, size: 14, color: Color(0xFF00695C)),
                    const SizedBox(width: 4),
                    const Text(
                      "LinkedIn",
                      style: TextStyle(
                        color: Color(0xFF00695C),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const Divider(height: 40, thickness: 1.5, color: Colors.black12),
      ],
    );
  }
}

class _TextBlockRead extends StatelessWidget {
  final CVBlock block;
  const _TextBlockRead({required this.block});
  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: block.content['text'] ?? '',
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        h1: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        h2: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        p: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
        strong: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ExperienceBlockRead extends StatelessWidget {
  final CVBlock block;
  const _ExperienceBlockRead({required this.block});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  block.content['role'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                block.content['period'] ?? '',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          Text(
            block.content['company'] ?? '',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            block.content['description'] ?? '',
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _EducationBlockRead extends StatelessWidget {
  final CVBlock block;
  const _EducationBlockRead({required this.block});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              block.content['institution'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              block.content['period'] ?? '',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        Text(
          block.content['degree'] ?? '',
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}

class _SkillBlockRead extends StatelessWidget {
  final CVBlock block;
  const _SkillBlockRead({required this.block});
  @override
  Widget build(BuildContext context) {
    final skills = (block.content['skills'] as String? ?? '').split(',');
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills
          .where((s) => s.trim().isNotEmpty)
          .map(
            (s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                s.trim(),
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ProjectBlockRead extends StatelessWidget {
  final CVBlock block;
  const _ProjectBlockRead({required this.block});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              block.content['title'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            if (block.content['link'] != null &&
                block.content['link'].isNotEmpty) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => launchUrl(Uri.parse(block.content['link'])),
                child: const Icon(
                  Icons.open_in_new,
                  size: 12,
                  color: Colors.blue,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          block.content['description'] ?? '',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
      ],
    );
  }
}

// =============================================================================
// WIDGETS DE EDIÇÃO (EDIT MODE)
// =============================================================================

class _MarkdownToolbar extends StatelessWidget {
  final TextEditingController controller;
  const _MarkdownToolbar({required this.controller});

  void _insert(String start, [String end = '']) {
    final text = controller.text;
    final selection = controller.selection;
    if (selection.start < 0) return;
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      "$start${text.substring(selection.start, selection.end)}$end",
    );
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset:
            selection.start +
            start.length +
            (selection.end - selection.start) +
            end.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: Colors.grey[50],
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          IconButton(
            icon: const Icon(Icons.format_bold, size: 18),
            onPressed: () => _insert('**', '**'),
            tooltip: 'Negrito',
          ),
          IconButton(
            icon: const Icon(Icons.format_italic, size: 18),
            onPressed: () => _insert('_', '_'),
            tooltip: 'Itálico',
          ),
          const VerticalDivider(width: 16, indent: 10, endIndent: 10),
          IconButton(
            icon: const Text(
              'H1',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
            ),
            onPressed: () => _insert('# '),
            tooltip: 'Título 1',
          ),
          IconButton(
            icon: const Text(
              'H2',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            onPressed: () => _insert('## '),
            tooltip: 'Título 2',
          ),
          const VerticalDivider(width: 16, indent: 10, endIndent: 10),
          IconButton(
            icon: const Icon(Icons.list, size: 18),
            onPressed: () => _insert('\n- '),
            tooltip: 'Lista',
          ),
        ],
      ),
    );
  }
}

class _HeaderBlockEdit extends StatefulWidget {
  final CVBlock block;
  final CvEditorViewModel vm;
  const _HeaderBlockEdit({required this.block, required this.vm});
  @override
  State<_HeaderBlockEdit> createState() => _HeaderBlockEditState();
}

class _HeaderBlockEditState extends State<_HeaderBlockEdit> {
  late TextEditingController _name, _email, _link;
  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.block.content['name']);
    _email = TextEditingController(text: widget.block.content['email']);
    _link = TextEditingController(text: widget.block.content['linkedin']);
  }

  void _up() => widget.vm.updateBlock(widget.block.id, {
    'name': _name.text,
    'email': _email.text,
    'linkedin': _link.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Nome Completo'),
          onChanged: (_) => _up(),
        ),
        TextField(
          controller: _email,
          decoration: const InputDecoration(labelText: 'E-mail'),
          onChanged: (_) => _up(),
        ),
        TextField(
          controller: _link,
          decoration: const InputDecoration(labelText: 'Link (LinkedIn/Site)'),
          onChanged: (_) => _up(),
        ),
      ],
    );
  }
}

class _TextBlockEdit extends StatefulWidget {
  final CVBlock block;
  final CvEditorViewModel vm;
  const _TextBlockEdit({required this.block, required this.vm});
  @override
  State<_TextBlockEdit> createState() => _TextBlockEditState();
}

class _TextBlockEditState extends State<_TextBlockEdit> {
  late TextEditingController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.block.content['text']);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MarkdownToolbar(controller: _ctrl),
        const SizedBox(height: 8),
        TextField(
          controller: _ctrl,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: 'Escreva livremente...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
          onChanged: (v) => widget.vm.updateBlock(widget.block.id, {'text': v}),
        ),
      ],
    );
  }
}

class _ExperienceBlockEdit extends StatefulWidget {
  final CVBlock block;
  final CvEditorViewModel vm;
  const _ExperienceBlockEdit({required this.block, required this.vm});
  @override
  State<_ExperienceBlockEdit> createState() => _ExperienceBlockEditState();
}

class _ExperienceBlockEditState extends State<_ExperienceBlockEdit> {
  late TextEditingController _role, _comp, _per, _desc;
  @override
  void initState() {
    super.initState();
    _role = TextEditingController(text: widget.block.content['role']);
    _comp = TextEditingController(text: widget.block.content['company']);
    _per = TextEditingController(text: widget.block.content['period']);
    _desc = TextEditingController(text: widget.block.content['description']);
  }

  void _up() => widget.vm.updateBlock(widget.block.id, {
    'role': _role.text,
    'company': _comp.text,
    'period': _per.text,
    'description': _desc.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _role,
          decoration: const InputDecoration(labelText: 'Cargo'),
          onChanged: (_) => _up(),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _comp,
                decoration: const InputDecoration(labelText: 'Empresa'),
                onChanged: (_) => _up(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _per,
                decoration: const InputDecoration(labelText: 'Período'),
                onChanged: (_) => _up(),
              ),
            ),
          ],
        ),
        TextField(
          controller: _desc,
          decoration: const InputDecoration(labelText: 'Descrição'),
          maxLines: 3,
          onChanged: (_) => _up(),
        ),
      ],
    );
  }
}

class _EducationBlockEdit extends StatefulWidget {
  final CVBlock block;
  final CvEditorViewModel vm;
  const _EducationBlockEdit({required this.block, required this.vm});
  @override
  State<_EducationBlockEdit> createState() => _EducationBlockEditState();
}

class _EducationBlockEditState extends State<_EducationBlockEdit> {
  late TextEditingController _inst, _deg, _per;
  @override
  void initState() {
    super.initState();
    _inst = TextEditingController(text: widget.block.content['institution']);
    _deg = TextEditingController(text: widget.block.content['degree']);
    _per = TextEditingController(text: widget.block.content['period']);
  }

  void _up() => widget.vm.updateBlock(widget.block.id, {
    'institution': _inst.text,
    'degree': _deg.text,
    'period': _per.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _inst,
          decoration: const InputDecoration(labelText: 'Instituição'),
          onChanged: (_) => _up(),
        ),
        TextField(
          controller: _deg,
          decoration: const InputDecoration(labelText: 'Curso/Grau'),
          onChanged: (_) => _up(),
        ),
        TextField(
          controller: _per,
          decoration: const InputDecoration(labelText: 'Período'),
          onChanged: (_) => _up(),
        ),
      ],
    );
  }
}

class _SkillBlockEdit extends StatefulWidget {
  final CVBlock block;
  final CvEditorViewModel vm;
  const _SkillBlockEdit({required this.block, required this.vm});
  @override
  State<_SkillBlockEdit> createState() => _SkillBlockEditState();
}

class _SkillBlockEditState extends State<_SkillBlockEdit> {
  late TextEditingController _skills;
  @override
  void initState() {
    super.initState();
    _skills = TextEditingController(text: widget.block.content['skills']);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _skills,
      decoration: const InputDecoration(
        labelText: 'Habilidades (separe por vírgula)',
        hintText: 'Flutter, Go, SQL...',
      ),
      onChanged: (v) => widget.vm.updateBlock(widget.block.id, {'skills': v}),
    );
  }
}

class _ProjectBlockEdit extends StatefulWidget {
  final CVBlock block;
  final CvEditorViewModel vm;
  const _ProjectBlockEdit({required this.block, required this.vm});
  @override
  State<_ProjectBlockEdit> createState() => _ProjectBlockEditState();
}

class _ProjectBlockEditState extends State<_ProjectBlockEdit> {
  late TextEditingController _ti, _de, _li;
  @override
  void initState() {
    super.initState();
    _ti = TextEditingController(text: widget.block.content['title']);
    _de = TextEditingController(text: widget.block.content['description']);
    _li = TextEditingController(text: widget.block.content['link']);
  }

  void _up() => widget.vm.updateBlock(widget.block.id, {
    'title': _ti.text,
    'description': _de.text,
    'link': _li.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _ti,
          decoration: const InputDecoration(labelText: 'Título do Projeto'),
          onChanged: (_) => _up(),
        ),
        TextField(
          controller: _li,
          decoration: const InputDecoration(labelText: 'Link (Github/Demo)'),
          onChanged: (_) => _up(),
        ),
        TextField(
          controller: _de,
          decoration: const InputDecoration(labelText: 'Descrição'),
          maxLines: 2,
          onChanged: (_) => _up(),
        ),
      ],
    );
  }
}
