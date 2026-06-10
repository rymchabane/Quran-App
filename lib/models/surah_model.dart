class Surah {
  final int number;
  final String nameArabic;
  final String nameSimple;      // e.g. "Al-Fatihah"
  final String nameTranslation; // e.g. "The Opener"
  final int versesCount;
  final String revelationPlace; // "makkah" or "madinah"

  Surah({
    required this.number,
    required this.nameArabic,
    required this.nameSimple,
    required this.nameTranslation,
    required this.versesCount,
    required this.revelationPlace,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['id'],
      nameArabic: json['name_arabic'] ?? '',
      nameSimple: json['name_simple'] ?? '',
      nameTranslation: json['translated_name']?['name'] ?? '',
      versesCount: json['verses_count'] ?? 0,
      revelationPlace: json['revelation_place'] ?? '',
    );
  }
}