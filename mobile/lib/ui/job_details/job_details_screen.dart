import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/job_repository.dart';
import '../../domain/models/job.dart';
import '../../domain/models/vocabulary_term.dart';
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
        backgroundColor: const Color(0xFFF5F5F7),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Modo Estudo',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          centerTitle: true,
        ),
        body: Consumer<JobDetailsViewModel>(
          builder: (context, viewModel, child) {
            return _buildBody(context, viewModel);
          },
        ),
      ),
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
      return const Center(
        child: Text(
          'Sem termos para estudar nesta vaga.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return PageView.builder(
      itemCount: viewModel.terms.length,
      itemBuilder: (context, index) {
        return _Flashcard(term: viewModel.terms[index]);
      },
    );
  }
}

// Widget interno para o Flashcard
class _Flashcard extends StatelessWidget {
  final VocabularyTerm term;
  const _Flashcard({required this.term});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<JobDetailsViewModel>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
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
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00695C),
                ),
              ),
              if (term.phonetic.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  term.phonetic,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              const SizedBox(height: 40),
              IconButton(
                icon: const Icon(
                  CupertinoIcons.speaker_2_fill,
                  size: 40,
                  color: Colors.black54,
                ),
                onPressed: () => viewModel.speak(term.term),
              ),
            ],
          ),
        ),
        back: _buildCardSide(
          context,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      term.term,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Chip(label: Text(term.grammarType)),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  term.definitionEn,
                  style: GoogleFonts.inter(
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  term.translationPt,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00695C),
                  ),
                ),
                if (term.exampleSentenceEn.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            term.exampleSentenceEn,
                            style: GoogleFonts.inter(color: Colors.grey[800]),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.speaker_1, size: 20),
                          onPressed: () =>
                              viewModel.speak(term.exampleSentenceEn),
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
    );
  }

  Widget _buildCardSide(BuildContext context, {required Widget child}) {
    return Card(
      elevation: 8.0,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: Colors.white,
      child: Center(child: child),
    );
  }
}
