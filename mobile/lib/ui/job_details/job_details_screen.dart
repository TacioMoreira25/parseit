import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/ui/job_details/view_models/job_details_view_model.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/job_repository.dart';
import '../../domain/models/job.dart';
import '../../domain/models/vocabulary_term.dart';

class JobDetailsScreen extends StatelessWidget {
  final Job job;
  const JobDetailsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          JobDetailsViewModel(context.read<JobRepository>(), job.tags),
      // O Builder cria um NOVO context que está ABAIXO do Provider
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text('Modo Estudo'),
          ),
          body: Consumer<JobDetailsViewModel>(
            builder: (context, viewModel, child) {
              return _buildBody(context, viewModel);
            },
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, JobDetailsViewModel viewModel) {
    if (viewModel.state == DetailsState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.state == DetailsState.error) {
      return Center(child: Text(viewModel.errorMessage));
    }

    if (viewModel.terms.isEmpty) {
      return const Center(child: Text('Sem termos para estudar.'));
    }

    return Stack(
      children: [
        PageView.builder(
          controller: viewModel.pageController,
          onPageChanged: viewModel.onPageChanged,
          itemCount: viewModel.terms.length,
          itemBuilder: (context, index) {
            return _Flashcard(term: viewModel.terms[index]);
          },
        ),
        if (kIsWeb) ...[
          _buildWebNav(viewModel, isLeft: true),
          _buildWebNav(viewModel, isLeft: false),
        ],
      ],
    );
  }

  Widget _buildWebNav(JobDetailsViewModel vm, {required bool isLeft}) {
    bool canNav = isLeft
        ? vm.currentIndex > 0
        : vm.currentIndex < vm.terms.length - 1;
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
          onPressed: canNav ? (isLeft ? vm.previousPage : vm.nextPage) : null,
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
    // Aqui usamos context.read pois estamos dentro da árvore do Provider
    final viewModel = context.read<JobDetailsViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 48.0),
      child: FlipCard(
        front: _buildCardSide(
          context,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                term.term.toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 40),
              IconButton(
                iconSize: 64,
                icon: const Icon(CupertinoIcons.speaker_2_fill),
                onPressed: () => viewModel.speak(term.term),
              ),
            ],
          ),
        ),
        back: _buildCardSide(
          context,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  term.term,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(height: 32),
                Text(
                  term.definitionEn,
                  style: const TextStyle(fontSize: 18, height: 1.4),
                ),
                const SizedBox(height: 16),
                Text(
                  term.translationPt,
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: colorScheme.primary,
                  ),
                ),
                if (term.exampleSentenceEn.isNotEmpty)
                  _buildExampleBox(context, viewModel),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExampleBox(BuildContext context, JobDetailsViewModel vm) {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Example",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            term.exampleSentenceEn,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(CupertinoIcons.speaker_1, size: 20),
              onPressed: () => vm.speak(term.exampleSentenceEn),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSide(BuildContext context, {required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox.expand(child: child),
    );
  }
}
