import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/job.dart';
import '../view_models/dashboard_view_model.dart';

class JobCard extends StatelessWidget {
  final Job job;
  const JobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.4)),
      ),
      color: theme.brightness == Brightness.light
          ? Colors.white
          : colorScheme.surfaceVariant.withOpacity(0.3),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/details', extra: job),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.business,
                      color: colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Textos Principais
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                job.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // --- NOVO: BADGE DE STATUS CLICÁVEL ---
                            _StatusBadge(job: job),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.company,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (job.location.isNotEmpty || job.jobType.isNotEmpty)
                          Text(
                            "${job.location} • ${job.jobType}",
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Tags ou Loading
              if (job.tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: job.tags
                      .take(4)
                      .map((tag) => _buildTag(context, tag))
                      .toList(),
                )
              else
                Row(
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "IA analisando requisitos...",
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.tertiary,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: colorScheme.secondaryContainer.withOpacity(0.5),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.onSecondaryContainer,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Job job;
  const _StatusBadge({required this.job});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    switch (job.status) {
      case 'interview':
        color = Colors.orange;
        text = 'Entrevista';
        break;
      case 'offer':
        color = Colors.green;
        text = 'Oferta';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Rejeitado';
        break;
      case 'applied':
      default:
        color = Colors.blue;
        text = 'Aplicado';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showStatusMenu(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 8, color: color),
              const SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.arrow_drop_down, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatusMenu(BuildContext context) {
    final viewModel = context.read<DashboardViewModel>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Atualizar Status",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            _buildStatusOption(
              ctx,
              viewModel,
              'applied',
              'Aplicado',
              Colors.blue,
            ),
            _buildStatusOption(
              ctx,
              viewModel,
              'interview',
              'Entrevista',
              Colors.orange,
            ),
            _buildStatusOption(ctx, viewModel, 'offer', 'Oferta', Colors.green),
            _buildStatusOption(
              ctx,
              viewModel,
              'rejected',
              'Rejeitado',
              Colors.red,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(
    BuildContext context,
    DashboardViewModel vm,
    String value,
    String label,
    Color color,
  ) {
    final isSelected = job.status == value;
    return ListTile(
      leading: Icon(
        isSelected ? Icons.check_circle : Icons.circle_outlined,
        color: color,
      ),
      title: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      onTap: () {
        vm.updateJobStatus(job.id, value);
        Navigator.pop(context);
      },
    );
  }
}
