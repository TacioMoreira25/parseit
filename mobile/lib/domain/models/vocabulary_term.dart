class VocabularyTerm {
  final String term;
  final String definitionEn;
  final String translationPt;
  final String phonetic;
  final String grammarType;
  final String exampleSentenceEn;
  final String exampleSentencePt;

  VocabularyTerm({
    required this.term,
    required this.definitionEn,
    required this.translationPt,
    required this.phonetic,
    required this.grammarType,
    required this.exampleSentenceEn,
    required this.exampleSentencePt,
  });

  factory VocabularyTerm.fromJson(Map<String, dynamic> json) {
    return VocabularyTerm(
      // Mapeando as chaves exatas que vêm do Backend Go (Snake Case)
      term: json['term'] ?? '',
      definitionEn: json['definition_en'] ?? 'Definição indisponível',
      translationPt: json['translation_pt'] ?? 'Tradução indisponível',
      phonetic: json['phonetic_ipa'] ?? '',
      grammarType: json['grammatical_category'] ?? 'Substantivo',
      exampleSentenceEn: json['example_sentence_en'] ?? '',
      exampleSentencePt: json['example_sentence_pt'] ?? '',
    );
  }
}
