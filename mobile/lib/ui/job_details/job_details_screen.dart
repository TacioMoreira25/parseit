import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para copiar o link
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/job_repository.dart';
import '../../domain/models/job.dart';
import '../../domain/models/vocabulary_term.dart';
import '../dashboard/view_models/dashboard_view_model.dart';
import 'view_models/job_details_view_model.dart';

class JobDetailsScreen extends StatelessWidget {
  final Job job;
  const JobDetailsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          JobDetailsViewModel(context.read<JobRepository>(), job.tags),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Modo Estudo',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
          actions: [
            // --- MENU DE OPÇÕES ---
            Consumer<JobDetailsViewModel>(
              builder: (context, viewModel, _) {
                return PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onSelected: (value) {
                    if (value == 'view') {
                      _showJobData(context); // <--- NOVA FUNCIONALIDADE
                    } else if (value == 'edit') {
                      context.push('/edit_job', extra: job).then((_) {
                        context.read<DashboardViewModel>().fetchJobs();
                      });
                    } else if (value == 'delete') {
                      _confirmDelete(context, viewModel, job.id);
                    }
                  },
                  itemBuilder: (context) => [
                    // Opção de Visualizar
                    PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Text("Ver Detalhes"),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit, color: Colors.grey, size: 20),
                          const SizedBox(width: 12),
                          const Text("Editar Vaga"),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Excluir",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        body: Consumer<JobDetailsViewModel>(
          builder: (context, viewModel, child) =>
              _buildBody(context, viewModel),
        ),
      ),
    );
  }

  // --- MODAL DE VISUALIZAÇÃO DA VAGA ---
  void _showJobData(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho do Modal
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Text(
                job.title,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                job.company,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),

              // Chips de Informação
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(icon: Icons.work_outline, label: job.jobType),
                  _InfoChip(
                    icon: Icons.location_on_outlined,
                    label: job.location,
                  ),
                  if (job.salary.isNotEmpty)
                    _InfoChip(
                      icon: Icons.attach_money,
                      label: job.salary,
                      color: Colors.green,
                    ),
                  _InfoChip(
                    icon: Icons.flag_outlined,
                    label: _translateStatus(job.status),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Link (Copiável)
              if (job.url.isNotEmpty) ...[
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: job.url));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Link copiado!")),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.link, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            job.url,
                            style: GoogleFonts.inter(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.copy, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Descrição
              Text(
                "Descrição",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: SelectableText(
                  job.description,
                  style: GoogleFonts.inter(fontSize: 15, height: 1.5),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'applied':
        return 'Aplicado';
      case 'interview':
        return 'Entrevista';
      case 'offer':
        return 'Oferta';
      case 'rejected':
        return 'Rejeitado';
      default:
        return status;
    }
  }

  void _confirmDelete(
    BuildContext context,
    JobDetailsViewModel viewModel,
    String jobId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir Vaga"),
        content: const Text(
          "Tem certeza? Isso apagará o progresso de estudo desta vaga.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await viewModel.deleteJob(jobId);
              if (success && context.mounted) {
                context.read<DashboardViewModel>().fetchJobs();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Vaga excluída."),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text("Excluir"),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, JobDetailsViewModel viewModel) {
    if (viewModel.state == DetailsState.loading)
      return const Center(child: CircularProgressIndicator());
    if (viewModel.state == DetailsState.error)
      return Center(child: Text(viewModel.errorMessage));
    if (viewModel.terms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Sem termos para estudar.',
              style: GoogleFonts.inter(color: Theme.of(context).disabledColor),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: viewModel.pageController,
          onPageChanged: viewModel.onPageChanged,
          itemCount: viewModel.terms.length,
          itemBuilder: (context, index) =>
              _Flashcard(term: viewModel.terms[index]),
        ),
        if (kIsWeb) ...[
          _buildWebNav(context, viewModel, isLeft: true),
          _buildWebNav(context, viewModel, isLeft: false),
        ],
      ],
    );
  }

  Widget _buildWebNav(
    BuildContext context,
    JobDetailsViewModel vm, {
    required bool isLeft,
  }) {
    final disabled = isLeft
        ? vm.currentIndex == 0
        : vm.currentIndex == vm.terms.length - 1;
    return Positioned(
      left: isLeft ? 20 : null,
      right: isLeft ? null : 20,
      top: 0,
      bottom: 0,
      child: Center(
        child: IconButton(
          icon: Icon(
            isLeft ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
            size: 40,
          ),
          color: disabled
              ? Theme.of(context).disabledColor.withOpacity(0.3)
              : Theme.of(context).iconTheme.color?.withOpacity(0.5),
          onPressed: disabled ? null : (isLeft ? vm.previousPage : vm.nextPage),
        ),
      ),
    );
  }
}

class _Flashcard extends StatelessWidget {
  final VocabularyTerm term;
  const _Flashcard({required this.term});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<JobDetailsViewModel>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textStyle = GoogleFonts.inter(color: colorScheme.onSurface);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: FlipCard(
            direction: FlipDirection.HORIZONTAL,
            front: _buildCardSide(
              context,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    term.term.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  IconButton.filledTonal(
                    iconSize: 32,
                    icon: const Icon(CupertinoIcons.speaker_2_fill),
                    onPressed: () => viewModel.speak(term.term),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Toque para ver o significado",
                    style: textStyle.copyWith(
                      color: theme.disabledColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            back: _buildCardSide(
              context,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            term.term,
                            style: textStyle.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.translate,
                          size: 20,
                          color: theme.disabledColor,
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Text(
                      term.definitionEn,
                      style: textStyle.copyWith(fontSize: 18, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      term.translationPt,
                      style: textStyle.copyWith(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: colorScheme.primary,
                      ),
                    ),
                    if (term.exampleSentenceEn.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.format_quote_rounded,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "EXEMPLO",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              term.exampleSentenceEn,
                              style: textStyle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: Icon(
                                  CupertinoIcons.speaker_1,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                                onPressed: () =>
                                    viewModel.speak(term.exampleSentenceEn),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardSide(BuildContext context, {required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: child,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty || label == 'Não especificado')
      return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (color ?? Theme.of(context).colorScheme.primary).withOpacity(
          0.1,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (color ?? Theme.of(context).colorScheme.primary).withOpacity(
            0.2,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color ?? Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
