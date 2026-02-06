import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/job.dart';
import '../view_models/dashboard_view_model.dart';

class JobCard extends StatelessWidget {
  final Job job;

  const JobCard({super.key, required this.job});

  void _navigateToDetails(BuildContext context) {
    context.push('/details', extra: job);
  }

  @override
  Widget build(BuildContext context) {
    final statusStyle = _getStatusStyle(job.status);

    return Card(
      elevation: 2.0,
      shadowColor: Colors.black.withOpacity(0.05),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToDetails(context),
        onLongPress: () => _showManagementBottomSheet(context, job),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, statusStyle),
              const SizedBox(height: 12.0),
              Text(
                job.description,
                style: GoogleFonts.inter(
                  fontSize: 14.0,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16.0),
              if (job.tags.isNotEmpty) _buildTags(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, _StatusStyle statusStyle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.title,
                style: GoogleFonts.inter(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6.0),
              Row(
                children: [
                  Text(
                    job.company,
                    style: GoogleFonts.inter(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      job.status,
                      style: GoogleFonts.inter(
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                        color: statusStyle.textColor,
                      ),
                    ),
                    backgroundColor: statusStyle.backgroundColor,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    side: BorderSide.none,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(CupertinoIcons.ellipsis, color: Colors.grey),
          onPressed: () => _showManagementBottomSheet(context, job),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 6.0,
      runSpacing: 6.0,
      children: job.tags
          .map(
            (tag) => Chip(
              label: Text(
                tag,
                style: GoogleFonts.inter(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF00695C),
                ),
              ),
              backgroundColor: const Color(0xFFE0F2F1),
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 2.0,
              ),
              side: BorderSide.none,
              visualDensity: VisualDensity.compact,
            ),
          )
          .toList(),
    );
  }

  void _showManagementBottomSheet(BuildContext context, Job job) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        final viewModel = Provider.of<DashboardViewModel>(
          modalContext,
          listen: false,
        );

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gerenciar Vaga',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Divider(height: 32),
                  Text(
                    'Alterar Status',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    children: ['applied', 'interview', 'offer', 'rejected'].map(
                      (status) {
                        final isSelected = job.status == status;
                        final style = _getStatusStyle(status);
                        return ChoiceChip(
                          label: Text(
                            status,
                            style: GoogleFonts.inter(
                              color: isSelected
                                  ? style.textColor
                                  : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) async {
                            if (selected) {
                              Navigator.pop(modalContext); // Close modal first
                              final success = await viewModel.updateJobStatus(
                                job.id,
                                status,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? 'Status atualizado para: $status'
                                        : viewModel.errorMessage,
                                  ),
                                  backgroundColor: success
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              );
                            }
                          },
                          selectedColor: style.backgroundColor,
                          backgroundColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide.none,
                          ),
                        );
                      },
                    ).toList(),
                  ),
                  const Divider(height: 32),
                  ListTile(
                    leading: const Icon(
                      CupertinoIcons.trash,
                      color: Colors.red,
                    ),
                    title: Text(
                      'Excluir Vaga',
                      style: GoogleFonts.inter(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(modalContext); // Close bottom sheet
                      _showDeleteConfirmationDialog(context, viewModel, job);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    DashboardViewModel viewModel,
    Job job,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir a vaga "${job.title}"? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog
              final success = await viewModel.deleteJob(job.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Vaga excluída com sucesso'
                        : viewModel.errorMessage,
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  _StatusStyle _getStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'interview':
        return _StatusStyle(
          backgroundColor: Colors.purple[100]!,
          textColor: Colors.purple[800]!,
        );
      case 'offer':
        return _StatusStyle(
          backgroundColor: Colors.green[100]!,
          textColor: Colors.green[800]!,
        );
      case 'rejected':
        return _StatusStyle(
          backgroundColor: Colors.red[100]!,
          textColor: Colors.red[800]!,
        );
      case 'applied':
      default:
        return _StatusStyle(
          backgroundColor: Colors.blue[100]!,
          textColor: Colors.blue[800]!,
        );
    }
  }
}

class _StatusStyle {
  final Color backgroundColor;
  final Color textColor;
  _StatusStyle({required this.backgroundColor, required this.textColor});
}
