class VocabularyTerm {
  final String term;
  final String phonetic;
  final String definitionEn;
  final String translationPt;
  final String grammarType;
  final String exampleSentenceEn;

  VocabularyTerm({
    required this.term,
    required this.phonetic,
    required this.definitionEn,
    required this.translationPt,
    required this.grammarType,
    required this.exampleSentenceEn,
  });

  factory VocabularyTerm.fromJson(Map<String, dynamic> json) {
    return VocabularyTerm(
      term: json['term'] as String? ?? 'N/A',
      phonetic: json['phonetic'] as String? ?? '',
      definitionEn:
          json['definition_en'] as String? ?? 'No definition available.',
      translationPt:
          json['translation_pt'] as String? ?? 'Tradução não disponível.',
      grammarType: json['grammar_type'] as String? ?? '',
      exampleSentenceEn: json['example_sentence_en'] as String? ?? '',
    );
  }
}
