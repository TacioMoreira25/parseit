import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../domain/models/vocabulary_term.dart';

enum DetailsState { loading, success, error }

class JobDetailsViewModel extends ChangeNotifier {
  final JobRepository _jobRepository;
  final List<String> _tags;

  final FlutterTts flutterTts = FlutterTts();

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
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _fetchVocabulary() async {
    _state = DetailsState.loading;
    notifyListeners();
    try {
      if (_tags.isNotEmpty) {
        _terms = await _jobRepository.lookupVocabulary(_tags);
      }
      _state = DetailsState.success;
    } catch (e) {
      _state = DetailsState.error;
      _errorMessage = 'Failed to load study terms.';
      debugPrint('Error fetching vocabulary: $e');
    } finally {
      notifyListeners();
    }
  }

  void speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
}
