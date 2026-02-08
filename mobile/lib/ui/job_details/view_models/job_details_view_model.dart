import 'dart:io';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../domain/models/vocabulary_term.dart';

enum DetailsState { loading, success, error }

class JobDetailsViewModel extends ChangeNotifier {
  final JobRepository _jobRepository;
  final List<String> _tags;

  final FlutterTts flutterTts = FlutterTts();

  // Controle do Carrossel de Cards
  final PageController pageController = PageController();
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  DetailsState _state = DetailsState.loading;
  DetailsState get state => _state;

  List<VocabularyTerm> _terms = [];
  List<VocabularyTerm> get terms => _terms;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  JobDetailsViewModel(this._jobRepository, this._tags) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _setupTts();
    await _fetchVocabulary();
  }

  Future<void> _setupTts() async {
    try {
      // Configuração para WEB e MOBILE
      await flutterTts.setLanguage("en-US");

      // Ajuste Fino: 0.5 é muito lento (robótico). 0.9 ou 1.0 é o natural.
      await flutterTts.setSpeechRate(0.9);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);

      // Apenas no Mobile (Android/iOS) esperamos o fim da fala
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await flutterTts.awaitSpeakCompletion(true);
      }
    } catch (e) {
      debugPrint("Erro ao configurar TTS: $e");
    }
  }

  Future<void> _fetchVocabulary() async {
    _state = DetailsState.loading;
    notifyListeners();

    try {
      if (_tags.isNotEmpty) {
        _terms = await _jobRepository.lookupVocabulary(_tags);
        if (_terms.isEmpty) {
          _errorMessage = 'Nenhum termo encontrado.';
          _state = DetailsState.success;
        } else {
          _state = DetailsState.success;
        }
      } else {
        _state = DetailsState.success;
      }
    } catch (e) {
      _state = DetailsState.error;
      _errorMessage = 'Erro ao carregar termos.';
    } finally {
      notifyListeners();
    }
  }

  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      // Para o áudio anterior antes de começar um novo (evita sobreposição)
      await flutterTts.stop();
      await flutterTts.speak(text);
    }
  }

  // --- Métodos de Navegação (Essenciais para Web) ---

  void onPageChanged(int index) {
    _currentIndex = index;
    // Opcional: Falar automaticamente ao mudar de card
    // speak(_terms[index].term);
    notifyListeners();
  }

  void nextPage() {
    if (_currentIndex < _terms.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() {
    if (_currentIndex > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    pageController.dispose();
    super.dispose();
  }
}
