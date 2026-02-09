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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(viewModel.errorMessage, textAlign: TextAlign.center),
        ),
      );
    }

    if (viewModel.terms.isEmpty) {
      return const Center(
        child: Text(
          'Sem termos para estudar nesta vaga.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: viewModel.pageController, // Conecta o controller
          onPageChanged: viewModel.onPageChanged,
          itemCount: viewModel.terms.length,
          itemBuilder: (context, index) {
            return _Flashcard(term: viewModel.terms[index]);
          },
        ),

        // --- Navegação para WEB (Setas Laterais) ---
        if (kIsWeb) ...[
          // Seta Esquerda (Anterior)
          Positioned(
            left: 20,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 40,
                  color: Colors.grey,
                ),
                onPressed: viewModel.currentIndex > 0
                    ? viewModel.previousPage
                    : null, // Desabilita se for o primeiro
              ),
            ),
          ),
          // Seta Direita (Próximo)
          Positioned(
            right: 20,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 40,
                  color: Colors.grey,
                ),
                onPressed: viewModel.currentIndex < viewModel.terms.length - 1
                    ? viewModel.nextPage
                    : null, // Desabilita se for o último
              ),
            ),
          ),
        ],
      ],
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
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 48.0),
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
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF00695C),
                ),
              ),

              const SizedBox(height: 40),

              IconButton(
                iconSize: 64,
                icon: const Icon(
                  CupertinoIcons.speaker_2_fill,
                  color: Colors.black54,
                ),
                onPressed: () => viewModel.speak(term.term),
              ),
              const SizedBox(height: 20),
              Text(
                "Toque para ver o significado",
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[400]),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      term.term,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.translate, color: Colors.grey, size: 20),
                  ],
                ),
                const Divider(height: 32),

                Text(
                  term.definitionEn,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  term.translationPt,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF00695C),
                  ),
                ),

                if (term.exampleSentenceEn.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4F4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.format_quote_rounded,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Exemplo",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          term.exampleSentenceEn,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        if (term.exampleSentencePt.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            term.exampleSentencePt,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(
                              CupertinoIcons.speaker_1,
                              size: 20,
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
    );
  }

  Widget _buildCardSide(BuildContext context, {required Widget child}) {
    return Card(
      elevation: 4.0,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: Colors.white,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
