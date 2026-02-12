import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../domain/models/vocabulary_term.dart';

enum DetailsState { loading, success, error }

class JobDetailsViewModel extends ChangeNotifier {
  final JobRepository _jobRepository;
  final List<String> _tags;

  final FlutterTts flutterTts = FlutterTts();
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
      await flutterTts.setLanguage("en-US");
      await flutterTts.setSpeechRate(0.9);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await flutterTts.awaitSpeakCompletion(true);
      }
    } catch (e) {
      debugPrint("Erro TTS: $e");
    }
  }

  Future<void> _fetchVocabulary() async {
    _state = DetailsState.loading;
    notifyListeners();

    try {
      if (_tags.isNotEmpty) {
        _terms = await _jobRepository.lookupVocabulary(_tags);
        _state = DetailsState.success;
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

  Future<bool> deleteJob(String jobId) async {
    try {
      await _jobRepository.deleteJob(jobId);
      return true;
    } catch (e) {
      _errorMessage = "Erro ao excluir vaga";
      notifyListeners();
      return false;
    }
  }

  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await flutterTts.stop();
      await flutterTts.speak(text);
    }
  }

  void onPageChanged(int index) {
    _currentIndex = index;
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
