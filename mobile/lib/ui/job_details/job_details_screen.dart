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
    // Cria o ViewModel passando o repositório e as tags da vaga
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

    // Usamos Stack para colocar as setas de navegação "flutuando" sobre o PageView
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

  // Usamos um GlobalKey para o FlipCard se quisermos resetar o estado via código,
  // mas aqui o PageView rebuilda o widget, então ele volta para o "front" naturalmente.
  const _Flashcard({required this.term});

  @override
  Widget build(BuildContext context) {
    // Acessamos o viewModel apenas para usar o método speak
    final viewModel = context.read<JobDetailsViewModel>();

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 40.0,
        horizontal: 48.0,
      ), // Aumentei margem lateral para dar espaço às setas web
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
              // Botão de Áudio Principal
              IconButton(
                icon: const Icon(
                  CupertinoIcons.speaker_2_fill,
                  size: 40,
                  color: Colors.black54,
                ),
                onPressed: () => viewModel.speak(term.term),
              ),
              const SizedBox(height: 10),
              Text(
                "Toque para ver o significado",
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[400]),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      term.term,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Chip(
                      label: Text(
                        term.grammarType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: const Color(0xFF00695C),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  term.definitionEn,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  term.translationPt,
                  style: GoogleFonts.inter(
                    fontSize: 18,
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                term.exampleSentenceEn,
                                style: GoogleFonts.inter(
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (term.exampleSentencePt.isNotEmpty)
                                Text(
                                  term.exampleSentencePt,
                                  style: GoogleFonts.inter(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Botão de Áudio da Frase
                        IconButton(
                          icon: const Icon(CupertinoIcons.speaker_1, size: 24),
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
      elevation: 4.0, // Reduzi um pouco a elevação para ficar mais "clean"
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: Colors.white,
      child: Container(
        width: double.infinity,
        height: double.infinity, // Ocupa toda a altura do container do PageView
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
